function bp = calcBuyerProfile(rp, mc, mflow, process_id, ref)
%CALCBUYERPROFILE Compute buyer profile values from the Excel model.

if nargin < 5 || isempty(ref)
    ref = tribe.data.ReferenceData();
end

bp = struct();
bp.chipset = string(rp.chipset_type);
bp.cooling_method = string(rp.cooling_method);
bp.gpus_per_module = rp.gpus_per_module;
bp.module_it_capacity_kw = rp.actual_module_it_capacity_kw;
bp.select_process = string(process_id);

process = defaultProcess();
if ~isempty(process_id)
    try
        process = tribe.data.ProcessLibrary.getProcess(process_id);
    catch
        process = defaultProcess();
    end
end

bp.process_name = string(process.name);
bp.size_category = string(process.size_category);
bp.required_temperature_c = process.required_temp_c;
bp.heat_demand_kwth = process.heat_demand_kwth;
bp.operating_hours_per_year = process.operating_hours_per_year;
bp.notes = string(process.notes);
bp.source = string(process.source);
bp.source_url = string(process.source_url);

bp.annual_heat_demand_mwh = bp.heat_demand_kwth * bp.operating_hours_per_year / 1000;
bp.process_deltat_c = process.delta_t_c;
bp.required_flow_rate_m3_per_hr = bp.heat_demand_kwth / (4.18 * bp.process_deltat_c) * 3.6;

bp.module_thermal_capacity_kwth = mc.thermal_output_kwth;
bp.module_delivery_temp_c = mc.delivery_temperature_c;
bp.module_flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;

if bp.module_delivery_temp_c >= bp.required_temperature_c
    bp.temperature_compatible = "YES";
else
    bp.temperature_compatible = "NO - need higher temp";
end

bp.modules_needed_thermal = roundup(bp.heat_demand_kwth / bp.module_thermal_capacity_kwth, 0);
bp.modules_if_flow_constrained_reference = roundup( ...
    bp.required_flow_rate_m3_per_hr / bp.module_flow_capacity_m3_per_hr, 0);
bp.modules_required = bp.modules_needed_thermal;

bp.flow_deficit_m3_per_hr = max(0, bp.required_flow_rate_m3_per_hr ...
    - bp.modules_required * bp.module_flow_capacity_m3_per_hr);

denom_flow = bp.modules_required * bp.module_flow_capacity_m3_per_hr;
if denom_flow > 0
    bp.flow_ratio_buyer_per_system = bp.required_flow_rate_m3_per_hr / denom_flow;
else
    bp.flow_ratio_buyer_per_system = 0;
end

bp.system_thermal_capacity_kwth = bp.modules_required * bp.module_thermal_capacity_kwth;
bp.system_flow_capacity_m3_per_hr = bp.modules_required * bp.module_flow_capacity_m3_per_hr;
bp.thermal_utilisation_pct = bp.heat_demand_kwth / bp.system_thermal_capacity_kwth;

bp.flow_augmentation_pump_m3_per_hr = bp.flow_deficit_m3_per_hr;
if bp.flow_deficit_m3_per_hr > 0
    bp.mixing_valve_required = "YES";
else
    bp.mixing_valve_required = "NO";
end

if bp.flow_deficit_m3_per_hr > 0
    bp.augmentation_pumps_required = roundup( ...
        bp.flow_deficit_m3_per_hr / ref.standard_augmentation_pump_capacity_m3_per_hr, 0);
else
    bp.augmentation_pumps_required = 0;
end

bp.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pumps_required ...
    * ref.standard_augmentation_pump_capacity_m3_per_hr;
bp.augmentation_pump_power_kw = bp.augmentation_pump_capacity_m3_per_hr ...
    * ref.augmentation_pump_power_kw_per_m3_per_hr;
bp.augmented_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr ...
    + bp.augmentation_pump_capacity_m3_per_hr;

if bp.augmented_system_flow_m3_per_hr > 0
    bp.flow_utilisation_pct = bp.required_flow_rate_m3_per_hr / bp.augmented_system_flow_m3_per_hr;
