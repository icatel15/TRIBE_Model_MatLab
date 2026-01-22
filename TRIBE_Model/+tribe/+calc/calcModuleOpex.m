function mopex = calcModuleOpex(rp, mc, mcapex, electricity_rate)
%CALCMODULEOPEX Compute module opex values from the Excel model.

mopex = struct();
mopex.electricity_rate_gbp_per_kwh = electricity_rate;

mopex.infrastructure_power_from_pue = rp.pue_contribution - 1;
mopex.infrastructure_power_cost_gbp_per_yr = mc.module_it_capacity_kw ...
    * mopex.infrastructure_power_from_pue * mc.hours_per_year ...
    * mopex.electricity_rate_gbp_per_kwh * mc.target_utilisation_rate_pct;

if mc.heat_pump_enabled == 1
    mopex.heat_pump_electricity_gbp_per_yr = (mc.thermal_output_kwth / mc.heat_pump_cop) ...
        * mc.hours_per_year * mc.target_utilisation_rate_pct * mopex.electricity_rate_gbp_per_kwh;
else
    mopex.heat_pump_electricity_gbp_per_yr = 0;
end

mopex.subtotal_electricity = mopex.infrastructure_power_cost_gbp_per_yr ...
    + mopex.heat_pump_electricity_gbp_per_yr;

mopex.base_maintenance_pct_of_base_capex = 0.03;
mopex.base_maintenance_gbp_per_yr = mcapex.base_infrastructure ...
    * mopex.base_maintenance_pct_of_base_capex;

mopex.heat_pump_maintenance_pct_of_hp_capex = 0.02;
if mc.heat_pump_enabled == 1
    mopex.heat_pump_maintenance_gbp_per_yr = mcapex.heat_pump_unit ...
        * mopex.heat_pump_maintenance_pct_of_hp_capex;
else
    mopex.heat_pump_maintenance_gbp_per_yr = 0;
end

mopex.insurance_pct_of_total_capex = 0.01;
mopex.insurance_gbp_per_yr = mcapex.total_module_capex * mopex.insurance_pct_of_total_capex;

mopex.subtotal_maintenance_insurance = mopex.base_maintenance_gbp_per_yr ...
    + mopex.heat_pump_maintenance_gbp_per_yr + mopex.insurance_gbp_per_yr;

mopex.site_lease_per_licence_gbp_per_yr = 15000;
mopex.remote_monitoring_noc_gbp_per_yr = 12000;
mopex.connectivity_admin_gbp_per_yr = 8000;
mopex.subtotal_other = sum([mopex.site_lease_per_licence_gbp_per_yr, ...
    mopex.remote_monitoring_noc_gbp_per_yr, mopex.connectivity_admin_gbp_per_yr]);

mopex.total_module_opex_gbp_per_yr = mopex.subtotal_electricity ...
    + mopex.subtotal_maintenance_insurance + mopex.subtotal_other;
end
