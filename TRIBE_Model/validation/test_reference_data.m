function test_reference_data()
%TEST_REFERENCE_DATA Validate reference data against the Excel workbook.

validation_dir = fileparts(mfilename('fullpath'));
model_root = fileparts(validation_dir);
repo_root = fileparts(model_root);
excel_path = fullfile(repo_root, 'Tribe_model_20.1.26.xlsx');

addpath(model_root);

ref = tribe.data.ReferenceData();
all_pass = true;

% Heat rejection infrastructure.
rejection = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A10:E12');
actual_methods = string(rejection(:, 1));
actual_ranges = string(rejection(:, 2));
actual_capex = cell2mat(rejection(:, 3));
actual_opex = cell2mat(rejection(:, 4));
actual_notes = string(rejection(:, 5));

all_pass = checkEqual('heat_rejection.method', ref.heat_rejection_infrastructure.method, actual_methods) && all_pass;
all_pass = checkEqual('heat_rejection.capacity_range', ref.heat_rejection_infrastructure.capacity_range, actual_ranges) && all_pass;
all_pass = checkEqual('heat_rejection.capex_gbp_per_kwth', ref.heat_rejection_infrastructure.capex_gbp_per_kwth, actual_capex) && all_pass;
all_pass = checkEqual('heat_rejection.opex_gbp_per_kwth_per_yr', ref.heat_rejection_infrastructure.opex_gbp_per_kwth_per_yr, actual_opex) && all_pass;
all_pass = checkEqual('heat_rejection.notes', ref.heat_rejection_infrastructure.notes, actual_notes) && all_pass;

thresholds = cell2mat(readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'B15:B16'));
all_pass = checkEqual('dry_cooler_max_kwth', ref.dry_cooler_max_kwth, thresholds(1)) && all_pass;
all_pass = checkEqual('adiabatic_cooler_max_kwth', ref.adiabatic_cooler_max_kwth, thresholds(2)) && all_pass;

all_pass = checkEqual('dry_cooler__capex_gbp_per_kwth', ref.dry_cooler__capex_gbp_per_kwth, actual_capex(1)) && all_pass;
all_pass = checkEqual('adiabatic_cooler__capex_gbp_per_kwth', ref.adiabatic_cooler__capex_gbp_per_kwth, actual_capex(2)) && all_pass;
all_pass = checkEqual('cooling_tower__capex_gbp_per_kwth', ref.cooling_tower__capex_gbp_per_kwth, actual_capex(3)) && all_pass;
all_pass = checkEqual('dry_cooler__opex_gbp_per_kwth_per_yr', ref.dry_cooler__opex_gbp_per_kwth_per_yr, actual_opex(1)) && all_pass;
all_pass = checkEqual('adiabatic_cooler__opex_gbp_per_kwth_per_yr', ref.adiabatic_cooler__opex_gbp_per_kwth_per_yr, actual_opex(2)) && all_pass;
all_pass = checkEqual('cooling_tower__opex_gbp_per_kwth_per_yr', ref.cooling_tower__opex_gbp_per_kwth_per_yr, actual_opex(3)) && all_pass;

% Cooling method characteristics.
cooling = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A23:E27');
actual_cooling_names = string(cooling(:, 1));
actual_heat_capture = cellfun(@(x) parsePercent(x, true), cooling(:, 2));
actual_capture_temp = cellfun(@parseTemp, cooling(:, 3));
actual_capex_premium = cellfun(@(x) parsePercent(x, false), cooling(:, 4));
actual_source_deltat = cell2mat(cooling(:, 5));

all_pass = checkEqual('cooling_methods.name', ref.cooling_methods.name, actual_cooling_names) && all_pass;
all_pass = checkEqual('cooling_methods.heat_capture_rate_pct', ref.cooling_methods.heat_capture_rate_pct, actual_heat_capture) && all_pass;
all_pass = checkEqual('cooling_methods.capture_temperature_c', ref.cooling_methods.capture_temperature_c, actual_capture_temp) && all_pass;
all_pass = checkEqual('cooling_methods.capex_premium_pct', ref.cooling_methods.capex_premium_pct, actual_capex_premium) && all_pass;
all_pass = checkEqual('cooling_methods.source_deltat_c', ref.cooling_methods.source_deltat_c, actual_source_deltat) && all_pass;

all_pass = checkEqual('direct_to_chip_dtc__source_deltat_c', ref.direct_to_chip_dtc__source_deltat_c, actual_source_deltat(1)) && all_pass;
all_pass = checkEqual('single_phase_immersion__source_deltat_c', ref.single_phase_immersion__source_deltat_c, actual_source_deltat(2)) && all_pass;
all_pass = checkEqual('two_phase_immersion__source_deltat_c', ref.two_phase_immersion__source_deltat_c, actual_source_deltat(3)) && all_pass;
all_pass = checkEqual('rear_door_heat_exchanger__source_deltat_c', ref.rear_door_heat_exchanger__source_deltat_c, actual_source_deltat(4)) && all_pass;
all_pass = checkEqual('air_cooled_reference__source_deltat_c', ref.air_cooled_reference__source_deltat_c, actual_source_deltat(5)) && all_pass;

