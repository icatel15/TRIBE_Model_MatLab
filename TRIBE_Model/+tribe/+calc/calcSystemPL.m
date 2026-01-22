function spl = calcSystemPL(mc, bp, scapex, sopex)
%CALCSYSTEMPL Compute system profit and loss values from the Excel model.

spl = struct();
spl.selected_buyer_profile = string(bp.select_process);
spl.modules_in_system = bp.modules_required;
spl.chipset = string(bp.chipset);
spl.cooling_method = string(bp.cooling_method);

spl.module_it_capacity_kw = mc.module_it_capacity_kw;
spl.rack_rate_gbp_per_kw_per_month = mc.compute_rate_gbp_per_kw_per_month;
spl.operating_hours_per_year = bp.operating_hours_per_year;
spl.utilisation_assumption_pct = mc.target_utilisation_rate_pct;
spl.compute_revenue_per_module_gbp_per_yr = spl.module_it_capacity_kw ...
    * spl.rack_rate_gbp_per_kw_per_month * 12 * spl.utilisation_assumption_pct;
spl.total_compute_revenue_gbp_per_yr = spl.compute_revenue_per_module_gbp_per_yr ...
    * spl.modules_in_system;

spl.heat_price_gbp_per_mwh = mc.effective_heat_price_gbp_per_mwh;
spl.buyer_operating_hours_per_year = bp.operating_hours_per_year;
spl.theoretical_heat_output_kwth = bp.system_heat_generation_kwth;
spl.theoretical_heat_revenue_gbp_per_yr = spl.theoretical_heat_output_kwth ...
    * spl.buyer_operating_hours_per_year * spl.heat_price_gbp_per_mwh / 1000;
spl.actual_buyer_absorption_kwth = bp.buyer_heat_absorption_kwth;
spl.actual_heat_revenue_gbp_per_yr = spl.actual_buyer_absorption_kwth ...
    * spl.buyer_operating_hours_per_year * spl.heat_price_gbp_per_mwh / 1000;

if spl.theoretical_heat_output_kwth > 0
    spl.heat_utilisation_pct = spl.actual_buyer_absorption_kwth / spl.theoretical_heat_output_kwth;
else
    spl.heat_utilisation_pct = 0;
end

spl.lost_heat_revenue_gbp_per_yr = spl.theoretical_heat_revenue_gbp_per_yr ...
    - spl.actual_heat_revenue_gbp_per_yr;

spl.compute_revenue_gbp_per_yr = spl.total_compute_revenue_gbp_per_yr;
spl.heat_revenue_gbp_per_yr = spl.actual_heat_revenue_gbp_per_yr;
spl.total_revenue_gbp_per_yr = spl.compute_revenue_gbp_per_yr + spl.heat_revenue_gbp_per_yr;
if spl.total_revenue_gbp_per_yr > 0
    spl.heat_as_pct_of_total_revenue = spl.heat_revenue_gbp_per_yr ...
        / spl.total_revenue_gbp_per_yr;
else
    spl.heat_as_pct_of_total_revenue = 0;
end

spl.base_system_opex_gbp_per_yr = sopex.base_system_opex_excl_rejection;
spl.heat_rejection_opex_gbp_per_yr = sopex.heat_rejection_opex_gbp_per_yr;
spl.hydraulic_augmentation_opex_gbp_per_yr = sopex.augmentation_pump_electricity_gbp_per_yr;
spl.total_opex_gbp_per_yr = sopex.total_system_opex;

spl.gross_profit_gbp_per_yr = spl.total_revenue_gbp_per_yr - spl.total_opex_gbp_per_yr;
if spl.total_revenue_gbp_per_yr > 0
    spl.gross_margin_pct = spl.gross_profit_gbp_per_yr / spl.total_revenue_gbp_per_yr;
else
    spl.gross_margin_pct = 0;
end

spl.total_system_capex_gbp = scapex.total_system_capex;
if spl.gross_profit_gbp_per_yr > 0
    spl.simple_payback_years = spl.total_system_capex_gbp / spl.gross_profit_gbp_per_yr;
else
    spl.simple_payback_years = 0;
end

if spl.total_system_capex_gbp > 0
    spl.unlevered_roi_pct = spl.gross_profit_gbp_per_yr / spl.total_system_capex_gbp;
else
    spl.unlevered_roi_pct = 0;
end

spl.heat_utilisation_efficiency_pct = spl.heat_utilisation_pct;
spl.revenue_lost_to_heat_rejection_gbp_per_yr = spl.lost_heat_revenue_gbp_per_yr;
spl.cost_of_heat_rejection_gbp_per_yr = spl.heat_rejection_opex_gbp_per_yr;
spl.total_heat_inefficiency_cost_gbp_per_yr = spl.revenue_lost_to_heat_rejection_gbp_per_yr ...
    + spl.cost_of_heat_rejection_gbp_per_yr;

if (spl.gross_profit_gbp_per_yr + spl.total_heat_inefficiency_cost_gbp_per_yr) > 0
    spl.heat_inefficiency_as_pct_of_potential_profit = spl.total_heat_inefficiency_cost_gbp_per_yr ...
        / (spl.gross_profit_gbp_per_yr + spl.total_heat_inefficiency_cost_gbp_per_yr);
else
    spl.heat_inefficiency_as_pct_of_potential_profit = 0;
end
end
