function mflow = calcModuleFlow(mc, cooling_method, ref)
%CALCMODULEFLOW Compute module flow values from the Excel model.

if nargin < 3 || isempty(ref)
    ref = tribe.data.ReferenceData();
end

cooling_method = string(cooling_method);

mflow = struct();
mflow.specific_heat_of_water_kj_per_kg_k = 4.18;
mflow.water_density_kg_per_l = 1;

mflow.thermal_power_kwth = mc.captured_heat_kwth;
mflow.inlet_temperature_c = mc.capture_temperature_c;
mflow.source_loop_deltat_c = lookupSourceDeltaT(cooling_method, ref);
mflow.outlet_temperature_c = mflow.inlet_temperature_c - mflow.source_loop_deltat_c;

mflow.mass_flow_rate_kg_per_s = mflow.thermal_power_kwth ...
    / (mflow.specific_heat_of_water_kj_per_kg_k * mflow.source_loop_deltat_c);
mflow.volume_flow_rate_l_per_s = mflow.mass_flow_rate_kg_per_s / mflow.water_density_kg_per_l;
mflow.volume_flow_rate_m3_per_hr = mflow.volume_flow_rate_l_per_s * 3.6;

mflow.thermal_power_delivered_kwth = mc.thermal_output_kwth;
mflow.outlet_temperature_c__b20 = mc.delivery_temperature_c;
mflow.sink_loop_deltat_c = 10;
mflow.return_temperature_c = mflow.outlet_temperature_c__b20 - mflow.sink_loop_deltat_c;

mflow.mass_flow_rate_kg_per_s__b24 = mflow.thermal_power_delivered_kwth ...
    / (mflow.specific_heat_of_water_kj_per_kg_k * mflow.sink_loop_deltat_c);
mflow.volume_flow_rate_l_per_s__b25 = mflow.mass_flow_rate_kg_per_s__b24 / mflow.water_density_kg_per_l;
mflow.volume_flow_rate_m3_per_hr__b26 = mflow.volume_flow_rate_l_per_s__b25 * 3.6;

mflow.design_velocity_m_per_s = 2;
mflow.source_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s / 1000) ...
    / (mflow.design_velocity_m_per_s * 3.14159 / 4)) * 1000;
mflow.sink_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s__b25 / 1000) ...
    / (mflow.design_velocity_m_per_s * 3.14159 / 4)) * 1000;

mflow.source_loop_nearest_dn = nearestDN(mflow.source_loop_pipe_id_mm);
mflow.sink_loop_nearest_dn = nearestDN(mflow.sink_loop_pipe_id_mm);

mflow.thermal_capacity_kwth = mflow.thermal_power_delivered_kwth;
mflow.delivery_temperature_c = mflow.outlet_temperature_c__b20;
mflow.flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;
end

function delta_t = lookupSourceDeltaT(cooling_method, ref)
switch cooling_method
    case "Direct-to-Chip (DTC)"
        delta_t = ref.direct_to_chip_dtc__source_deltat_c;
    case "Single-Phase Immersion"
        delta_t = ref.single_phase_immersion__source_deltat_c;
    case "Two-Phase Immersion"
        delta_t = ref.two_phase_immersion__source_deltat_c;
    case "Rear Door Heat Exchanger"
        delta_t = ref.rear_door_heat_exchanger__source_deltat_c;
    otherwise
        delta_t = ref.air_cooled_reference__source_deltat_c;
end
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
else
    dn = "DN125+";
end
end