% Chipset specifications.
chipsets = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A34:E38');
actual_chipset_names = string(chipsets(:, 1));
actual_tdp = cell2mat(chipsets(:, 2));
actual_chips_per_server = cell2mat(chipsets(:, 3));
actual_t_junction = cell2mat(chipsets(:, 4));
actual_chipset_notes = string(chipsets(:, 5));

all_pass = checkEqual('chipsets.name', ref.chipsets.name, actual_chipset_names) && all_pass;
all_pass = checkEqual('chipsets.tdp_per_chip_w', ref.chipsets.tdp_per_chip_w, actual_tdp) && all_pass;
all_pass = checkEqual('chipsets.chips_per_server', ref.chipsets.chips_per_server, actual_chips_per_server) && all_pass;
all_pass = checkEqual('chipsets.t_junction_c', ref.chipsets.t_junction_c, actual_t_junction) && all_pass;
all_pass = checkEqual('chipsets.notes', ref.chipsets.notes, actual_chipset_notes) && all_pass;

% Heat pump parameters and reference table.
ref_data = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'B110:B112');
actual_carnot = ref_data{1};
actual_min_cop = ref_data{2};
actual_max_cop = ref_data{3};

all_pass = checkEqual('carnot_efficiency_factor', ref.carnot_efficiency_factor, actual_carnot) && all_pass;
all_pass = checkEqual('minimum_practical_cop', ref.minimum_practical_cop, actual_min_cop) && all_pass;
all_pass = checkEqual('maximum_practical_cop', ref.maximum_practical_cop, actual_max_cop) && all_pass;

actual_target_temp = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'B44');
actual_target_temp = actual_target_temp{1};
all_pass = checkEqual('target_delivery_temp_c', ref.target_delivery_temp_c, actual_target_temp) && all_pass;

