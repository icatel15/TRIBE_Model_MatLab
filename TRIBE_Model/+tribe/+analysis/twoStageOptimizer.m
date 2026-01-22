function results = twoStageOptimizer(base_config, options)
%TWOSTAGEOPTIMIZER Run two-stage optimization for optimal TRIBE configuration.
%
% SYNTAX:
%   results = twoStageOptimizer()
%   results = twoStageOptimizer(base_config)
%   results = twoStageOptimizer(base_config, options)
%
% INPUTS:
%   base_config - Base tribe.Config struct (optional, uses default if empty)
%   options     - struct with fields:
%       .top_n               - Number of configs to optimize in Stage 2 (default: 20)
%       .objective           - 'profit', 'roi', or 'payback' (default: 'profit')
%       .annualization_years - Years for capex annualization (default: 10)
%       .progress_callback   - function handle @(stage, progress, message)
%       .cancel_check        - function handle @() returning true to cancel
%       .n_samples           - Latin Hypercube samples for Stage 2 (default: 500)
%
% OUTPUTS:
%   results - struct with:
%       .stage1_all     - Table of all discrete combo results
%       .stage1_top_n   - Top N results from Stage 1
%       .stage2_results - Cell array of optimized results for top N
%       .best_config    - Optimal configuration struct
%       .best_results   - Full model results for best config
%       .best_objective - Best objective value achieved
%       .completed      - true if optimization finished without cancel

if nargin < 1 || isempty(base_config)
    base_config = tribe.Config.default();
else
    base_config = tribe.Config.apply(base_config);
end

if nargin < 2
    options = struct();
end

% Set defaults
options = setDefaultOption(options, 'top_n', 20);
options = setDefaultOption(options, 'objective', 'profit');
options = setDefaultOption(options, 'annualization_years', 10);
options = setDefaultOption(options, 'progress_callback', []);
options = setDefaultOption(options, 'cancel_check', @() false);
options = setDefaultOption(options, 'n_samples', 500);

results = struct();
results.completed = false;

% Stage 1: Grid search all discrete combinations
reportProgress(options, 1, 0, 'Stage 1: Building discrete grid...');
stage1 = runStage1GridSearch(base_config, options);

if options.cancel_check()
    results.stage1_all = stage1.all_results;
    results.stage1_top_n = stage1.top_n;
    return;
end

results.stage1_all = stage1.all_results;
results.stage1_top_n = stage1.top_n;

% Stage 2: Optimize continuous parameters for top N configs
reportProgress(options, 2, 0, 'Stage 2: Optimizing continuous parameters...');
stage2 = runStage2Optimization(stage1.top_n, base_config, options);

if options.cancel_check()
    results.stage2_results = stage2.results;
    return;
end

results.stage2_results = stage2.results;

% Find overall best
best_idx = 1;
best_obj = -Inf;
if strcmp(options.objective, 'payback')
    best_obj = Inf;
end

for i = 1:numel(stage2.results)
    obj = stage2.results{i}.objective;
    if strcmp(options.objective, 'payback')
        if obj < best_obj
            best_obj = obj;
            best_idx = i;
        end
    else
        if obj > best_obj
            best_obj = obj;
            best_idx = i;
        end
    end
end

results.best_config = stage2.results{best_idx}.config;
results.best_results = stage2.results{best_idx}.model_results;
results.best_objective = best_obj;
results.completed = true;

reportProgress(options, 2, 1, 'Optimization complete.');
end

%% Stage 1: Grid Search
function stage1 = runStage1GridSearch(base_config, options)
    % Build grid of all discrete combinations
    grid = buildDiscreteGrid();
    n = numel(grid);

    % Pre-allocate results table
    chipset = strings(n, 1);
    cooling_method = strings(n, 1);
    process_id = strings(n, 1);
    modules = zeros(n, 1);
    capex = zeros(n, 1);
    opex = zeros(n, 1);
    revenue = zeros(n, 1);
    profit = zeros(n, 1);
    annualized_profit = zeros(n, 1);
    objective = zeros(n, 1);
    valid = true(n, 1);

    for i = 1:n
        if options.cancel_check()
            break;
        end

        % Build config for this discrete combination
        cfg = base_config;
        cfg.rack_profile.chipset = grid(i).chipset;
        cfg.rack_profile.cooling_method = grid(i).cooling;
        cfg.buyer_profile.process_id = grid(i).process;

        try
            run = tribe.Model.runWithConfig(cfg);

            chipset(i) = grid(i).chipset;
            cooling_method(i) = grid(i).cooling;
            process_id(i) = grid(i).process;
            modules(i) = run.spl.modules_in_system;
            capex(i) = run.spl.total_system_capex_gbp;
            opex(i) = run.spl.total_opex_gbp_per_yr;
            revenue(i) = run.spl.total_revenue_gbp_per_yr;
            profit(i) = run.spl.gross_profit_gbp_per_yr;
            annualized_profit(i) = profit(i) - (capex(i) / options.annualization_years);
            objective(i) = calcObjective(run.spl, options);
        catch
            valid(i) = false;
            objective(i) = getWorstObjective(options);
        end

        % Report progress
        reportProgress(options, 1, i/n, sprintf('Stage 1: %d/%d combinations tested', i, n));
    end

    % Create results table
    results_table = table(chipset, cooling_method, process_id, modules, ...
        capex, opex, revenue, profit, annualized_profit, objective, valid);

    % Sort by objective (descending for profit/roi, ascending for payback)
    if strcmp(options.objective, 'payback')
        results_table = sortrows(results_table, 'objective', 'ascend');
    else
        results_table = sortrows(results_table, 'objective', 'descend');
    end

    % Filter valid results only for top N
    valid_results = results_table(results_table.valid, :);
    top_n_count = min(options.top_n, height(valid_results));

    stage1.all_results = results_table;
    stage1.top_n = valid_results(1:top_n_count, :);