else
    bp.flow_utilisation_pct = bp.required_flow_rate_m3_per_hr / bp.system_flow_capacity_m3_per_hr;
end

if bp.flow_ratio_buyer_per_system > 1
    bp.hydraulic_augmentation_needed = "YES - flow ratio " ...
        + string(round(bp.flow_ratio_buyer_per_system, 2)) + "x";
else
    bp.hydraulic_augmentation_needed = "NO";
end

bp.system_heat_generation_kwth = bp.system_thermal_capacity_kwth;
bp.buyer_heat_absorption_kwth = min(bp.heat_demand_kwth, bp.system_thermal_capacity_kwth);
bp.excess_heat_kwth = max(0, bp.system_heat_generation_kwth - bp.buyer_heat_absorption_kwth);
if bp.system_heat_generation_kwth > 0
    bp.excess_heat_pct = bp.excess_heat_kwth / bp.system_heat_generation_kwth;
else
    bp.excess_heat_pct = 0;
end

if bp.excess_heat_kwth > 0
    bp.heat_rejection_required = "YES - " + string(round(bp.excess_heat_kwth, 0)) ...
        + " kWth rejection needed";
else
    bp.heat_rejection_required = "NO - full utilisation";
end

if bp.excess_heat_kwth == 0
    bp.rejection_method = "-";
elseif bp.excess_heat_kwth < ref.dry_cooler_max_kwth
    bp.rejection_method = "Dry cooler";
elseif bp.excess_heat_kwth < ref.adiabatic_cooler_max_kwth
    bp.rejection_method = "Adiabatic cooler";
else
    bp.rejection_method = "Cooling tower";
end

bp.rejection_capacity_required_kwth = bp.excess_heat_kwth;
if bp.rejection_method == "-"
    bp.rejection_capex_rate_gbp_per_kwth = 0;
    bp.rejection_opex_rate_gbp_per_kwth_per_yr = 0;
elseif bp.rejection_method == "Dry cooler"
    bp.rejection_capex_rate_gbp_per_kwth = ref.dry_cooler__capex_gbp_per_kwth;
    bp.rejection_opex_rate_gbp_per_kwth_per_yr = ref.dry_cooler__opex_gbp_per_kwth_per_yr;
elseif bp.rejection_method == "Adiabatic cooler"
    bp.rejection_capex_rate_gbp_per_kwth = ref.adiabatic_cooler__capex_gbp_per_kwth;
    bp.rejection_opex_rate_gbp_per_kwth_per_yr = ref.adiabatic_cooler__opex_gbp_per_kwth_per_yr;
else
    bp.rejection_capex_rate_gbp_per_kwth = ref.cooling_tower__capex_gbp_per_kwth;
    bp.rejection_opex_rate_gbp_per_kwth_per_yr = ref.cooling_tower__opex_gbp_per_kwth_per_yr;
end

bp.rejection_capex_gbp = bp.rejection_capacity_required_kwth ...
    * bp.rejection_capex_rate_gbp_per_kwth;
bp.annual_rejection_opex_gbp_per_yr = bp.rejection_capacity_required_kwth ...
    * bp.rejection_opex_rate_gbp_per_kwth_per_yr;

bp.total_modules_required = bp.modules_required;
bp.total_it_capacity_kw = bp.modules_required * mc.module_it_capacity_kw;
bp.total_rack_units_42u_racks_10kw = roundup(bp.total_it_capacity_kw / 10, 0);

if bp.required_temperature_c > mc.capture_temperature_c
    bp.heat_pump_required = "YES";
    bp.temperature_lift_required_k = bp.required_temperature_c - mc.capture_temperature_c;
else
    bp.heat_pump_required = "NO - direct heat sufficient";
    bp.temperature_lift_required_k = 0;
end

bp.heat_pump_units = bp.modules_required;
bp.total_hp_capacity_kwth = bp.modules_required * mc.heat_pump_capacity_kwth;

