function test_rack_profile()
%TEST_RACK_PROFILE Validate rack profile calculations against the Excel workbook.

validation_dir = fileparts(mfilename('fullpath'));
model_root = fileparts(validation_dir);
repo_root = fileparts(model_root);
excel_path = fullfile(repo_root, 'Tribe_model_20.1.26.xlsx');

addpath(model_root);

[chipset, cooling_method, module_it_target, electricity_price, annual_hours] = readInputs(excel_path);
rp = tribe.calc.calcRackProfile(chipset, cooling_method, module_it_target, electricity_price, annual_hours);

expected = calcExpected(chipset, cooling_method, module_it_target, electricity_price, annual_hours);
[excel_expected, has_excel_values] = readExcelExpected(excel_path);
if has_excel_values
    expected = mergeExpected(expected, excel_expected);
else
    fprintf('Rack profile validation: Excel formulas not cached; using computed expectations.\n');
end

all_pass = true;
fields = [ ...
    "tdp_per_chip_w", ...
    "chips_per_server", ...
    "server_power_kw", ...
    "max_junction_temp_c", ...
    "recommended_coolant_inlet_c", ...
    "heat_capture_rate_pct", ...
    "capture_temperature_c", ...
    "coolant_type", ...
    "pue_contribution", ...
    "capex_premium_vs_air_cooled_pct", ...
    "rack_thermal_limit_kw_per_rack", ...
    "servers_per_rack", ...
    "gpus_per_rack", ...
    "actual_rack_power_kw", ...
    "rack_thermal_utilisation_pct", ...
    "racks_per_module", ...
    "servers_per_module", ...
    "gpus_per_module", ...
    "actual_module_it_capacity_kw", ...
    "captured_heat_kwth", ...
    "capture_temperature_c__b44", ...
    "residual_heat_to_air_kwth", ...
    "heat_capture_quality", ...
    "heat_pump_requirement", ...
    "recommended_hp_output_c", ...
    "estimated_cop_at_recommended_output", ...
    "target_output_temperature_c", ...
    "temperature_lift_k", ...
    "cop_at_this_lift", ...
    "hp_electricity_per_kwth_captured", ...
    "total_heat_output_per_kw_it", ...
    "hp_electricity_cost_gbp_per_kwth_hr", ...
    "heat_delivered_mwh_per_yr", ...
    "hp_electricity_mwh_per_yr", ...
    "hp_electricity_cost_gbp_per_yr" ...
    ];

for i = 1:numel(fields)
    field = fields(i);
    all_pass = checkEqual(field, rp.(field), expected.(field)) && all_pass;
end

all_pass = runAlternateTests(all_pass, fields);

if all_pass
    fprintf('Rack profile validation: PASS\n');
else
    fprintf('Rack profile validation: FAIL\n');
end
end

function [chipset, cooling_method, module_it_target, electricity_price, annual_hours] = readInputs(excel_path)
inputs = readExcelRange(excel_path, '0. Rack Profile', 'B6:B70');
chipset = inputs{1};
cooling_method = inputs{12};
module_it_target = inputs{31};
electricity_price = inputs{53};
annual_hours = inputs{62};
end

function expected = calcExpected(chipset, cooling_method, module_it_target, electricity_price, annual_hours)
ref = tribe.data.ReferenceData();

expected = struct();
expected.chipset_type = string(chipset);
expected.cooling_method = string(cooling_method);
expected.module_it_capacity_target_kw = module_it_target;
expected.electricity_price_gbp_per_kwh = electricity_price;
expected.annual_operating_hours = annual_hours;

[tdp_per_chip_w, chips_per_server, max_junction_temp_c] = lookupChipset(expected.chipset_type, ref);
expected.tdp_per_chip_w = tdp_per_chip_w;
expected.chips_per_server = chips_per_server;
expected.server_power_kw = expected.tdp_per_chip_w * expected.chips_per_server / 1000 * 1.15;
expected.max_junction_temp_c = max_junction_temp_c;
expected.recommended_coolant_inlet_c = expected.max_junction_temp_c - 25;

[heat_capture_rate_pct, capture_temperature_c, coolant_type, pue_contribution, ...
    capex_premium_vs_air_cooled_pct, rack_thermal_limit_kw_per_rack] = lookupCooling(expected.cooling_method, ref);
