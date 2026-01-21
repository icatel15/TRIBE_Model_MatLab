# Phase 6 — System-Level Calculations

## Scope

- Implement `6. System Capex`, `7. System Opex`, `8. System Flow`, `9. System P&L`.

## Dependencies

- Phase 2–5 outputs (rp, mc, mcapex, mopex, mflow, bp, ref).

## Required Functions

- `tribe.calc.calcSystemCapex(mcapex, bp, ref)`
- `tribe.calc.calcSystemOpex(mopex, bp, ref)`
- `tribe.calc.calcSystemFlow(mc, bp)`
- `tribe.calc.calcSystemPL(mc, bp, scapex, sopex)`

## Formula Transcription List

| Sheet!Cell | Label | Excel formula | MATLAB transcription | Notes |
|---|---|---|---|---|
| `6. System Capex!B5` | Chipset | `='0. Rack Profile'!B6` | `scapex.chipset = rp.chipset_type;` |  |
| `6. System Capex!B6` | Cooling method | `='0. Rack Profile'!B17` | `scapex.cooling_method = rp.cooling_method;` |  |
| `6. System Capex!B7` | GPUs per module | `='0. Rack Profile'!B39` | `scapex.gpus_per_module = rp.gpus_per_module;` |  |
| `6. System Capex!B10` | Selected buyer profile | `='5. Buyer Profile'!B11` | `scapex.selected_buyer_profile = bp.select_process;` |  |
| `6. System Capex!B11` | Modules required | `='5. Buyer Profile'!B36` | `scapex.modules_required = bp.modules_required;` |  |
| `6. System Capex!B14` | Enclosure & structure | `='2. Module Capex'!B16` | `scapex.enclosure_structure = mcapex.subtotal_enclosure;` |  |
| `6. System Capex!B15` | Cooling system | `='2. Module Capex'!B24+'2. Module Capex'!B30` | `scapex.cooling_system = mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling;` |  |
| `6. System Capex!B16` | Power distribution | `='2. Module Capex'!B36` | `scapex.power_distribution = mcapex.subtotal_power;` |  |
| `6. System Capex!B17` | Thermal integration | `='2. Module Capex'!B43` | `scapex.thermal_integration = mcapex.subtotal_thermal;` |  |
| `6. System Capex!B18` | Monitoring & controls | `='2. Module Capex'!B49` | `scapex.monitoring_controls = mcapex.subtotal_monitoring;` |  |
| `6. System Capex!B19` | Cooling method premium | `='2. Module Capex'!B60` | `scapex.cooling_method_premium = mcapex.applied_to_base_infrastructure;` |  |
| `6. System Capex!B20` | Heat pump (if enabled) | `='2. Module Capex'!B56` | `scapex.heat_pump_if_enabled = mcapex.subtotal_heat_pump;` |  |
| `6. System Capex!B21` | TOTAL PER MODULE | `='2. Module Capex'!B66` | `scapex.total_per_module = mcapex.total_module_capex;` |  |
| `6. System Capex!B24` | Total module capex | `=B21*B11` | `scapex.total_module_capex = scapex.total_per_module*scapex.modules_required;` |  |
| `6. System Capex!B26` | Shared infrastructure (£) | `=B24*B25` | `scapex.shared_infrastructure_gbp = scapex.total_module_capex*scapex.shared_infrastructure_pct;` |  |
| `6. System Capex!B27` | Integration & commissioning | `=IF(B11>1,25000*(B11-1),0)` | `scapex.integration_commissioning = ifelse(scapex.modules_required>1,25000*(scapex.modules_required-1),0);` |  |
| `6. System Capex!B30` | Rejection capacity required (kWth) | `='5. Buyer Profile'!B54` | `scapex.rejection_capacity_required_kwth = bp.rejection_capacity_required_kwth;` |  |
| `6. System Capex!B31` | Rejection capex rate (£/kWth) | `='5. Buyer Profile'!B55` | `scapex.rejection_capex_rate_gbp_per_kwth = bp.rejection_capex_rate_gbp_per_kwth;` |  |
| `6. System Capex!B32` | Heat rejection capex | `=IF(B30>0,B30*B31,0)` | `scapex.heat_rejection_capex = ifelse(scapex.rejection_capacity_required_kwth>0,scapex.rejection_capacity_required_kwth*scapex.rejection_capex_rate_gbp_per_kwth,0);` |  |
| `6. System Capex!B35` | Flow deficit (m³/hr) | `='5. Buyer Profile'!B37` | `scapex.flow_deficit_m3_per_hr = bp.flow_deficit_m3_per_hr;` |  |
| `6. System Capex!B36` | Augmentation pumps required | `='5. Buyer Profile'!B86` | `scapex.augmentation_pumps_required = bp.augmentation_pumps_required;` |  |
| `6. System Capex!B37` | Augmentation pump capex | `=B36*'11. Reference Data'!B124*'11. Reference Data'!B120` | `scapex.augmentation_pump_capex = scapex.augmentation_pumps_required*ref.standard_augmentation_pump_capacity_m3_per_hr*ref.augmentation_pump_capex_gbp_per_m3_per_hr;` |  |
| `6. System Capex!B38` | Mixing valve + controls | `=IF(B35>0,'11. Reference Data'!B122,0)` | `scapex.mixing_valve_controls = ifelse(scapex.flow_deficit_m3_per_hr>0,ref.mixing_valve_controls_gbp,0);` |  |
| `6. System Capex!B39` | Pipe upsizing allowance | `=IF(B35>20,B35*'11. Reference Data'!B123,0)` | `scapex.pipe_upsizing_allowance = ifelse(scapex.flow_deficit_m3_per_hr>20,scapex.flow_deficit_m3_per_hr*ref.pipe_upsizing_allowance_gbp_per_m3_per_hr,0);` |  |
| `6. System Capex!B40` | SUBTOTAL: HYDRAULIC AUGMENTATION | `=SUM(B37:B39)` | `scapex.subtotal_hydraulic_augmentation = sum([scapex.augmentation_pump_capex, scapex.mixing_valve_controls, scapex.pipe_upsizing_allowance]);` |  |
| `6. System Capex!B43` | Base system capex (excl. rejection) | `=B24+B26+B27` | `scapex.base_system_capex_excl_rejection = scapex.total_module_capex+scapex.shared_infrastructure_gbp+scapex.integration_commissioning;` |  |
| `6. System Capex!B44` | Heat rejection capex | `=B32` | `scapex.heat_rejection_capex__b44 = scapex.heat_rejection_capex;` |  |
| `6. System Capex!B45` | Hydraulic augmentation capex | `=B40` | `scapex.hydraulic_augmentation_capex = scapex.subtotal_hydraulic_augmentation;` |  |
| `6. System Capex!B46` | TOTAL SYSTEM CAPEX | `=B43+B44+B45` | `scapex.total_system_capex = scapex.base_system_capex_excl_rejection+scapex.heat_rejection_capex__b44+scapex.hydraulic_augmentation_capex;` |  |
| `6. System Capex!B48` | Capex per IT kW (£/kW) | `=B46/(B11*'0. Rack Profile'!B40)` | `scapex.capex_per_it_kw_gbp_per_kw = scapex.total_system_capex/(scapex.modules_required*rp.actual_module_it_capacity_kw);` |  |
| `6. System Capex!B49` | Capex per kWth delivered (£/kWth) | `=B46/'5. Buyer Profile'!B17` | `scapex.capex_per_kwth_delivered_gbp_per_kwth = scapex.total_system_capex/bp.heat_demand_kwth;` |  |
| `7. System Opex!B5` | Chipset | `='0. Rack Profile'!B6` | `sopex.chipset = rp.chipset_type;` |  |
| `7. System Opex!B6` | Cooling method | `='0. Rack Profile'!B17` | `sopex.cooling_method = rp.cooling_method;` |  |
| `7. System Opex!B7` | GPUs per module | `='0. Rack Profile'!B39` | `sopex.gpus_per_module = rp.gpus_per_module;` |  |
| `7. System Opex!B10` | Selected buyer profile | `='5. Buyer Profile'!B11` | `sopex.selected_buyer_profile = bp.select_process;` |  |
| `7. System Opex!B11` | Modules in system | `='5. Buyer Profile'!B36` | `sopex.modules_in_system = bp.modules_required;` |  |
| `7. System Opex!B14` | Electricity (infra + HP) | `='3. Module Opex'!B10` | `sopex.electricity_infra_hp = mopex.subtotal_electricity;` |  |
| `7. System Opex!B15` | Maintenance & insurance | `='3. Module Opex'!B21` | `sopex.maintenance_insurance = mopex.subtotal_maintenance_insurance;` |  |
| `7. System Opex!B16` | Other (site, NOC, admin) | `='3. Module Opex'!B27` | `sopex.other_site_noc_admin = mopex.subtotal_other;` |  |
| `7. System Opex!B17` | TOTAL PER MODULE | `='3. Module Opex'!B29` | `sopex.total_per_module = mopex.total_module_opex_gbp_per_yr;` |  |
| `7. System Opex!B20` | Total module opex | `=B17*B11` | `sopex.total_module_opex = sopex.total_per_module*sopex.modules_in_system;` |  |
| `7. System Opex!B22` | Shared overhead (£/yr) | `=B20*B21` | `sopex.shared_overhead_gbp_per_yr = sopex.total_module_opex*sopex.shared_overhead_pct;` |  |
| `7. System Opex!B23` | Base system opex (excl. rejection) | `=B20+B22` | `sopex.base_system_opex_excl_rejection = sopex.total_module_opex+sopex.shared_overhead_gbp_per_yr;` |  |
| `7. System Opex!B26` | Excess heat (kWth) | `='5. Buyer Profile'!B50` | `sopex.excess_heat_kwth = bp.excess_heat_kwth;` |  |
| `7. System Opex!B27` | Rejection running cost (£/kWth/yr) | `='5. Buyer Profile'!B56` | `sopex.rejection_running_cost_gbp_per_kwth_per_yr = bp.rejection_opex_rate_gbp_per_kwth_per_yr;` |  |
| `7. System Opex!B28` | Heat rejection opex (£/yr) | `=IF(B26>0,B26*B27,0)` | `sopex.heat_rejection_opex_gbp_per_yr = ifelse(sopex.excess_heat_kwth>0,sopex.excess_heat_kwth*sopex.rejection_running_cost_gbp_per_kwth_per_yr,0);` |  |
| `7. System Opex!B29` | Heat rejection uplift (%) | `=IF(B23>0,B28/B23,0)` | `sopex.heat_rejection_uplift_pct = ifelse(sopex.base_system_opex_excl_rejection>0,sopex.heat_rejection_opex_gbp_per_yr/sopex.base_system_opex_excl_rejection,0);` |  |
| `7. System Opex!B31` | Augmentation pump capacity (m³/hr) | `='5. Buyer Profile'!B87` | `sopex.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pump_capacity_m3_per_hr;` |  |
| `7. System Opex!B32` | Augmentation pump power (kW) | `='5. Buyer Profile'!B85` | `sopex.augmentation_pump_power_kw = bp.augmentation_pump_power_kw;` |  |
| `7. System Opex!B33` | Annual operating hours | `='5. Buyer Profile'!B18` | `sopex.annual_operating_hours = bp.operating_hours_per_year;` |  |
| `7. System Opex!B34` | Electricity rate (£/kWh) | `='3. Module Opex'!B5` | `sopex.electricity_rate_gbp_per_kwh = mopex.electricity_rate_gbp_per_kwh;` |  |
| `7. System Opex!B35` | Augmentation pump electricity (£/yr) | `=B32*B33*B34` | `sopex.augmentation_pump_electricity_gbp_per_yr = sopex.augmentation_pump_power_kw*sopex.annual_operating_hours*sopex.electricity_rate_gbp_per_kwh;` |  |
| `7. System Opex!B37` | TOTAL SYSTEM OPEX | `=B23+B28+B35` | `sopex.total_system_opex = sopex.base_system_opex_excl_rejection+sopex.heat_rejection_opex_gbp_per_yr+sopex.augmentation_pump_electricity_gbp_per_yr;` |  |
| `8. System Flow!B5` | Chipset | `='0. Rack Profile'!B6` | `sflow.chipset = rp.chipset_type;` |  |
| `8. System Flow!B6` | Cooling method | `='0. Rack Profile'!B17` | `sflow.cooling_method = rp.cooling_method;` |  |
| `8. System Flow!B7` | Capture temperature (°C) | `='0. Rack Profile'!B21` | `sflow.capture_temperature_c = rp.capture_temperature_c;` |  |
| `8. System Flow!B10` | Selected buyer profile | `='5. Buyer Profile'!B11` | `sflow.selected_buyer_profile = bp.select_process;` |  |
| `8. System Flow!B11` | Modules in system | `='5. Buyer Profile'!B36` | `sflow.modules_in_system = bp.modules_required;` |  |
| `8. System Flow!B14` | Required temperature (°C) | `='5. Buyer Profile'!B16` | `sflow.required_temperature_c = bp.required_temperature_c;` |  |
| `8. System Flow!B15` | Required thermal load (kWth) | `='5. Buyer Profile'!B17` | `sflow.required_thermal_load_kwth = bp.heat_demand_kwth;` |  |
| `8. System Flow!B16` | Required flow rate (m³/hr) | `='5. Buyer Profile'!B26` | `sflow.required_flow_rate_m3_per_hr = bp.required_flow_rate_m3_per_hr;` |  |
| `8. System Flow!B17` | Annual heat demand (MWh) | `='5. Buyer Profile'!B24` | `sflow.annual_heat_demand_mwh = bp.annual_heat_demand_mwh;` |  |
| `8. System Flow!B20` | Delivery temperature (°C) | `='1. Module Criteria'!B22` | `sflow.delivery_temperature_c = mc.delivery_temperature_c;` |  |
| `8. System Flow!B21` | System thermal capacity (kWth) | `='5. Buyer Profile'!B41` | `sflow.system_thermal_capacity_kwth = bp.system_thermal_capacity_kwth;` |  |
| `8. System Flow!B22` | System flow capacity (m³/hr) | `='5. Buyer Profile'!B42` | `sflow.system_flow_capacity_m3_per_hr = bp.system_flow_capacity_m3_per_hr;` |  |
| `8. System Flow!B23` | Annual heat supply (MWh) | `=B21*'5. Buyer Profile'!B18/1000` | `sflow.annual_heat_supply_mwh = sflow.system_thermal_capacity_kwth*bp.operating_hours_per_year/1000;` |  |
| `8. System Flow!B26` | Temperature (°C) | `=B14` | `sflow.temperature_c = sflow.required_temperature_c;` |  |
| `8. System Flow!C26` | Temperature (°C) | `=B20` | `sflow.temperature_c__supplied = sflow.delivery_temperature_c;` |  |
| `8. System Flow!D26` | Temperature (°C) | `=IF(C26>=B26,"✓ YES","✗ NO - need "&B26&"°C")` | `sflow.temperature_c__match = string(ifelse(sflow.temperature_c__supplied>=sflow.temperature_c,"✓ YES","✗ NO - need ") + string(sflow.temperature_c) + string("°C"));` | text concat |
| `8. System Flow!B27` | Thermal load (kWth) | `=B15` | `sflow.thermal_load_kwth = sflow.required_thermal_load_kwth;` |  |
| `8. System Flow!C27` | Thermal load (kWth) | `=B21` | `sflow.thermal_load_kwth__supplied = sflow.system_thermal_capacity_kwth;` |  |
| `8. System Flow!D27` | Thermal load (kWth) | `=IF(C27>=B27,"✓ YES - "&ROUND((C27-B27),0)&" kWth spare","✗ SHORT "&ROUND((B27-C27),0)&" kWth")` | `sflow.thermal_load_kwth__match = string(ifelse(sflow.thermal_load_kwth__supplied>=sflow.thermal_load_kwth,"✓ YES - ") + string(round((sflow.thermal_load_kwth__supplied-sflow.thermal_load_kwth),0)) + " kWth spare","✗ SHORT " + string(round((sflow.thermal_load_kwth-sflow.thermal_load_kwth__supplied),0)) + string(" kWth"));` | text concat |
| `8. System Flow!B28` | Flow rate (m³/hr) | `=B16` | `sflow.flow_rate_m3_per_hr = sflow.required_flow_rate_m3_per_hr;` |  |
| `8. System Flow!C28` | Flow rate (m³/hr) | `=B22` | `sflow.flow_rate_m3_per_hr__supplied = sflow.system_flow_capacity_m3_per_hr;` |  |
| `8. System Flow!D28` | Flow rate (m³/hr) | `=IF(C28>=B28,"✓ YES - "&ROUND((C28-B28),1)&" m³/hr spare","✗ SHORT "&ROUND((B28-C28),1)&" m³/hr")` | `sflow.flow_rate_m3_per_hr__match = string(ifelse(sflow.flow_rate_m3_per_hr__supplied>=sflow.flow_rate_m3_per_hr,"✓ YES - ") + string(round((sflow.flow_rate_m3_per_hr__supplied-sflow.flow_rate_m3_per_hr),1)) + " m³/hr spare","✗ SHORT " + string(round((sflow.flow_rate_m3_per_hr-sflow.flow_rate_m3_per_hr__supplied),1)) + string(" m³/hr"));` | text concat |
| `8. System Flow!B29` | Annual energy (MWh) | `=B17` | `sflow.annual_energy_mwh = sflow.annual_heat_demand_mwh;` |  |
| `8. System Flow!C29` | Annual energy (MWh) | `=B23` | `sflow.annual_energy_mwh__supplied = sflow.annual_heat_supply_mwh;` |  |
| `8. System Flow!D29` | Annual energy (MWh) | `=IF(C29>=B29,"✓ YES - "&ROUND((C29-B29),0)&" MWh spare","✗ SHORT "&ROUND((B29-C29),0)&" MWh")` | `sflow.annual_energy_mwh__match = string(ifelse(sflow.annual_energy_mwh__supplied>=sflow.annual_energy_mwh,"✓ YES - ") + string(round((sflow.annual_energy_mwh__supplied-sflow.annual_energy_mwh),0)) + " MWh spare","✗ SHORT " + string(round((sflow.annual_energy_mwh-sflow.annual_energy_mwh__supplied),0)) + string(" MWh"));` | text concat |
| `8. System Flow!B32` | Thermal utilisation | `='5. Buyer Profile'!B43` | `sflow.thermal_utilisation = bp.thermal_utilisation_pct;` |  |
| `8. System Flow!B33` | Flow utilisation | `='5. Buyer Profile'!B44` | `sflow.flow_utilisation = bp.flow_utilisation_pct;` |  |
| `8. System Flow!B34` | Binding constraint | `=IF(AND(ISNUMBER('5. Buyer Profile'!B43),ISNUMBER('5. Buyer Profile'!B44)),IF('5. Buyer Profile'!B43>='5. Buyer Profile'!B44,"Thermal","Flow"),"-")` | `sflow.binding_constraint = ifelse(and(isnumber(bp.thermal_utilisation_pct),isnumber(bp.flow_utilisation_pct)),ifelse(bp.thermal_utilisation_pct>=bp.flow_utilisation_pct,"Thermal","Flow"),"-");` | ISNUMBER guard |
| `8. System Flow!B36` | Spare capacity (kWth) | `=B21-B15` | `sflow.spare_capacity_kwth = sflow.system_thermal_capacity_kwth-sflow.required_thermal_load_kwth;` |  |
| `8. System Flow!B37` | Spare capacity (m³/hr) | `=B22-B16` | `sflow.spare_capacity_m3_per_hr = sflow.system_flow_capacity_m3_per_hr-sflow.required_flow_rate_m3_per_hr;` |  |
| `8. System Flow!B41` | Main header pipe ID (mm) | `=SQRT((B16/3600)/(B40*3.14159/4))*1000` | `sflow.main_header_pipe_id_mm = sqrt((sflow.required_flow_rate_m3_per_hr/3600)/(sflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| `8. System Flow!B42` | Nearest DN size | `=IF(B41<28,"DN25",IF(B41<36,"DN32",IF(B41<42,"DN40",IF(B41<54,"DN50",IF(B41<68,"DN65",IF(B41<82,"DN80",IF(B41<107,"DN100",IF(B41<131,"DN125",IF(B41<159,"DN150","DN200+")))))))))` | `sflow.nearest_dn_size = ifelse(sflow.main_header_pipe_id_mm<28,"DN25",ifelse(sflow.main_header_pipe_id_mm<36,"DN32",ifelse(sflow.main_header_pipe_id_mm<42,"DN40",ifelse(sflow.main_header_pipe_id_mm<54,"DN50",ifelse(sflow.main_header_pipe_id_mm<68,"DN65",ifelse(sflow.main_header_pipe_id_mm<82,"DN80",ifelse(sflow.main_header_pipe_id_mm<107,"DN100",ifelse(sflow.main_header_pipe_id_mm<131,"DN125",ifelse(sflow.main_header_pipe_id_mm<159,"DN150","DN200+")))))))));` |  |
| `9. System P&L!B6` | Selected buyer profile | `='5. Buyer Profile'!B11` | `spl.selected_buyer_profile = bp.select_process;` |  |
| `9. System P&L!B7` | Modules in system | `='5. Buyer Profile'!B36` | `spl.modules_in_system = bp.modules_required;` |  |
| `9. System P&L!B8` | Chipset | `='0. Rack Profile'!B6` | `spl.chipset = rp.chipset_type;` |  |
| `9. System P&L!B9` | Cooling method | `='0. Rack Profile'!B17` | `spl.cooling_method = rp.cooling_method;` |  |
| `9. System P&L!B12` | Module IT capacity (kW) | `='1. Module Criteria'!B5` | `spl.module_it_capacity_kw = mc.module_it_capacity_kw;` |  |
| `9. System P&L!B13` | Rack rate (£/kW/month) | `='1. Module Criteria'!B6` | `spl.rack_rate_gbp_per_kw_per_month = mc.compute_rate_gbp_per_kw_per_month;` |  |
| `9. System P&L!B14` | Operating hours/year | `='5. Buyer Profile'!B18` | `spl.operating_hours_per_year = bp.operating_hours_per_year;` |  |
| `9. System P&L!B15` | Utilisation assumption (%) | `='1. Module Criteria'!B7` | `spl.utilisation_assumption_pct = mc.target_utilisation_rate_pct;` |  |
| `9. System P&L!B16` | Compute revenue per module (£/yr) | `=B12*B13*12*B15` | `spl.compute_revenue_per_module_gbp_per_yr = spl.module_it_capacity_kw*spl.rack_rate_gbp_per_kw_per_month*12*spl.utilisation_assumption_pct;` |  |
| `9. System P&L!B17` | TOTAL COMPUTE REVENUE (£/yr) | `=B16*B7` | `spl.total_compute_revenue_gbp_per_yr = spl.compute_revenue_per_module_gbp_per_yr*spl.modules_in_system;` |  |
| `9. System P&L!B20` | Heat price (£/MWh) | `='1. Module Criteria'!B29` | `spl.heat_price_gbp_per_mwh = mc.effective_heat_price_gbp_per_mwh;` |  |
| `9. System P&L!B21` | Buyer operating hours/year | `='5. Buyer Profile'!B18` | `spl.buyer_operating_hours_per_year = bp.operating_hours_per_year;` |  |
| `9. System P&L!B23` | Theoretical heat output (kWth) | `='5. Buyer Profile'!B48` | `spl.theoretical_heat_output_kwth = bp.system_heat_generation_kwth;` |  |
| `9. System P&L!B24` | Theoretical heat revenue (£/yr) | `=B23*B21*B20/1000` | `spl.theoretical_heat_revenue_gbp_per_yr = spl.theoretical_heat_output_kwth*spl.buyer_operating_hours_per_year*spl.heat_price_gbp_per_mwh/1000;` |  |
| `9. System P&L!B26` | Actual buyer absorption (kWth) | `='5. Buyer Profile'!B49` | `spl.actual_buyer_absorption_kwth = bp.buyer_heat_absorption_kwth;` |  |
| `9. System P&L!B27` | ACTUAL HEAT REVENUE (£/yr) | `=B26*B21*B20/1000` | `spl.actual_heat_revenue_gbp_per_yr = spl.actual_buyer_absorption_kwth*spl.buyer_operating_hours_per_year*spl.heat_price_gbp_per_mwh/1000;` |  |
| `9. System P&L!B29` | Heat utilisation (%) | `=IF(B23>0,B26/B23,0)` | `spl.heat_utilisation_pct = ifelse(spl.theoretical_heat_output_kwth>0,spl.actual_buyer_absorption_kwth/spl.theoretical_heat_output_kwth,0);` |  |
| `9. System P&L!B30` | Lost heat revenue (£/yr) | `=B24-B27` | `spl.lost_heat_revenue_gbp_per_yr = spl.theoretical_heat_revenue_gbp_per_yr-spl.actual_heat_revenue_gbp_per_yr;` |  |
| `9. System P&L!B33` | Compute revenue (£/yr) | `=B17` | `spl.compute_revenue_gbp_per_yr = spl.total_compute_revenue_gbp_per_yr;` |  |
| `9. System P&L!B34` | Heat revenue (£/yr) | `=B27` | `spl.heat_revenue_gbp_per_yr = spl.actual_heat_revenue_gbp_per_yr;` |  |
| `9. System P&L!B35` | TOTAL REVENUE (£/yr) | `=B33+B34` | `spl.total_revenue_gbp_per_yr = spl.compute_revenue_gbp_per_yr+spl.heat_revenue_gbp_per_yr;` |  |
| `9. System P&L!B36` | Heat as % of total revenue | `=IF(B35>0,B34/B35,0)` | `spl.heat_as_pct_of_total_revenue = ifelse(spl.total_revenue_gbp_per_yr>0,spl.heat_revenue_gbp_per_yr/spl.total_revenue_gbp_per_yr,0);` |  |
| `9. System P&L!B39` | Base system opex (£/yr) | `='7. System Opex'!B23` | `spl.base_system_opex_gbp_per_yr = sopex.base_system_opex_excl_rejection;` |  |
| `9. System P&L!B40` | Heat rejection opex (£/yr) | `='7. System Opex'!B28` | `spl.heat_rejection_opex_gbp_per_yr = sopex.heat_rejection_opex_gbp_per_yr;` |  |
| `9. System P&L!B41` | Hydraulic augmentation opex (£/yr) | `='7. System Opex'!B35` | `spl.hydraulic_augmentation_opex_gbp_per_yr = sopex.augmentation_pump_electricity_gbp_per_yr;` |  |
| `9. System P&L!B42` | TOTAL OPEX (£/yr) | `='7. System Opex'!B37` | `spl.total_opex_gbp_per_yr = sopex.total_system_opex;` |  |
| `9. System P&L!B45` | Gross profit (£/yr) | `=B35-B42` | `spl.gross_profit_gbp_per_yr = spl.total_revenue_gbp_per_yr-spl.total_opex_gbp_per_yr;` |  |
| `9. System P&L!B46` | Gross margin (%) | `=IF(B35>0,B45/B35,0)` | `spl.gross_margin_pct = ifelse(spl.total_revenue_gbp_per_yr>0,spl.gross_profit_gbp_per_yr/spl.total_revenue_gbp_per_yr,0);` |  |
| `9. System P&L!B48` | Total system capex (£) | `='6. System Capex'!B46` | `spl.total_system_capex_gbp = scapex.total_system_capex;` |  |
| `9. System P&L!B49` | Simple payback (years) | `=IF(B45>0,B48/B45,0)` | `spl.simple_payback_years = ifelse(spl.gross_profit_gbp_per_yr>0,spl.total_system_capex_gbp/spl.gross_profit_gbp_per_yr,0);` |  |
| `9. System P&L!B50` | Unlevered ROI (%) | `=IF(B48>0,B45/B48,0)` | `spl.unlevered_roi_pct = ifelse(spl.total_system_capex_gbp>0,spl.gross_profit_gbp_per_yr/spl.total_system_capex_gbp,0);` |  |
| `9. System P&L!B53` | Heat utilisation efficiency (%) | `=B29` | `spl.heat_utilisation_efficiency_pct = spl.heat_utilisation_pct;` |  |
| `9. System P&L!B54` | Revenue lost to heat rejection (£/yr) | `=B30` | `spl.revenue_lost_to_heat_rejection_gbp_per_yr = spl.lost_heat_revenue_gbp_per_yr;` |  |
| `9. System P&L!B55` | Cost of heat rejection (£/yr) | `=B40` | `spl.cost_of_heat_rejection_gbp_per_yr = spl.heat_rejection_opex_gbp_per_yr;` |  |
| `9. System P&L!B56` | Total heat inefficiency cost (£/yr) | `=B54+B55` | `spl.total_heat_inefficiency_cost_gbp_per_yr = spl.revenue_lost_to_heat_rejection_gbp_per_yr+spl.cost_of_heat_rejection_gbp_per_yr;` |  |
| `9. System P&L!B57` | Heat inefficiency as % of potential profit | `=IF((B45+B56)>0,B56/(B45+B56),0)` | `spl.heat_inefficiency_as_pct_of_potential_profit = ifelse((spl.gross_profit_gbp_per_yr+spl.total_heat_inefficiency_cost_gbp_per_yr)>0,spl.total_heat_inefficiency_cost_gbp_per_yr/(spl.gross_profit_gbp_per_yr+spl.total_heat_inefficiency_cost_gbp_per_yr),0);` |  |

## Validation Criteria

- Full chain produces system capex/opex/flow and P&L matching Excel.
- Payback and ROI use profit and capex cells as per `9. System P&L`.

