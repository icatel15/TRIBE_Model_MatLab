classdef OptimizationRunner < handle
    %OPTIMIZATIONRUNNER Execute two-stage optimization with UI integration.
    % Wraps twoStageOptimizer for use with the TribeFrontEnd GUI.

    properties
        baseConfig          % Base configuration for optimization
        lastResults         % Results from last optimization run
        options             % Optimization options
    end

    properties (Access = private)
        isCancelled_        % Cancel flag
        currentStage        % 1 or 2
        currentProgress     % 0-1 progress within stage
        statusMessage       % Current status text
    end

    methods
        function obj = OptimizationRunner(config)
            %OPTIMIZATIONRUNNER Constructor.
            % OptimizationRunner() - use default config
            % OptimizationRunner(config) - use provided config

            if nargin < 1 || isempty(config)
                obj.baseConfig = tribe.Config.default();
            else
                obj.baseConfig = tribe.Config.apply(config);
            end

            obj.lastResults = [];
            obj.options = obj.getDefaultOptions();
            obj.isCancelled_ = false;
            obj.currentStage = 0;
            obj.currentProgress = 0;
            obj.statusMessage = 'Ready';
        end

        function setBaseConfig(obj, config)
            %SETBASECONFIG Update the base configuration.
            obj.baseConfig = tribe.Config.apply(config);
        end

        function setOptions(obj, opts)
            %SETOPTIONS Update optimization options.
            % opts struct with fields: top_n, objective, annualization_years, n_samples, fixed_market_values

            if isfield(opts, 'top_n')
                obj.options.top_n = opts.top_n;
            end
            if isfield(opts, 'objective')
                obj.options.objective = opts.objective;
            end
            if isfield(opts, 'annualization_years')
                obj.options.annualization_years = opts.annualization_years;
            end
            if isfield(opts, 'n_samples')
                obj.options.n_samples = opts.n_samples;
            end
            if isfield(opts, 'fixed_market_values')
                obj.options.fixed_market_values = logical(opts.fixed_market_values);
            end
        end

        function results = runOptimization(obj)
            %RUNOPTIMIZATION Execute the two-stage optimization.
            % Returns results struct from twoStageOptimizer.

            obj.isCancelled_ = false;
            obj.currentStage = 0;
            obj.currentProgress = 0;
            obj.statusMessage = 'Starting optimization...';

            % Set up callbacks
            opts = obj.options;
            opts.progress_callback = @(stage, prog, msg) obj.updateProgress(stage, prog, msg);
            opts.cancel_check = @() obj.isCancelled_;
            opts.ui_yield = true;

            results = tribe.analysis.twoStageOptimizer(obj.baseConfig, opts);
            obj.lastResults = results;

            if results.completed
                obj.statusMessage = 'Optimization complete.';
            elseif isfield(results, 'cancelled') && results.cancelled
                obj.statusMessage = 'Optimization cancelled.';
            elseif isfield(results, 'error_message') && strlength(string(results.error_message)) > 0
                obj.statusMessage = char(results.error_message);
            else
                obj.statusMessage = 'Optimization stopped.';
            end
        end

        function cancel(obj)
            %CANCEL Cancel a running optimization.
            obj.isCancelled_ = true;
            obj.statusMessage = 'Cancelling...';
        end

        function tf = isCancelled(obj)
            %ISCANCELLED Check if optimization was cancelled.
            tf = obj.isCancelled_;
        end

        function [stage, progress, message] = getProgress(obj)
            %GETPROGRESS Get current progress information.
            stage = obj.currentStage;
            progress = obj.currentProgress;
            message = obj.statusMessage;
        end

        function topConfigs = getStage1TopN(obj, n)
            %GETSTAGE1TOPN Get top N configurations from Stage 1.
            if isempty(obj.lastResults) || ~isfield(obj.lastResults, 'stage1_top_n')
                error('OptimizationRunner:NoData', 'No Stage 1 results available.');
            end

            if nargin < 2
                topConfigs = obj.lastResults.stage1_top_n;
            else
                n = min(n, height(obj.lastResults.stage1_top_n));
                topConfigs = obj.lastResults.stage1_top_n(1:n, :);
            end
        end

        function stage2Table = getStage2Table(obj)
            %GETSTAGE2TABLE Get Stage 2 results as a table.
            if isempty(obj.lastResults) || ~isfield(obj.lastResults, 'stage2_results')
                error('OptimizationRunner:NoData', 'No Stage 2 results available.');
            end

            stage2 = obj.lastResults.stage2_results;
            n = numel(stage2);

            rank = (1:n)';
            chipset = strings(n, 1);
            cooling_method = strings(n, 1);
            process_id = strings(n, 1);
            objective = zeros(n, 1);

            for i = 1:n
                chipset(i) = stage2{i}.chipset;
                cooling_method(i) = stage2{i}.cooling_method;
                process_id(i) = stage2{i}.process_id;
                objective(i) = stage2{i}.objective;
            end

            stage2Table = table(rank, chipset, cooling_method, process_id, objective);
        end

        function cfg = getBestConfig(obj)
            %GETBESTCONFIG Get the overall best configuration.
            if isempty(obj.lastResults) || ~isfield(obj.lastResults, 'best_config')
                error('OptimizationRunner:NoData', 'No optimization results available.');
            end
            cfg = obj.lastResults.best_config;
        end

        function modelResults = getBestResults(obj)
            %GETBESTRESULTS Get the model results for the best configuration.
            if isempty(obj.lastResults) || ~isfield(obj.lastResults, 'best_results')
                error('OptimizationRunner:NoData', 'No optimization results available.');
            end
            modelResults = obj.lastResults.best_results;
        end

        function exportResults(obj, filepath, format)
            %EXPORTRESULTS Export optimization results to file.
            if isempty(obj.lastResults)
                error('OptimizationRunner:NoData', 'No results to export.');
            end

            if nargin < 3
                [~, ~, ext] = fileparts(filepath);
                format = lower(strrep(ext, '.', ''));
            end

            switch lower(format)
                case 'csv'
                    % Export Stage 1 top N results
                    writetable(obj.lastResults.stage1_top_n, filepath);

                case 'mat'
                    optimizationResults = obj.lastResults;
                    save(filepath, 'optimizationResults');

                otherwise
                    error('OptimizationRunner:InvalidFormat', 'Unsupported format: %s', format);
            end
        end

        function opts = getDefaultOptions(~)
            %GETDEFAULTOPTIONS Get default optimization options.
            opts = struct();
            opts.top_n = 20;
            opts.objective = 'profit';
            opts.annualization_years = 10;
            opts.n_samples = 50;  % Reduced: only 1 continuous param to optimize
            opts.fixed_market_values = true;
        end

        function metrics = getAvailableObjectives(~)
            %GETAVAILABLEOBJECTIVES Get available optimization objectives.
            metrics = struct();
            metrics.profit = 'Annualized Profit (GBP/yr)';
            metrics.roi = 'Unlevered ROI (%)';
            metrics.payback = 'Simple Payback (years)';
        end
    end

    methods (Access = private)
        function updateProgress(obj, stage, progress, message)
            obj.currentStage = stage;
            obj.currentProgress = progress;
            obj.statusMessage = message;
        end
    end
end