if ~isnumber(mc.heat_pump_cop) || mc.heat_pump_cop <= 1
    bp.hp_electrical_demand_kw = 0;
else
    bp.hp_electrical_demand_kw = bp.system_thermal_capacity_kwth / mc.heat_pump_cop;
end

bp.source_loop_pumps = bp.modules_required;
bp.sink_loop_pumps = bp.modules_required;
bp.total_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr;

if bp.system_flow_capacity_m3_per_hr < 10
    bp.header_pipe_size_estimate_dn = "DN50";
elseif bp.system_flow_capacity_m3_per_hr < 25
    bp.header_pipe_size_estimate_dn = "DN65";
elseif bp.system_flow_capacity_m3_per_hr < 50
    bp.header_pipe_size_estimate_dn = "DN80";
elseif bp.system_flow_capacity_m3_per_hr < 100
    bp.header_pipe_size_estimate_dn = "DN100";
else
    bp.header_pipe_size_estimate_dn = "DN125+";
end

if bp.modules_required > 2
    bp.buffer_tank_recommended = "YES - system balancing";
else
    bp.buffer_tank_recommended = "OPTIONAL";
end

flow_shortfall_m3_per_hr = bp.required_flow_rate_m3_per_hr - bp.augmented_system_flow_m3_per_hr;
m3_symbol = char(179);
if bp.augmented_system_flow_m3_per_hr >= bp.required_flow_rate_m3_per_hr
    bp.flow_requirement_met = "YES";
else
    bp.flow_requirement_met = "NO - shortfall of " + string(round(flow_shortfall_m3_per_hr, 1)) ...
        + " m" + string(m3_symbol) + "/hr";
end

bp.it_load_kw = bp.total_it_capacity_kw;
bp.cooling_infrastructure_kw = bp.total_it_capacity_kw * mc.target_utilisation_rate_pct * 0.05;
bp.heat_pump_load_kw = bp.hp_electrical_demand_kw;
bp.total_electrical_demand_kw = bp.it_load_kw + bp.cooling_infrastructure_kw + bp.heat_pump_load_kw;
bp.grid_connection_kva_0_9_pf = roundup(bp.total_electrical_demand_kw / 0.9, -1);

bp.module_footprint_each_m = 15;
bp.total_module_footprint_m = bp.modules_required * bp.module_footprint_each_m;
if bp.modules_required > 2
    bp.plant_room_allowance_m = 25;
else
    bp.plant_room_allowance_m = 15;
end
bp.total_site_area_m = bp.total_module_footprint_m + bp.plant_room_allowance_m;

bp.modular_dc_units_250kw_it = bp.modules_required;
bp.heat_pump_units__b108 = bp.heat_pump_units;
bp.server_racks_42u = bp.total_rack_units_42u_racks_10kw;
bp.source_circulation_pumps = bp.source_loop_pumps;
bp.sink_circulation_pumps = bp.sink_loop_pumps;
bp.plate_heat_exchangers = bp.modules_required;
if bp.buffer_tank_recommended == "YES - system balancing"
    bp.buffer_tank = 1;
else
    bp.buffer_tank = 0;
end
bp.bms_per_controls_package = 1;
bp.flow_augmentation_pumps = bp.augmentation_pumps_required;
if bp.augmentation_pumps_required > 0
    bp.mixing_valves = 1;
else
    bp.mixing_valves = 0;
end
end

function process = defaultProcess()
process = struct( ...
    'name', "-", ...
    'size_category', "-", ...
    'required_temp_c', 0, ...
    'heat_demand_kwth', 0, ...
    'operating_hours_per_year', 0, ...
    'notes', "-", ...
    'source', "", ...
    'delta_t_c', 10, ...
    'source_url', "" ...
);
end

function tf = isnumber(value)
tf = isnumeric(value) && isscalar(value) && ~isnan(value);
end

function y = roundup(x, digits)
if nargin < 2
    digits = 0;
end
factor = 10.^digits;
y = sign(x) .* ceil(abs(x) .* factor) ./ factor;
end
