function rp = calcRackProfile(chipset, cooling_method, module_it_target, electricity_price, annual_hours)
%CALCRACKPROFILE Compute rack profile values from the Excel model.

ref = tribe.data.ReferenceData();

rp = struct();
rp.chipset_type = string(chipset);
rp.cooling_method = string(cooling_method);
rp.module_it_capacity_target_kw = module_it_target;
rp.electricity_price_gbp_per_kwh = electricity_price;
rp.annual_operating_hours = annual_hours;

[tdp_per_chip_w, chips_per_server, max_junction_temp_c] = lookupChipset(rp.chipset_type, ref);
rp.tdp_per_chip_w = tdp_per_chip_w;
rp.chips_per_server = chips_per_server;
rp.server_power_kw = rp.tdp_per_chip_w * rp.chips_per_server / 1000 * 1.15;
rp.max_junction_temp_c = max_junction_temp_c;
rp.recommended_coolant_inlet_c = rp.max_junction_temp_c - 25;

[heat_capture_rate_pct, capture_temperature_c, coolant_type, pue_contribution, ...
    capex_premium_vs_air_cooled_pct, rack_thermal_limit_kw_per_rack] = lookupCooling(rp.cooling_method, ref);
rp.heat_capture_rate_pct = heat_capture_rate_pct;
rp.capture_temperature_c = capture_temperature_c;
rp.coolant_type = coolant_type;
rp.pue_contribution = pue_contribution;
rp.capex_premium_vs_air_cooled_pct = capex_premium_vs_air_cooled_pct;
rp.rack_thermal_limit_kw_per_rack = rack_thermal_limit_kw_per_rack;

rp.servers_per_rack = floor(rp.rack_thermal_limit_kw_per_rack / rp.server_power_kw);
rp.gpus_per_rack = rp.servers_per_rack * rp.chips_per_server;
rp.actual_rack_power_kw = rp.servers_per_rack * rp.server_power_kw;
rp.rack_thermal_utilisation_pct = rp.actual_rack_power_kw / rp.rack_thermal_limit_kw_per_rack;

rp.racks_per_module = ceil(rp.module_it_capacity_target_kw / rp.actual_rack_power_kw);
rp.servers_per_module = rp.racks_per_module * rp.servers_per_rack;
rp.gpus_per_module = rp.racks_per_module * rp.gpus_per_rack;
rp.actual_module_it_capacity_kw = rp.racks_per_module * rp.actual_rack_power_kw;

rp.captured_heat_kwth = rp.actual_module_it_capacity_kw * rp.heat_capture_rate_pct;
rp.capture_temperature_c__b44 = rp.capture_temperature_c;
rp.residual_heat_to_air_kwth = rp.actual_module_it_capacity_kw * (1 - rp.heat_capture_rate_pct);

if rp.capture_temperature_c >= 55
    rp.heat_capture_quality = "HIGH - Suitable for process heat";
elseif rp.capture_temperature_c >= 45
    rp.heat_capture_quality = "MEDIUM - District heating suitable";
else
    rp.heat_capture_quality = "LOW - Limited applications";
end

if rp.capture_temperature_c >= 70
    rp.heat_pump_requirement = "Optional - direct use possible";
elseif rp.capture_temperature_c >= 50
    rp.heat_pump_requirement = "Recommended for industrial use";
else
    rp.heat_pump_requirement = "Required for most applications";
end

if rp.capture_temperature_c >= 70
    rp.recommended_hp_output_c = rp.capture_temperature_c;
elseif rp.capture_temperature_c >= 50
    rp.recommended_hp_output_c = 90;
else
    rp.recommended_hp_output_c = 80;
end

if rp.heat_pump_requirement == "Optional - direct use possible"
    rp.estimated_cop_at_recommended_output = "-";
else
    cop_raw = round(ref.carnot_efficiency_factor * (rp.recommended_hp_output_c + 273.15) ...
        / (rp.recommended_hp_output_c - rp.capture_temperature_c), 2);
    rp.estimated_cop_at_recommended_output = boundCop(cop_raw, ref);
end

rp.target_output_temperature_c = rp.recommended_hp_output_c;
rp.temperature_lift_k = rp.target_output_temperature_c - rp.capture_temperature_c;

cop_at_lift = NaN;
if rp.temperature_lift_k > 0
    cop_raw = round(ref.carnot_efficiency_factor * (rp.target_output_temperature_c + 273.15) ...
        / rp.temperature_lift_k, 2);
    cop_at_lift = boundCop(cop_raw, ref);
end

if isnan(cop_at_lift)
    rp.cop_at_this_lift = "-";
    rp.hp_electricity_per_kwth_captured = "-";
    rp.total_heat_output_per_kw_it = rp.heat_capture_rate_pct;
    rp.hp_electricity_cost_gbp_per_kwth_hr = "-";
else
    rp.cop_at_this_lift = cop_at_lift;
    rp.hp_electricity_per_kwth_captured = round(1 / (rp.cop_at_this_lift - 1), 3);
    rp.total_heat_output_per_kw_it = round(rp.heat_capture_rate_pct * rp.cop_at_this_lift ...
        / (rp.cop_at_this_lift - 1), 3);
    rp.hp_electricity_cost_gbp_per_kwth_hr = round( ...
        rp.hp_electricity_per_kwth_captured * rp.electricity_price_gbp_per_kwh, 4);
end

rp.heat_delivered_mwh_per_yr = round( ...
    rp.actual_module_it_capacity_kw * rp.total_heat_output_per_kw_it * rp.annual_operating_hours / 1000, 0);

if ischar(rp.hp_electricity_per_kwth_captured) || (isstring(rp.hp_electricity_per_kwth_captured) ...
        && rp.hp_electricity_per_kwth_captured == "-")
    rp.hp_electricity_mwh_per_yr = 0;
else
    rp.hp_electricity_mwh_per_yr = round( ...
        rp.captured_heat_kwth * rp.hp_electricity_per_kwth_captured * rp.annual_operating_hours / 1000, 0);
end

rp.hp_electricity_cost_gbp_per_yr = rp.hp_electricity_mwh_per_yr * 1000 * rp.electricity_price_gbp_per_kwh;
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