end

%% Stage 2: Continuous Optimization
function stage2 = runStage2Optimization(top_configs, base_config, options)
    bounds = tribe.analysis.getOptimizableBounds();
    n_params = numel(bounds);
    n_configs = height(top_configs);
    n_samples = options.n_samples;

    stage2_results = cell(n_configs, 1);

    for c = 1:n_configs
        if options.cancel_check()
            break;
        end

        % Set discrete parameters from Stage 1 result
        cfg = base_config;
        cfg.rack_profile.chipset = top_configs.chipset(c);
        cfg.rack_profile.cooling_method = top_configs.cooling_method(c);
        cfg.buyer_profile.process_id = top_configs.process_id(c);

        % Latin Hypercube Sampling
        lhs_samples = lhsdesign(n_samples, n_params);

        % Scale samples to parameter bounds
        param_values = zeros(n_samples, n_params);
        for p = 1:n_params
            lb = bounds(p).lower;
            ub = bounds(p).upper;
            param_values(:, p) = lb + lhs_samples(:, p) * (ub - lb);
        end

        % Evaluate all samples
        objectives = zeros(n_samples, 1);
        for s = 1:n_samples
            test_cfg = cfg;
            for p = 1:n_params
                test_cfg = tribe.analysis.setNestedField(test_cfg, bounds(p).path, param_values(s, p));
            end

            try
                run = tribe.Model.runWithConfig(test_cfg);
                objectives(s) = calcObjective(run.spl, options);
            catch
                objectives(s) = getWorstObjective(options);
            end
        end

        % Find best sample
        if strcmp(options.objective, 'payback')
            [best_obj, best_idx] = min(objectives);
        else
            [best_obj, best_idx] = max(objectives);
        end

        % Build optimal config
        best_cfg = cfg;
        for p = 1:n_params
            best_cfg = tribe.analysis.setNestedField(best_cfg, bounds(p).path, param_values(best_idx, p));
        end

        % Run final model with best config
        try
            best_run = tribe.Model.runWithConfig(best_cfg);
            best_obj = calcObjective(best_run.spl, options);
        catch
            best_run = struct();
            best_obj = getWorstObjective(options);
        end

        stage2_results{c} = struct(...
            'config', best_cfg, ...
            'model_results', best_run, ...
            'objective', best_obj, ...
            'chipset', top_configs.chipset(c), ...
            'cooling_method', top_configs.cooling_method(c), ...
            'process_id', top_configs.process_id(c));

        reportProgress(options, 2, c/n_configs, ...
            sprintf('Stage 2: Optimized config %d/%d', c, n_configs));
    end

    stage2.results = stage2_results;
end

%% Helper Functions
function grid = buildDiscreteGrid()
    ref = tribe.data.ReferenceData();
    chipsets = ref.chipsets.name;
    cooling = ref.cooling_methods.name;

    processes = tribe.data.ProcessLibrary.all();
    process_ids = string({processes.dropdown_name});

    n_total = numel(chipsets) * numel(cooling) * numel(process_ids);

    grid = struct('chipset', cell(n_total, 1), 'cooling', cell(n_total, 1), ...
                  'process', cell(n_total, 1));
    idx = 0;
    for c = 1:numel(chipsets)
        for m = 1:numel(cooling)
            for p = 1:numel(process_ids)
                idx = idx + 1;
                grid(idx).chipset = chipsets(c);
                grid(idx).cooling = cooling(m);
                grid(idx).process = process_ids(p);
            end
        end
    end
end

function obj = calcObjective(spl, options)
    switch options.objective
        case 'profit'
            % Annualized profit = gross_profit - (capex / years)
            annualized_capex = spl.total_system_capex_gbp / options.annualization_years;
            obj = spl.gross_profit_gbp_per_yr - annualized_capex;

        case 'roi'
            obj = spl.unlevered_roi_pct;

        case 'payback'
            obj = spl.simple_payback_years;
            if obj <= 0 || ~isfinite(obj)
                obj = 999;
            end
    end
end

function obj = getWorstObjective(options)
    switch options.objective
        case {'profit', 'roi'}
            obj = -Inf;
        case 'payback'
            obj = Inf;
    end
end

function reportProgress(options, stage, progress, message)
    if ~isempty(options.progress_callback)
        options.progress_callback(stage, progress, message);
    end
end

function opts = setDefaultOption(opts, field, default)
    if ~isfield(opts, field) || isempty(opts.(field))
        opts.(field) = default;
    end
end
