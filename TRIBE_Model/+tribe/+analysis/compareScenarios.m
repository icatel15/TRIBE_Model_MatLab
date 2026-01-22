function comparison = compareScenarios(configs)
%COMPARESCENARIOS Run multiple configurations and compare key outputs.

if nargin < 1 || isempty(configs)
    error('analysis:compareScenarios', 'Provide a list of configs to compare.');
end

config_list = normalizeConfigs(configs);
n = numel(config_list);

scenario = strings(n, 1);
chipset = strings(n, 1);
cooling_method = strings(n, 1);
process_id = strings(n, 1);
modules_in_system = zeros(n, 1);
capex_gbp = zeros(n, 1);
opex_gbp_per_yr = zeros(n, 1);
revenue_gbp_per_yr = zeros(n, 1);
gross_profit_gbp_per_yr = zeros(n, 1);
gross_margin_pct = zeros(n, 1);
payback_years = zeros(n, 1);
roi_pct = zeros(n, 1);

runs = cell(n, 1);
for i = 1:n
    cfg = config_list{i};
    run = tribe.Model.runWithConfig(cfg);
    runs{i} = run;

    scenario(i) = deriveScenarioLabel(run.config);
    chipset(i) = run.config.rack_profile.chipset;
    cooling_method(i) = run.config.rack_profile.cooling_method;
    process_id(i) = run.config.buyer_profile.process_id;

    modules_in_system(i) = run.spl.modules_in_system;
    capex_gbp(i) = run.spl.total_system_capex_gbp;
    opex_gbp_per_yr(i) = run.spl.total_opex_gbp_per_yr;
    revenue_gbp_per_yr(i) = run.spl.total_revenue_gbp_per_yr;
    gross_profit_gbp_per_yr(i) = run.spl.gross_profit_gbp_per_yr;
    gross_margin_pct(i) = run.spl.gross_margin_pct;
    payback_years(i) = run.spl.simple_payback_years;
    roi_pct(i) = run.spl.unlevered_roi_pct;
end

comparison = struct();
comparison.table = table(scenario, chipset, cooling_method, process_id, ...
    modules_in_system, capex_gbp, opex_gbp_per_yr, revenue_gbp_per_yr, ...
    gross_profit_gbp_per_yr, gross_margin_pct, payback_years, roi_pct);
comparison.table.Properties.VariableNames = {
    'scenario',
    'chipset',
    'cooling_method',
    'process_id',
    'modules_in_system',
    'total_system_capex_gbp',
    'total_opex_gbp_per_yr',
    'total_revenue_gbp_per_yr',
    'gross_profit_gbp_per_yr',
    'gross_margin_pct',
    'simple_payback_years',
    'unlevered_roi_pct'
    };
comparison.results = runs;
end

function config_list = normalizeConfigs(configs)
if iscell(configs)
    config_list = configs(:);
elseif isstruct(configs)
    if numel(configs) == 1
        config_list = {configs};
    else
        config_list = arrayfun(@(x) x, configs(:), 'UniformOutput', false);
    end
else
    error('analysis:compareScenarios', 'Configs must be a struct array or cell array.');
end
end

function label = deriveScenarioLabel(cfg)
if isfield(cfg, 'scenario_name') && ~isempty(cfg.scenario_name)
    label = string(cfg.scenario_name);
elseif isfield(cfg, 'name') && ~isempty(cfg.name)
    label = string(cfg.name);
else
    label = cfg.rack_profile.chipset + " | " + cfg.rack_profile.cooling_method ...
        + " | " + cfg.buyer_profile.process_id;
end
end