expected.heat_capture_rate_pct = heat_capture_rate_pct;
expected.capture_temperature_c = capture_temperature_c;
expected.coolant_type = coolant_type;
expected.pue_contribution = pue_contribution;
expected.capex_premium_vs_air_cooled_pct = capex_premium_vs_air_cooled_pct;
expected.rack_thermal_limit_kw_per_rack = rack_thermal_limit_kw_per_rack;

expected.servers_per_rack = floor(expected.rack_thermal_limit_kw_per_rack / expected.server_power_kw);
expected.gpus_per_rack = expected.servers_per_rack * expected.chips_per_server;
expected.actual_rack_power_kw = expected.servers_per_rack * expected.server_power_kw;
expected.rack_thermal_utilisation_pct = expected.actual_rack_power_kw / expected.rack_thermal_limit_kw_per_rack;

expected.racks_per_module = ceil(expected.module_it_capacity_target_kw / expected.actual_rack_power_kw);
expected.servers_per_module = expected.racks_per_module * expected.servers_per_rack;
expected.gpus_per_module = expected.racks_per_module * expected.gpus_per_rack;
expected.actual_module_it_capacity_kw = expected.racks_per_module * expected.actual_rack_power_kw;

expected.captured_heat_kwth = expected.actual_module_it_capacity_kw * expected.heat_capture_rate_pct;
expected.capture_temperature_c__b44 = expected.capture_temperature_c;
expected.residual_heat_to_air_kwth = expected.actual_module_it_capacity_kw * (1 - expected.heat_capture_rate_pct);

if expected.capture_temperature_c >= 55
    expected.heat_capture_quality = "HIGH - Suitable for process heat";
elseif expected.capture_temperature_c >= 45
    expected.heat_capture_quality = "MEDIUM - District heating suitable";
else
    expected.heat_capture_quality = "LOW - Limited applications";
end

if expected.capture_temperature_c >= 70
    expected.heat_pump_requirement = "Optional - direct use possible";
elseif expected.capture_temperature_c >= 50
    expected.heat_pump_requirement = "Recommended for industrial use";
else
    expected.heat_pump_requirement = "Required for most applications";
end

if expected.capture_temperature_c >= 70
    expected.recommended_hp_output_c = expected.capture_temperature_c;
elseif expected.capture_temperature_c >= 50
    expected.recommended_hp_output_c = 90;
else
    expected.recommended_hp_output_c = 80;
end

if expected.heat_pump_requirement == "Optional - direct use possible"
    expected.estimated_cop_at_recommended_output = "-";
else
    cop_raw = round(ref.carnot_efficiency_factor * (expected.recommended_hp_output_c + 273.15) ...
        / (expected.recommended_hp_output_c - expected.capture_temperature_c), 2);
    expected.estimated_cop_at_recommended_output = boundCop(cop_raw, ref);
end

expected.target_output_temperature_c = expected.recommended_hp_output_c;
expected.temperature_lift_k = expected.target_output_temperature_c - expected.capture_temperature_c;

cop_at_lift = NaN;
if expected.temperature_lift_k > 0
    cop_raw = round(ref.carnot_efficiency_factor * (expected.target_output_temperature_c + 273.15) ...
        / expected.temperature_lift_k, 2);
    cop_at_lift = boundCop(cop_raw, ref);
end

if isnan(cop_at_lift)
    expected.cop_at_this_lift = "-";
    expected.hp_electricity_per_kwth_captured = "-";
    expected.total_heat_output_per_kw_it = expected.heat_capture_rate_pct;
    expected.hp_electricity_cost_gbp_per_kwth_hr = "-";
else
    expected.cop_at_this_lift = cop_at_lift;
    expected.hp_electricity_per_kwth_captured = round(1 / (expected.cop_at_this_lift - 1), 3);
    expected.total_heat_output_per_kw_it = round(expected.heat_capture_rate_pct * expected.cop_at_this_lift ...
        / (expected.cop_at_this_lift - 1), 3);
    expected.hp_electricity_cost_gbp_per_kwth_hr = round( ...
        expected.hp_electricity_per_kwth_captured * expected.electricity_price_gbp_per_kwh, 4);
end

