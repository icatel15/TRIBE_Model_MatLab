function sensitivity = sensitivityAnalysis(base_config, param_names, deltas)
%SENSITIVITYANALYSIS Run +/- sensitivity analysis for key inputs.

if nargin < 1
    base_config = [];
end

cfg_base = tribe.Config.apply(base_config);

if nargin < 2 || isempty(param_names)
    param_names = defaultParamNames();
end
param_names = string(param_names(:));

if nargin < 3 || isempty(deltas)
    deltas = [-0.2, -0.1, 0.1, 0.2];
end
if ~isnumeric(deltas)
    error('analysis:sensitivityAnalysis', 'Deltas must be numeric.');
end

deltas = deltas(:);

base_run = tribe.Model.runWithConfig(cfg_base);
base_metrics = struct();
base_metrics.simple_payback_years = base_run.spl.simple_payback_years;
base_metrics.unlevered_roi_pct = base_run.spl.unlevered_roi_pct;
base_metrics.gross_margin_pct = base_run.spl.gross_margin_pct;

row_count = numel(param_names) * numel(deltas);
parameter = strings(row_count, 1);
parameter_label = strings(row_count, 1);
delta_pct = zeros(row_count, 1);
value = zeros(row_count, 1);
payback_years = zeros(row_count, 1);
roi_pct = zeros(row_count, 1);
gross_margin_pct = zeros(row_count, 1);

row = 0;
for i = 1:numel(param_names)
    param_name = param_names(i);
    base_value = tribe.analysis.getNestedField(cfg_base, param_name);
    if ~(isnumeric(base_value) && isscalar(base_value))
        error('analysis:sensitivityAnalysis', 'Parameter %s must be numeric.', param_name);
    end
    label = formatParamLabel(param_name);

    for j = 1:numel(deltas)
        row = row + 1;
        delta = deltas(j);
        adjusted_value = base_value * (1 + delta);
        adjusted_value = clampValue(param_name, adjusted_value);

        cfg = cfg_base;
        cfg = tribe.analysis.setNestedField(cfg, param_name, adjusted_value);
        run = tribe.Model.runWithConfig(cfg);

        parameter(row) = param_name;
        parameter_label(row) = label;
        delta_pct(row) = delta;
        value(row) = adjusted_value;
        payback_years(row) = run.spl.simple_payback_years;
        roi_pct(row) = run.spl.unlevered_roi_pct;
        gross_margin_pct(row) = run.spl.gross_margin_pct;
    end
end

scenarios = table(parameter, parameter_label, delta_pct, value, ...
    payback_years, roi_pct, gross_margin_pct, ...
    'VariableNames', {
    'parameter', ...
    'parameter_label', ...
    'delta_pct', ...
    'value', ...
    'simple_payback_years', ...
    'unlevered_roi_pct', ...
    'gross_margin_pct' ...
    });

sensitivity = struct();
sensitivity.base_config = cfg_base;
sensitivity.base_results = base_run;
sensitivity.base_metrics = base_metrics;
sensitivity.scenarios = scenarios;
sensitivity.tornado = buildTornadoTables(param_names, scenarios, base_metrics);
end

function names = defaultParamNames()
names = [
    "module_criteria.compute_rate_gbp_per_kw_per_month"
    "module_criteria.target_utilisation_rate_pct"
    "module_criteria.base_heat_price_no_hp_gbp_per_mwh"
    "module_criteria.premium_heat_price_with_hp_gbp_per_mwh"
    "module_opex.electricity_rate_gbp_per_kwh"
    "rack_profile.module_it_capacity_target_kw"
    "system.shared_infrastructure_pct"
    "system.shared_overhead_pct"
    ];
end

function label = formatParamLabel(param_name)
parts = strsplit(param_name, ".");
label = string(parts(end));
label = strrep(label, "_", " ");
end

function adjusted = clampValue(param_name, value)
adjusted = value;
if adjusted < 0
    adjusted = 0;
end
if contains(param_name, "_pct")
    adjusted = min(max(adjusted, 0), 1);
end
end

function tornado = buildTornadoTables(param_names, scenarios, base_metrics)
metrics = {"simple_payback_years", "unlevered_roi_pct", "gross_margin_pct"};

param_labels = strings(numel(param_names), 1);
for i = 1:numel(param_names)
    mask = scenarios.parameter == param_names(i);
    label = scenarios.parameter_label(find(mask, 1));
    if ~isempty(label)
        param_labels(i) = label;
    else
        param_labels(i) = formatParamLabel(param_names(i));
    end
end

for m = 1:numel(metrics)
    metric = metrics{m};
    low_delta = zeros(numel(param_names), 1);
    high_delta = zeros(numel(param_names), 1);
    low_value = zeros(numel(param_names), 1);
    high_value = zeros(numel(param_names), 1);

    base_value = base_metrics.(metric);

    for i = 1:numel(param_names)
        mask = scenarios.parameter == param_names(i);
        values = scenarios.(metric)(mask);
        if isempty(values)
            low_delta(i) = 0;
            high_delta(i) = 0;
        else
            delta_values = values - base_value;
            low_delta(i) = min(delta_values);
            high_delta(i) = max(delta_values);
        end
        low_value(i) = base_value + low_delta(i);
        high_value(i) = base_value + high_delta(i);
    end

    tornado.(metric) = table(param_names, param_labels, low_delta, high_delta, low_value, high_value, ...
        'VariableNames', {
        'parameter',
        'parameter_label',
        'low_delta',
        'high_delta',
        'low_value',
        'high_value'
        });
end
end
