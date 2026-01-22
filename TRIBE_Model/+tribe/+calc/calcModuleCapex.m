function mcapex = calcModuleCapex(rp, mc, ref)
%CALCMODULECAPEX Compute module capex values from the Excel model.

if nargin < 3 || isempty(ref)
    ref = tribe.data.ReferenceData();
end

mcapex = struct();
mcapex.chipset = string(rp.chipset_type);
mcapex.cooling_method = string(rp.cooling_method);
mcapex.racks_per_module = rp.racks_per_module;
mcapex.servers_per_module = rp.servers_per_module;
mcapex.module_it_capacity_kw = rp.actual_module_it_capacity_kw;
mcapex.captured_heat_kwth = rp.captured_heat_kwth;

mcapex.container_shell = ref.container_shell_40ft;
mcapex.container_fit_out = ref.container_fit_out_electrical_hvac_prep;
mcapex.rack_enclosures = mcapex.racks_per_module * ref.rack_enclosure_42u_enclosed;

pound = char(163);
times_symbol = char(215);
mcapex.rack_enclosures__fixed_per_module = string(mcapex.racks_per_module) ...
    + " racks " + times_symbol + " " + pound + string(ref.rack_enclosure_42u_enclosed);

mcapex.subtotal_enclosure = sum([mcapex.container_shell, mcapex.container_fit_out, mcapex.rack_enclosures]);

is_dtc = mcapex.cooling_method == "Direct-to-Chip (DTC)";
mcapex.cold_plate_kits = ifzero(is_dtc, mcapex.servers_per_module * ref.cold_plate_kit_per_server);
mcapex.cdu_base = ifzero(is_dtc, ref.cdu_coolant_distribution_unit);
mcapex.cdu_capacity_scaling = ifzero(is_dtc, mcapex.module_it_capacity_kw * ref.cdu_capacity_scaling);
mcapex.manifolds_quick_connects = ifzero(is_dtc, mcapex.servers_per_module * ref.manifolds_quick_connects);
mcapex.primary_loop_piping = ifzero(is_dtc, ref.primary_loop_piping);
mcapex.subtotal_dtc_cooling = sum([mcapex.cold_plate_kits, mcapex.cdu_base, mcapex.cdu_capacity_scaling, ...
    mcapex.manifolds_quick_connects, mcapex.primary_loop_piping]);

is_single = mcapex.cooling_method == "Single-Phase Immersion";
is_two = mcapex.cooling_method == "Two-Phase Immersion";
mcapex.immersion_tanks = ifzero(is_single, mcapex.racks_per_module * ref.single_phase_immersion_tank) ...
    + ifzero(is_two, mcapex.racks_per_module * ref.two_phase_immersion_tank);
mcapex.dielectric_fluid_initial_fill = ifzero(is_single, mcapex.racks_per_module ...
    * ref.fluid_volume_per_rack_single_phase * ref.dielectric_fluid_single_phase) ...
    + ifzero(is_two, mcapex.racks_per_module ...
    * ref.fluid_volume_per_rack_two_phase * ref.dielectric_fluid_two_phase);
mcapex.fluid_management_system = ifzero(is_single || is_two, ref.fluid_management_system);
mcapex.subtotal_immersion_cooling = sum([mcapex.immersion_tanks, mcapex.dielectric_fluid_initial_fill, ...
    mcapex.fluid_management_system]);

mcapex.rack_pdus = mcapex.racks_per_module * ref.high_density_pdu_per_rack;
mcapex.module_power_distribution = mcapex.module_it_capacity_kw * ref.module_power_distribution;
mcapex.electrical_panels_switchgear = ref.electrical_panels_switchgear;
mcapex.subtotal_power = sum([mcapex.rack_pdus, mcapex.module_power_distribution, ...
    mcapex.electrical_panels_switchgear]);

mcapex.primary_heat_exchanger_base = ref.primary_heat_exchanger;
mcapex.heat_exchanger_capacity_scaling = mcapex.captured_heat_kwth * ref.heat_exchanger_scaling;
mcapex.thermal_integration_skid = ref.thermal_integration_skid_pumps_valves;
mcapex.instrumentation_sensors = ref.instrumentation_sensors;
mcapex.subtotal_thermal = sum([mcapex.primary_heat_exchanger_base, mcapex.heat_exchanger_capacity_scaling, ...
    mcapex.thermal_integration_skid, mcapex.instrumentation_sensors]);

mcapex.bms_base_system = ref.bms_base_system;
mcapex.per_rack_monitoring = mcapex.racks_per_module * ref.per_rack_monitoring;
mcapex.network_infrastructure = ref.network_infrastructure;
mcapex.subtotal_monitoring = sum([mcapex.bms_base_system, mcapex.per_rack_monitoring, ...
    mcapex.network_infrastructure]);

mcapex.heat_pump_capex_rate_gbp_per_kwth = 600;
mcapex.heat_pump_unit = ifzero(mc.heat_pump_enabled == 1, ...
    mc.heat_pump_capacity_kwth * mcapex.heat_pump_capex_rate_gbp_per_kwth);
mcapex.heat_pump_installation = ifzero(mc.heat_pump_enabled == 1, mcapex.heat_pump_unit * 0.15);
mcapex.heat_pump_controls = ifzero(mc.heat_pump_enabled == 1, 15000);
mcapex.subtotal_heat_pump = sum([mcapex.heat_pump_unit, mcapex.heat_pump_installation, ...
    mcapex.heat_pump_controls]);

mcapex.premium_rate_pct = rp.capex_premium_vs_air_cooled_pct / 100;
mcapex.applied_to_base_infrastructure = (mcapex.subtotal_enclosure + mcapex.subtotal_dtc_cooling ...
    + mcapex.subtotal_immersion_cooling) * mcapex.premium_rate_pct;
mcapex.base_infrastructure = mcapex.subtotal_enclosure + mcapex.subtotal_dtc_cooling ...
    + mcapex.subtotal_immersion_cooling + mcapex.subtotal_power + mcapex.subtotal_thermal ...
    + mcapex.subtotal_monitoring;
mcapex.cooling_premium = mcapex.applied_to_base_infrastructure;
mcapex.heat_pump = mcapex.subtotal_heat_pump;
mcapex.total_module_capex = mcapex.base_infrastructure + mcapex.cooling_premium + mcapex.heat_pump;

mcapex.capex_per_it_kw_gbp_per_kw = mcapex.total_module_capex / mcapex.module_it_capacity_kw;
mcapex.capex_per_gpu_gbp_per_gpu = mcapex.total_module_capex / rp.gpus_per_module;
end

function value = ifzero(condition, result)
if condition
    value = result;
else
    value = 0;
end
end