expected.heat_delivered_mwh_per_yr = round( ...
    expected.actual_module_it_capacity_kw * expected.total_heat_output_per_kw_it ...
    * expected.annual_operating_hours / 1000, 0);

if ischar(expected.hp_electricity_per_kwth_captured) || (isstring(expected.hp_electricity_per_kwth_captured) ...
        && expected.hp_electricity_per_kwth_captured == "-")
    expected.hp_electricity_mwh_per_yr = 0;
else
    expected.hp_electricity_mwh_per_yr = round( ...
        expected.captured_heat_kwth * expected.hp_electricity_per_kwth_captured ...
        * expected.annual_operating_hours / 1000, 0);
end

expected.hp_electricity_cost_gbp_per_yr = expected.hp_electricity_mwh_per_yr * 1000 ...
    * expected.electricity_price_gbp_per_kwh;
end

function [expected, has_excel_values] = readExcelExpected(excel_path)
data = readExcelRange(excel_path, '0. Rack Profile', 'B6:B70');
getCell = @(row) data{row - 5, 1};

sentinel_rows = [9, 11, 20, 31, 37, 40, 43, 60, 61, 68, 69, 70];
has_excel_values = false;
for i = 1:numel(sentinel_rows)
    value = getCell(sentinel_rows(i));
    if isFormulaValue(value) || ismissingValue(value)
        continue;
    end
    if isnumeric(value)
        if any(~isnan(value), 'all') && any(abs(value) > 0, 'all')
            has_excel_values = true;
            break;
        end
    elseif (isstring(value) || ischar(value)) && strlength(string(value)) > 0
        has_excel_values = true;
        break;
    end
end

expected = struct();
if ~has_excel_values
    return;
end

mapping = struct( ...
    'tdp_per_chip_w', 9, ...
    'chips_per_server', 10, ...
    'server_power_kw', 11, ...
    'max_junction_temp_c', 12, ...
    'recommended_coolant_inlet_c', 13, ...
    'heat_capture_rate_pct', 20, ...
    'capture_temperature_c', 21, ...
    'coolant_type', 22, ...
    'pue_contribution', 23, ...
    'capex_premium_vs_air_cooled_pct', 24, ...
    'rack_thermal_limit_kw_per_rack', 25, ...
    'servers_per_rack', 29, ...
    'gpus_per_rack', 30, ...
    'actual_rack_power_kw', 31, ...
    'rack_thermal_utilisation_pct', 32, ...
    'racks_per_module', 37, ...
    'servers_per_module', 38, ...
    'gpus_per_module', 39, ...
    'actual_module_it_capacity_kw', 40, ...
    'captured_heat_kwth', 43, ...
    'capture_temperature_c__b44', 44, ...
    'residual_heat_to_air_kwth', 45, ...
    'heat_capture_quality', 49, ...
    'heat_pump_requirement', 50, ...
    'recommended_hp_output_c', 51, ...
    'estimated_cop_at_recommended_output', 52, ...
    'target_output_temperature_c', 57, ...
    'temperature_lift_k', 60, ...
    'cop_at_this_lift', 61, ...
    'hp_electricity_per_kwth_captured', 62, ...
    'total_heat_output_per_kw_it', 63, ...
    'hp_electricity_cost_gbp_per_kwth_hr', 64, ...
    'heat_delivered_mwh_per_yr', 68, ...
    'hp_electricity_mwh_per_yr', 69, ...
    'hp_electricity_cost_gbp_per_yr', 70 ...
    );

fields = fieldnames(mapping);
for i = 1:numel(fields)
    field = fields{i};
    row = mapping.(field);
    value = getCell(row);
    if isFormulaValue(value) || ismissingValue(value)
        continue;
    end
    expected.(field) = value;
end
end

function expected = mergeExpected(expected, excel_expected)
fields = fieldnames(excel_expected);
for i = 1:numel(fields)
    field = fields{i};
    expected.(field) = excel_expected.(field);
end
end

function ok = runAlternateTests(all_pass, fields)
alt_cases = { ...
    struct('chipset', "NVIDIA H200", 'cooling', "Single-Phase Immersion", 'it_target', 300, ...
           'electricity', 0.20, 'hours', 7500), ...
    struct('chipset', "AMD MI300X", 'cooling', "Two-Phase Immersion", 'it_target', 200, ...
           'electricity', 0.15, 'hours', 8500) ...
    };

