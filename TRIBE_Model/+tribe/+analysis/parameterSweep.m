function results = parameterSweep(base_config, param_name, param_values)
%PARAMETERSWEEP Run the model across a range of parameter values.

if nargin < 1
    base_config = [];
end

cfg_base = tribe.Config.apply(base_config);

if nargin < 2 || isempty(param_name)
    error('analysis:parameterSweep', 'Parameter name is required.');
end
if nargin < 3 || isempty(param_values)
    error('analysis:parameterSweep', 'Parameter values are required.');
end

[value_cells, value_col] = normalizeParamValues(param_values);
n = numel(value_cells);

payback_years = zeros(n, 1);
roi_pct = zeros(n, 1);
gross_margin_pct = zeros(n, 1);
capex_gbp = zeros(n, 1);
opex_gbp_per_yr = zeros(n, 1);
revenue_gbp_per_yr = zeros(n, 1);
modules_in_system = zeros(n, 1);

for i = 1:n
    cfg = cfg_base;
    cfg = tribe.analysis.setNestedField(cfg, param_name, value_cells{i});
    run = tribe.Model.runWithConfig(cfg);

    payback_years(i) = run.spl.simple_payback_years;
    roi_pct(i) = run.spl.unlevered_roi_pct;
    gross_margin_pct(i) = run.spl.gross_margin_pct;
    capex_gbp(i) = run.spl.total_system_capex_gbp;
    opex_gbp_per_yr(i) = run.spl.total_opex_gbp_per_yr;
    revenue_gbp_per_yr(i) = run.spl.total_revenue_gbp_per_yr;
    modules_in_system(i) = run.spl.modules_in_system;
end

parameter = repmat(string(param_name), n, 1);
results = table(parameter, value_col, payback_years, roi_pct, gross_margin_pct, ...
    capex_gbp, opex_gbp_per_yr, revenue_gbp_per_yr, modules_in_system);
results.Properties.VariableNames = {
    'parameter',
    'param_value',
    'simple_payback_years',
    'unlevered_roi_pct',
    'gross_margin_pct',
    'total_system_capex_gbp',
    'total_opex_gbp_per_yr',
    'total_revenue_gbp_per_yr',
    'modules_in_system'
    };
end

function [value_cells, value_col] = normalizeParamValues(values)
if iscell(values)
    value_cells = values(:);
    if all(cellfun(@(x) isnumeric(x) && isscalar(x), value_cells))
        value_col = cellfun(@(x) x, value_cells);
    else
        value_col = string(value_cells);
    end
elseif isstring(values)
    value_cells = num2cell(values(:));
    value_col = values(:);
elseif ischar(values)
    value_cells = {string(values)};
    value_col = string(values);
elseif isnumeric(values)
    value_cells = num2cell(values(:));
    value_col = values(:);
else
    error('analysis:parameterSweep', 'Unsupported parameter value type.');
end
end