source_temps = cell2mat(readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A47:A50'));
expected_lift = actual_target_temp - source_temps;
expected_cop = round(actual_carnot * (actual_target_temp + 273.15) ./ expected_lift, 1);
expected_kwe = round(1 ./ expected_cop, 3);

all_pass = checkEqual('hp_reference_source_temp_c', ref.hp_reference_source_temp_c, source_temps) && all_pass;
all_pass = checkEqual('hp_reference_temperature_lift_c', ref.hp_reference_temperature_lift_c, expected_lift) && all_pass;
all_pass = checkEqual('hp_reference_cop', ref.hp_reference_cop, expected_cop) && all_pass;
all_pass = checkEqual('hp_reference_kwe_per_kwth', ref.hp_reference_kwe_per_kwth, expected_kwe) && all_pass;

% Module hardware capex rates.
capex_rows = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A71:B105');
label_map = containers.Map({ ...
    'Container shell (40ft)', ...
    'Container fit-out (electrical, HVAC prep)', ...
    'Rack enclosure (42U enclosed)', ...
    'Cold plate kit (per server)', ...
    'CDU (Coolant Distribution Unit)', ...
    'CDU capacity scaling', ...
    'Manifolds & quick-connects', ...
    'Primary loop piping', ...
    'Single-phase immersion tank', ...
    'Two-phase immersion tank', ...
    'Dielectric fluid - single-phase', ...
    'Dielectric fluid - two-phase', ...
    'Fluid volume per rack (single-phase)', ...
    'Fluid volume per rack (two-phase)', ...
    'Fluid management system', ...
    'High-density PDU (per rack)', ...
    'Module power distribution', ...
    'Electrical panels & switchgear', ...
    'Primary heat exchanger', ...
    'Heat exchanger scaling', ...
    'Thermal integration skid (pumps, valves)', ...
    'Instrumentation & sensors', ...
    'BMS base system', ...
    'Per-rack monitoring', ...
    'Network infrastructure' ...
}, { ...
    'container_shell_40ft', ...
    'container_fit_out_electrical_hvac_prep', ...
    'rack_enclosure_42u_enclosed', ...
    'cold_plate_kit_per_server', ...
    'cdu_coolant_distribution_unit', ...
    'cdu_capacity_scaling', ...
    'manifolds_quick_connects', ...
    'primary_loop_piping', ...
    'single_phase_immersion_tank', ...
    'two_phase_immersion_tank', ...
    'dielectric_fluid_single_phase', ...
    'dielectric_fluid_two_phase', ...
    'fluid_volume_per_rack_single_phase', ...
    'fluid_volume_per_rack_two_phase', ...
    'fluid_management_system', ...
    'high_density_pdu_per_rack', ...
    'module_power_distribution', ...
    'electrical_panels_switchgear', ...
    'primary_heat_exchanger', ...
    'heat_exchanger_scaling', ...
    'thermal_integration_skid_pumps_valves', ...
    'instrumentation_sensors', ...
    'bms_base_system', ...
    'per_rack_monitoring', ...
    'network_infrastructure' ...
});

for i = 1:size(capex_rows, 1)
    label = capex_rows{i, 1};
    value = capex_rows{i, 2};
    label_text = string(label);
    if ismissing(label_text) || strlength(label_text) == 0
        continue;
    end
    label_key = char(label_text);
    if isKey(label_map, label_key)
        field = label_map(label_key);
        all_pass = checkEqual("capex_rate." + string(label_key), ref.(field), value) && all_pass;
    end
end

% Hydraulic augmentation rates.
augmentation = readcell(excel_path, 'Sheet', '11. Reference Data', 'Range', 'A120:B124');
augmentation_fields = [ ...
    "augmentation_pump_capex_gbp_per_m3_per_hr", ...
    "augmentation_pump_power_kw_per_m3_per_hr", ...
    "mixing_valve_controls_gbp", ...
    "pipe_upsizing_allowance_gbp_per_m3_per_hr", ...
    "standard_augmentation_pump_capacity_m3_per_hr" ...
];

for i = 1:numel(augmentation_fields)
    value = augmentation{i, 2};
    field = augmentation_fields(i);
    all_pass = checkEqual("hydraulic_rate." + field, ref.(field), value) && all_pass;
end

% Process library.
process_table = readcell(excel_path, 'Sheet', '12. Process Library', 'Range', 'A4:J45');
processes = tribe.data.ProcessLibrary.all();

all_pass = checkEqual('process_library.name', string({processes.name}).', string(process_table(:, 1))) && all_pass;
all_pass = checkEqual('process_library.size_category', string({processes.size_category}).', string(process_table(:, 2))) && all_pass;
all_pass = checkEqual('process_library.required_temp_c', [processes.required_temp_c].', cell2mat(process_table(:, 3))) && all_pass;
all_pass = checkEqual('process_library.heat_demand_kwth', [processes.heat_demand_kwth].', cell2mat(process_table(:, 4))) && all_pass;
all_pass = checkEqual('process_library.operating_hours_per_year', [processes.operating_hours_per_year].', cell2mat(process_table(:, 5))) && all_pass;
all_pass = checkEqual('process_library.notes', string({processes.notes}).', string(process_table(:, 6))) && all_pass;
all_pass = checkEqual('process_library.dropdown_name', string({processes.dropdown_name}).', string(process_table(:, 7))) && all_pass;
all_pass = checkEqual('process_library.source', string({processes.source}).', string(process_table(:, 8))) && all_pass;
all_pass = checkEqual('process_library.delta_t_c', [processes.delta_t_c].', cell2mat(process_table(:, 9))) && all_pass;
all_pass = checkEqual('process_library.source_url', string({processes.source_url}).', string(process_table(:, 10))) && all_pass;

% Spot-check getProcess lookup.
spot_ids = ["Pasteurisation - Medium", "Bottle washing - Large", "District heating - Small", ...
            "Swimming pool - Medium", "Fermentation - Large"];
for i = 1:numel(spot_ids)
    process = tribe.data.ProcessLibrary.getProcess(spot_ids(i));
    idx = find(string({processes.dropdown_name}) == spot_ids(i), 1);
    expected = rmfield(processes(idx), 'dropdown_name');
    all_pass = checkEqual("getProcess.name." + spot_ids(i), process.name, expected.name) && all_pass;
    all_pass = checkEqual("getProcess.required_temp_c." + spot_ids(i), process.required_temp_c, expected.required_temp_c) && all_pass;
end

if all_pass
    fprintf('Reference data validation: PASS\n');
else
    fprintf('Reference data validation: FAIL\n');
end

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

function value = parsePercent(cellValue, asFraction)
if isnumeric(cellValue)
    value = cellValue;
else
    txt = string(cellValue);
    txt = replace(txt, "%", "");
    txt = replace(txt, "+", "");
    txt = strtrim(txt);
    value = str2double(txt);
end
if asFraction
    value = value / 100;
end
end

function value = parseTemp(cellValue)
if isnumeric(cellValue)
    value = cellValue;
else
    txt = string(cellValue);
    txt = replace(txt, char(176), "");
    txt = replace(txt, "C", "");
    txt = strtrim(txt);
    value = str2double(txt);
end
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
