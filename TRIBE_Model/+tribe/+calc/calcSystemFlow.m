function sflow = calcSystemFlow(mc, bp)
%CALCSYSTEMFLOW Compute system flow values from the Excel model.

sflow = struct();
sflow.chipset = string(bp.chipset);
sflow.cooling_method = string(bp.cooling_method);
sflow.capture_temperature_c = mc.capture_temperature_c;

sflow.selected_buyer_profile = string(bp.select_process);
sflow.modules_in_system = bp.modules_required;

sflow.required_temperature_c = bp.required_temperature_c;
sflow.required_thermal_load_kwth = bp.heat_demand_kwth;
sflow.required_flow_rate_m3_per_hr = bp.required_flow_rate_m3_per_hr;
sflow.annual_heat_demand_mwh = bp.annual_heat_demand_mwh;

sflow.delivery_temperature_c = mc.delivery_temperature_c;
sflow.system_thermal_capacity_kwth = bp.system_thermal_capacity_kwth;
sflow.system_flow_capacity_m3_per_hr = bp.system_flow_capacity_m3_per_hr;
sflow.annual_heat_supply_mwh = sflow.system_thermal_capacity_kwth ...
    * bp.operating_hours_per_year / 1000;

sflow.temperature_c = sflow.required_temperature_c;
sflow.temperature_c__supplied = sflow.delivery_temperature_c;

check_symbol = char(10003);
cross_symbol = char(10007);
degree_symbol = char(176);
m3_symbol = char(179);

if sflow.temperature_c__supplied >= sflow.temperature_c
    sflow.temperature_c__match = string(check_symbol) + " YES";
else
    sflow.temperature_c__match = string(cross_symbol) + " NO - need " ...
        + string(sflow.temperature_c) + string(degree_symbol) + "C";
end

sflow.thermal_load_kwth = sflow.required_thermal_load_kwth;
sflow.thermal_load_kwth__supplied = sflow.system_thermal_capacity_kwth;
if sflow.thermal_load_kwth__supplied >= sflow.thermal_load_kwth
    spare_kwth = round(sflow.thermal_load_kwth__supplied - sflow.thermal_load_kwth, 0);
    sflow.thermal_load_kwth__match = string(check_symbol) + " YES - " ...
        + string(spare_kwth) + " kWth spare";
else
    short_kwth = round(sflow.thermal_load_kwth - sflow.thermal_load_kwth__supplied, 0);
    sflow.thermal_load_kwth__match = string(cross_symbol) + " SHORT " ...
        + string(short_kwth) + " kWth";
end

sflow.flow_rate_m3_per_hr = sflow.required_flow_rate_m3_per_hr;
sflow.flow_rate_m3_per_hr__supplied = sflow.system_flow_capacity_m3_per_hr;
if sflow.flow_rate_m3_per_hr__supplied >= sflow.flow_rate_m3_per_hr
    spare_flow = round(sflow.flow_rate_m3_per_hr__supplied - sflow.flow_rate_m3_per_hr, 1);
    sflow.flow_rate_m3_per_hr__match = string(check_symbol) + " YES - " ...
        + string(spare_flow) + " m" + string(m3_symbol) + "/hr spare";
else
    short_flow = round(sflow.flow_rate_m3_per_hr - sflow.flow_rate_m3_per_hr__supplied, 1);
    sflow.flow_rate_m3_per_hr__match = string(cross_symbol) + " SHORT " ...
        + string(short_flow) + " m" + string(m3_symbol) + "/hr";
end

sflow.annual_energy_mwh = sflow.annual_heat_demand_mwh;
sflow.annual_energy_mwh__supplied = sflow.annual_heat_supply_mwh;
if sflow.annual_energy_mwh__supplied >= sflow.annual_energy_mwh
    spare_mwh = round(sflow.annual_energy_mwh__supplied - sflow.annual_energy_mwh, 0);
    sflow.annual_energy_mwh__match = string(check_symbol) + " YES - " ...
        + string(spare_mwh) + " MWh spare";
else
    short_mwh = round(sflow.annual_energy_mwh - sflow.annual_energy_mwh__supplied, 0);
    sflow.annual_energy_mwh__match = string(cross_symbol) + " SHORT " ...
        + string(short_mwh) + " MWh";
end

sflow.thermal_utilisation = bp.thermal_utilisation_pct;
sflow.flow_utilisation = bp.flow_utilisation_pct;

if isnumber(bp.thermal_utilisation_pct) && isnumber(bp.flow_utilisation_pct)
    if bp.thermal_utilisation_pct >= bp.flow_utilisation_pct
        sflow.binding_constraint = "Thermal";
    else
        sflow.binding_constraint = "Flow";
    end
else
    sflow.binding_constraint = "-";
end

sflow.spare_capacity_kwth = sflow.system_thermal_capacity_kwth - sflow.required_thermal_load_kwth;
sflow.spare_capacity_m3_per_hr = sflow.system_flow_capacity_m3_per_hr - sflow.required_flow_rate_m3_per_hr;

sflow.design_velocity_m_per_s = 2;
sflow.main_header_pipe_id_mm = sqrt((sflow.required_flow_rate_m3_per_hr / 3600) ...
    / (sflow.design_velocity_m_per_s * 3.14159 / 4)) * 1000;
sflow.nearest_dn_size = nearestDN(sflow.main_header_pipe_id_mm);
end

function tf = isnumber(value)
tf = isnumeric(value) && isscalar(value) && ~isnan(value);
end

function dn = nearestDN(pipe_id_mm)
if pipe_id_mm < 28
    dn = "DN25";
elseif pipe_id_mm < 36
    dn = "DN32";
elseif pipe_id_mm < 42
    dn = "DN40";
elseif pipe_id_mm < 54
    dn = "DN50";
elseif pipe_id_mm < 68
    dn = "DN65";
elseif pipe_id_mm < 82
    dn = "DN80";
elseif pipe_id_mm < 107
    dn = "DN100";
elseif pipe_id_mm < 131
    dn = "DN125";
elseif pipe_id_mm < 159
    dn = "DN150";
else
    dn = "DN200+";
end
end
