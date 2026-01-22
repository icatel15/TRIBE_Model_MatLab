function mc = calcModuleCriteria(rp, hp_enabled, hp_output_temp, utilisation, hours_per_year, base_heat_price, premium_heat_price)
%CALCMODULECRITERIA Compute module criteria values from the Excel model.

ref = tribe.data.ReferenceData();

mc = struct();
mc.module_it_capacity_kw = rp.actual_module_it_capacity_kw;
mc.compute_rate_gbp_per_kw_per_month = 150;
mc.target_utilisation_rate_pct = utilisation;

mc.heat_capture_rate_pct = rp.heat_capture_rate_pct;
mc.captured_heat_kwth = mc.module_it_capacity_kw * mc.heat_capture_rate_pct;
mc.capture_temperature_c = rp.capture_temperature_c;

mc.heat_pump_enabled = double(hp_enabled);
mc.heat_pump_output_temperature_c = hp_output_temp;

if mc.heat_pump_enabled == 0
    mc.heat_pump_cop = "-";
else
    cop_raw = round(ref.carnot_efficiency_factor * (mc.heat_pump_output_temperature_c + 273.15) ...
        / (mc.heat_pump_output_temperature_c - mc.capture_temperature_c), 2);
    mc.heat_pump_cop = boundCop(cop_raw, ref);
end

mc.heat_pump_capacity_kwth = mc.captured_heat_kwth;

if mc.heat_pump_enabled == 1
    if mc.heat_pump_cop <= 1
        mc.thermal_output_kwth = mc.captured_heat_kwth;
    else
        mc.thermal_output_kwth = mc.captured_heat_kwth * mc.heat_pump_cop ...
            / (mc.heat_pump_cop - 1);
    end
else
    mc.thermal_output_kwth = mc.captured_heat_kwth;
end

if mc.heat_pump_enabled == 1
    mc.delivery_temperature_c = mc.heat_pump_output_temperature_c;
else
    mc.delivery_temperature_c = mc.capture_temperature_c;
end

mc.hours_per_year = hours_per_year;
mc.annual_heat_output_mwh = mc.thermal_output_kwth * mc.hours_per_year ...
    * mc.target_utilisation_rate_pct / 1000;

mc.base_heat_price_no_hp_gbp_per_mwh = base_heat_price;
mc.premium_heat_price_with_hp_gbp_per_mwh = premium_heat_price;

if mc.heat_pump_enabled == 1
    mc.effective_heat_price_gbp_per_mwh = mc.premium_heat_price_with_hp_gbp_per_mwh;
else
    mc.effective_heat_price_gbp_per_mwh = mc.base_heat_price_no_hp_gbp_per_mwh;
end

mc.reference_industrial_gas_price_gbp_per_mwh = 53;
end

function cop = boundCop(cop_raw, ref)
cop = max(ref.minimum_practical_cop, min(ref.maximum_practical_cop, cop_raw));
end
