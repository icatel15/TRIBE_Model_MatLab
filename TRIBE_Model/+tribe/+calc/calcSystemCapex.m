function scapex = calcSystemCapex(mcapex, bp, ref)
%CALCSYSTEMCAPEX Compute system capex values from the Excel model.

if nargin < 3 || isempty(ref)
    ref = tribe.data.ReferenceData();
end

scapex = struct();
scapex.chipset = string(bp.chipset);
scapex.cooling_method = string(bp.cooling_method);
scapex.gpus_per_module = bp.gpus_per_module;

scapex.selected_buyer_profile = string(bp.select_process);
scapex.modules_required = bp.modules_required;

scapex.enclosure_structure = mcapex.subtotal_enclosure;
scapex.cooling_system = mcapex.subtotal_dtc_cooling + mcapex.subtotal_immersion_cooling;
scapex.power_distribution = mcapex.subtotal_power;
scapex.thermal_integration = mcapex.subtotal_thermal;
scapex.monitoring_controls = mcapex.subtotal_monitoring;
scapex.cooling_method_premium = mcapex.applied_to_base_infrastructure;
scapex.heat_pump_if_enabled = mcapex.subtotal_heat_pump;
scapex.total_per_module = mcapex.total_module_capex;

scapex.total_module_capex = scapex.total_per_module * scapex.modules_required;
scapex.shared_infrastructure_pct = 0.05;
scapex.shared_infrastructure_gbp = scapex.total_module_capex * scapex.shared_infrastructure_pct;

if scapex.modules_required > 1
    scapex.integration_commissioning = 25000 * (scapex.modules_required - 1);
else
    scapex.integration_commissioning = 0;
end

scapex.rejection_capacity_required_kwth = bp.rejection_capacity_required_kwth;
scapex.rejection_capex_rate_gbp_per_kwth = bp.rejection_capex_rate_gbp_per_kwth;
if scapex.rejection_capacity_required_kwth > 0
    scapex.heat_rejection_capex = scapex.rejection_capacity_required_kwth ...
        * scapex.rejection_capex_rate_gbp_per_kwth;
else
    scapex.heat_rejection_capex = 0;
end

scapex.flow_deficit_m3_per_hr = bp.flow_deficit_m3_per_hr;
scapex.augmentation_pumps_required = bp.augmentation_pumps_required;
scapex.augmentation_pump_capex = scapex.augmentation_pumps_required ...
    * ref.standard_augmentation_pump_capacity_m3_per_hr ...
    * ref.augmentation_pump_capex_gbp_per_m3_per_hr;

if scapex.flow_deficit_m3_per_hr > 0
    scapex.mixing_valve_controls = ref.mixing_valve_controls_gbp;
else
    scapex.mixing_valve_controls = 0;
end

if scapex.flow_deficit_m3_per_hr > 20
    scapex.pipe_upsizing_allowance = scapex.flow_deficit_m3_per_hr ...
        * ref.pipe_upsizing_allowance_gbp_per_m3_per_hr;
else
    scapex.pipe_upsizing_allowance = 0;
end

scapex.subtotal_hydraulic_augmentation = sum([scapex.augmentation_pump_capex, ...
    scapex.mixing_valve_controls, scapex.pipe_upsizing_allowance]);

scapex.base_system_capex_excl_rejection = scapex.total_module_capex ...
    + scapex.shared_infrastructure_gbp + scapex.integration_commissioning;
scapex.heat_rejection_capex__b44 = scapex.heat_rejection_capex;
scapex.hydraulic_augmentation_capex = scapex.subtotal_hydraulic_augmentation;
scapex.total_system_capex = scapex.base_system_capex_excl_rejection ...
    + scapex.heat_rejection_capex__b44 + scapex.hydraulic_augmentation_capex;

scapex.capex_per_it_kw_gbp_per_kw = scapex.total_system_capex ...
    / (scapex.modules_required * mcapex.module_it_capacity_kw);
scapex.capex_per_kwth_delivered_gbp_per_kwth = scapex.total_system_capex / bp.heat_demand_kwth;
end
