function sopex = calcSystemOpex(mopex, bp, ref)
%CALCSYSTEMOPEX Compute system opex values from the Excel model.

sopex = struct();
sopex.chipset = string(bp.chipset);
sopex.cooling_method = string(bp.cooling_method);
sopex.gpus_per_module = bp.gpus_per_module;

sopex.selected_buyer_profile = string(bp.select_process);
sopex.modules_in_system = bp.modules_required;

sopex.electricity_infra_hp = mopex.subtotal_electricity;
sopex.maintenance_insurance = mopex.subtotal_maintenance_insurance;
sopex.other_site_noc_admin = mopex.subtotal_other;
sopex.total_per_module = mopex.total_module_opex_gbp_per_yr;

sopex.total_module_opex = sopex.total_per_module * sopex.modules_in_system;
sopex.shared_overhead_pct = 0.05;
sopex.shared_overhead_gbp_per_yr = sopex.total_module_opex * sopex.shared_overhead_pct;
sopex.base_system_opex_excl_rejection = sopex.total_module_opex + sopex.shared_overhead_gbp_per_yr;

sopex.excess_heat_kwth = bp.excess_heat_kwth;
sopex.rejection_running_cost_gbp_per_kwth_per_yr = bp.rejection_opex_rate_gbp_per_kwth_per_yr;
if sopex.excess_heat_kwth > 0
    sopex.heat_rejection_opex_gbp_per_yr = sopex.excess_heat_kwth ...
        * sopex.rejection_running_cost_gbp_per_kwth_per_yr;
else
    sopex.heat_rejection_opex_gbp_per_yr = 0;
end

if sopex.base_system_opex_excl_rejection > 0
    sopex.heat_rejection_uplift_pct = sopex.heat_rejection_opex_gbp_per_yr ...
        / sopex.base_system_opex_excl_rejection;
else
    sopex.heat_rejection_uplift_pct = 0;
end

sopex.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pump_capacity_m3_per_hr;
sopex.augmentation_pump_power_kw = bp.augmentation_pump_power_kw;
sopex.annual_operating_hours = bp.operating_hours_per_year;
sopex.electricity_rate_gbp_per_kwh = mopex.electricity_rate_gbp_per_kwh;
sopex.augmentation_pump_electricity_gbp_per_yr = sopex.augmentation_pump_power_kw ...
    * sopex.annual_operating_hours * sopex.electricity_rate_gbp_per_kwh;

sopex.total_system_opex = sopex.base_system_opex_excl_rejection ...
    + sopex.heat_rejection_opex_gbp_per_yr + sopex.augmentation_pump_electricity_gbp_per_yr;
end