for i = 1:numel(alt_cases)
    cfg = alt_cases{i};
    rp = tribe.calc.calcRackProfile(cfg.chipset, cfg.cooling, cfg.it_target, cfg.electricity, cfg.hours);
    expected = calcExpected(cfg.chipset, cfg.cooling, cfg.it_target, cfg.electricity, cfg.hours);
    for j = 1:numel(fields)
        field = fields(j);
        all_pass = checkEqual("alt." + string(i) + "." + field, ...
            rp.(field), expected.(field)) && all_pass;
    end
end
ok = all_pass;
end

function ok = checkEqual(label, expected, actual)
if isstring(expected) || ischar(expected)
    ok = isequal(string(expected), string(actual));
elseif isnumeric(expected)
    ok = isnumeric(actual) && isequal(size(expected), size(actual)) ...
        && all(abs(expected - actual) < 1e-9, 'all');
else
    ok = isequaln(expected, actual);
end

if ok
    fprintf('PASS: %s\n', label);
else
    fprintf('FAIL: %s | expected: %s | actual: %s\n', label, valueToString(expected), valueToString(actual));
end
end

function data = readExcelRange(excel_path, sheet, range)
try
    data = readcell(excel_path, 'Sheet', sheet, 'Range', range, 'UseExcel', true);
catch
    data = readcell(excel_path, 'Sheet', sheet, 'Range', range);
end
end

function tf = isFormulaValue(value)
tf = (ischar(value) || isstring(value)) && startsWith(string(value), "=");
end

function tf = ismissingValue(value)
tf = isempty(value) ...
    || (isstring(value) && all(ismissing(value))) ...
    || (isnumeric(value) && any(isnan(value), 'all'));
end

function [tdp_per_chip_w, chips_per_server, max_junction_temp_c] = lookupChipset(chipset_name, ref)
idx = find(ref.chipsets.name == chipset_name, 1);
if isempty(idx)
    tdp_per_chip_w = 500;
    chips_per_server = 8;
    max_junction_temp_c = 85;
    return;
end
tdp_per_chip_w = ref.chipsets.tdp_per_chip_w(idx);
chips_per_server = ref.chipsets.chips_per_server(idx);
max_junction_temp_c = ref.chipsets.t_junction_c(idx);
end

function [heat_capture_rate_pct, capture_temperature_c, coolant_type, pue_contribution, ...
    capex_premium_vs_air_cooled_pct, rack_thermal_limit_kw_per_rack] = lookupCooling(cooling_name, ref)
idx = find(ref.cooling_methods.name == cooling_name, 1);
if isempty(idx)
    heat_capture_rate_pct = 0.05;
    capture_temperature_c = 35;
    capex_premium_vs_air_cooled_pct = 0;
else
    heat_capture_rate_pct = ref.cooling_methods.heat_capture_rate_pct(idx);
    capture_temperature_c = ref.cooling_methods.capture_temperature_c(idx);
    capex_premium_vs_air_cooled_pct = ref.cooling_methods.capex_premium_pct(idx);
end

switch cooling_name
    case "Direct-to-Chip (DTC)"
        coolant_type = "Water/Glycol";
        pue_contribution = 1.05;
        rack_thermal_limit_kw_per_rack = 80;
    case "Single-Phase Immersion"
        coolant_type = "Dielectric fluid";
        pue_contribution = 1.03;
        rack_thermal_limit_kw_per_rack = 100;
    case "Two-Phase Immersion"
        coolant_type = "Fluorocarbon";
        pue_contribution = 1.02;
        rack_thermal_limit_kw_per_rack = 120;
    case "Rear Door Heat Exchanger"
        coolant_type = "Water/Glycol";
        pue_contribution = 1.1;
        rack_thermal_limit_kw_per_rack = 40;
    otherwise
        coolant_type = "Air";
        pue_contribution = 1.4;
        rack_thermal_limit_kw_per_rack = 20;
end
end

function cop = boundCop(cop_raw, ref)
cop = max(ref.minimum_practical_cop, min(ref.maximum_practical_cop, cop_raw));
end

function text = valueToString(value)
if isstring(value) || ischar(value)
    text = char(string(value));
elseif isnumeric(value)
    text = mat2str(value);
else
    text = '<unprintable>';
end
end
