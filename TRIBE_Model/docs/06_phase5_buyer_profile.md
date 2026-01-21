# Phase 5 — Buyer Profile & Process Library Integration

## Scope

- Implement `5. Buyer Profile` as `tribe.calc.calcBuyerProfile`.

## Dependencies

- Phase 2 (ReferenceData, ProcessLibrary) + Phase 3/4 outputs (rp, mc, mflow).

## Inputs

- `process_id` corresponds to `5. Buyer Profile!B11` (dropdown name from Process Library column G).

## Output

- `bp` struct matching the `BuyerProfile` field inventory in `02_architecture.md`.

## Notes / Critical Formulas

- Flow rate: `kWth / (4.18 * ΔT) * 3.6` (see `5. Buyer Profile!B26`).
- Rejection method selection uses thresholds from Reference Data (`5. Buyer Profile!B53`).
- Augmentation pump sizing uses discrete pump capacity and `ROUNDUP` (`5. Buyer Profile!B86`).
- Heat pump electrical demand guards `ISNUMBER(COP)` and `COP>1` (`5. Buyer Profile!B75`).

## Formula Transcription List

| Sheet!Cell | Label | Excel formula | MATLAB transcription | Notes |
|---|---|---|---|---|
| `5. Buyer Profile!B5` | Chipset | `='0. Rack Profile'!B6` | `bp.chipset = rp.chipset_type;` |  |
| `5. Buyer Profile!B6` | Cooling method | `='0. Rack Profile'!B17` | `bp.cooling_method = rp.cooling_method;` |  |
| `5. Buyer Profile!B7` | GPUs per module | `='0. Rack Profile'!B39` | `bp.gpus_per_module = rp.gpus_per_module;` |  |
| `5. Buyer Profile!B8` | Module IT capacity (kW) | `='0. Rack Profile'!B40` | `bp.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| `5. Buyer Profile!B14` | Process name | `=IFERROR(INDEX('12. Process Library'!A:A,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.process_name = iferror(process.name, "-");` | IFERROR guard |
| `5. Buyer Profile!B15` | Size category | `=IFERROR(INDEX('12. Process Library'!B:B,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.size_category = iferror(process.size_category, "-");` | IFERROR guard |
| `5. Buyer Profile!B16` | Required temperature (°C) | `=IFERROR(INDEX('12. Process Library'!$C$4:$C$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.required_temperature_c = iferror(process.required_temp_c, "");` | IFERROR guard |
| `5. Buyer Profile!B17` | Heat demand (kWth) | `=IFERROR(INDEX('12. Process Library'!$D$4:$D$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.heat_demand_kwth = iferror(process.heat_demand_kwth, "");` | IFERROR guard |
| `5. Buyer Profile!B18` | Operating hours/year | `=IFERROR(INDEX('12. Process Library'!$E$4:$E$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.operating_hours_per_year = iferror(process.operating_hours_per_year, "");` | IFERROR guard |
| `5. Buyer Profile!B19` | Notes | `=IFERROR(INDEX('12. Process Library'!F:F,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.notes = iferror(process.notes, "-");` | IFERROR guard |
| `5. Buyer Profile!B20` | Source: | `=IFERROR(INDEX('12. Process Library'!$H$4:$H$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.source = iferror(process.source, "");` | IFERROR guard |
| `5. Buyer Profile!B21` | Source URL: | `=IFERROR(INDEX('12. Process Library'!$J$4:$J$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.source_url = iferror(process.source_url, "");` | IFERROR guard |
| `5. Buyer Profile!B24` | Annual heat demand (MWh) | `=B17*B18/1000` | `bp.annual_heat_demand_mwh = bp.heat_demand_kwth*bp.operating_hours_per_year/1000;` |  |
| `5. Buyer Profile!B25` | Process ΔT (°C) | `=IFERROR(INDEX('12. Process Library'!$I$4:$I$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),10)` | `bp.process_delta_t_c = iferror(process.delta_t_c, 10);` | IFERROR guard |
| `5. Buyer Profile!B26` | Required flow rate (m³/hr) | `=B17/(4.18*B25)*3.6` | `bp.required_flow_rate_m3_per_hr = bp.heat_demand_kwth/(4.18*bp.process_deltat_c)*3.6;` |  |
| `5. Buyer Profile!B29` | Module thermal capacity (kWth) | `='1. Module Criteria'!B21` | `bp.module_thermal_capacity_kwth = mc.thermal_output_kwth;` |  |
| `5. Buyer Profile!B30` | Module delivery temp (°C) | `='1. Module Criteria'!B22` | `bp.module_delivery_temp_c = mc.delivery_temperature_c;` |  |
| `5. Buyer Profile!B31` | Module flow capacity (m³/hr) | `='4. Module Flow'!B26` | `bp.module_flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;` |  |
| `5. Buyer Profile!B33` | Temperature compatible? | `=IF(B30>=B16,"YES","NO - need higher temp")` | `bp.temperature_compatible = ifelse(bp.module_delivery_temp_c>=bp.required_temperature_c,"YES","NO - need higher temp");` |  |
| `5. Buyer Profile!B34` | Modules needed (thermal) | `=ROUNDUP(B17/B29,0)` | `bp.modules_needed_thermal = roundup(bp.heat_demand_kwth/bp.module_thermal_capacity_kwth,0);` | rounding |
| `5. Buyer Profile!B35` | Modules if flow-constrained (reference) | `=ROUNDUP(B26/B31,0)` | `bp.modules_if_flow_constrained_reference = roundup(bp.required_flow_rate_m3_per_hr/bp.module_flow_capacity_m3_per_hr,0);` | rounding |
| `5. Buyer Profile!B36` | MODULES REQUIRED | `=B34` | `bp.modules_required = bp.modules_needed_thermal;` |  |
| `5. Buyer Profile!B37` | Flow deficit (m³/hr) | `=MAX(0,B26-B36*B31)` | `bp.flow_deficit_m3_per_hr = max(0,bp.required_flow_rate_m3_per_hr-bp.modules_required*bp.module_flow_capacity_m3_per_hr);` |  |
| `5. Buyer Profile!B38` | Flow ratio (buyer/system) | `=IF(B36*B31>0,B26/(B36*B31),0)` | `bp.flow_ratio_buyer_per_system = ifelse(bp.modules_required*bp.module_flow_capacity_m3_per_hr>0,bp.required_flow_rate_m3_per_hr/(bp.modules_required*bp.module_flow_capacity_m3_per_hr),0);` |  |
| `5. Buyer Profile!B41` | System thermal capacity (kWth) | `=B36*B29` | `bp.system_thermal_capacity_kwth = bp.modules_required*bp.module_thermal_capacity_kwth;` |  |
| `5. Buyer Profile!B42` | System flow capacity (m³/hr) | `=B36*B31` | `bp.system_flow_capacity_m3_per_hr = bp.modules_required*bp.module_flow_capacity_m3_per_hr;` |  |
| `5. Buyer Profile!B43` | Thermal utilisation (%) | `=B17/B41` | `bp.thermal_utilisation_pct = bp.heat_demand_kwth/bp.system_thermal_capacity_kwth;` |  |
| `5. Buyer Profile!B44` | Flow utilisation (%) | `=IF(B88>0,B26/B88,B26/B42)` | `bp.flow_utilisation_pct = ifelse(bp.augmented_system_flow_m3_per_hr>0,bp.required_flow_rate_m3_per_hr/bp.augmented_system_flow_m3_per_hr,bp.required_flow_rate_m3_per_hr/bp.system_flow_capacity_m3_per_hr);` |  |
| `5. Buyer Profile!B45` | Hydraulic augmentation needed? | `=IF(B38>1,"YES - flow ratio "&ROUND(B38,2)&"x","NO")` | `bp.hydraulic_augmentation_needed = string(ifelse(bp.flow_ratio_buyer_per_system>1,"YES - flow ratio ") + string(round(bp.flow_ratio_buyer_per_system,2)) + string("x","NO"));` | text concat |
| `5. Buyer Profile!B48` | System heat generation (kWth) | `=B41` | `bp.system_heat_generation_kwth = bp.system_thermal_capacity_kwth;` |  |
| `5. Buyer Profile!B49` | Buyer heat absorption (kWth) | `=MIN(B17,B41)` | `bp.buyer_heat_absorption_kwth = min(bp.heat_demand_kwth,bp.system_thermal_capacity_kwth);` |  |
| `5. Buyer Profile!B50` | Excess heat (kWth) | `=MAX(0,B48-B49)` | `bp.excess_heat_kwth = max(0,bp.system_heat_generation_kwth-bp.buyer_heat_absorption_kwth);` |  |
| `5. Buyer Profile!B51` | Excess heat (%) | `=IF(B48>0,B50/B48,0)` | `bp.excess_heat_pct = ifelse(bp.system_heat_generation_kwth>0,bp.excess_heat_kwth/bp.system_heat_generation_kwth,0);` |  |
| `5. Buyer Profile!B52` | Heat rejection required? | `=IF(B50>0,"YES - "&ROUND(B50,0)&" kWth rejection needed","NO - full utilisation")` | `bp.heat_rejection_required = string(ifelse(bp.excess_heat_kwth>0,"YES - ") + string(round(bp.excess_heat_kwth,0)) + string(" kWth rejection needed","NO - full utilisation"));` | text concat |
| `5. Buyer Profile!B53` | Rejection method | `=IF(B50=0,"-",IF(B50<'11. Reference Data'!B15,"Dry cooler",IF(B50<'11. Reference Data'!B16,"Adiabatic cooler","Cooling tower")))` | `bp.rejection_method = ifelse(bp.excess_heat_kwth==0,"-",ifelse(bp.excess_heat_kwth<ref.dry_cooler_max_kwth,"Dry cooler",ifelse(bp.excess_heat_kwth<ref.adiabatic_cooler_max_kwth,"Adiabatic cooler","Cooling tower")));` |  |
| `5. Buyer Profile!B54` | Rejection capacity required (kWth) | `=B50` | `bp.rejection_capacity_required_kwth = bp.excess_heat_kwth;` |  |
| `5. Buyer Profile!B55` | Rejection capex rate (£/kWth) | `=IF(B53="-",0,IF(B53="Dry cooler",'11. Reference Data'!C10,IF(B53="Adiabatic cooler",'11. Reference Data'!C11,IF(B53="Cooling tower",'11. Reference Data'!C12,0))))` | `bp.rejection_capex_rate_gbp_per_kwth = ifelse(bp.rejection_method=="-",0,ifelse(bp.rejection_method=="Dry cooler",ref.dry_cooler__capex_gbp_per_kwth,ifelse(bp.rejection_method=="Adiabatic cooler",ref.adiabatic_cooler__capex_gbp_per_kwth,ifelse(bp.rejection_method=="Cooling tower",ref.cooling_tower__capex_gbp_per_kwth,0))));` |  |
| `5. Buyer Profile!B56` | Rejection opex rate (£/kWth/yr) | `=IF(B53="-",0,IF(B53="Dry cooler",'11. Reference Data'!D10,IF(B53="Adiabatic cooler",'11. Reference Data'!D11,IF(B53="Cooling tower",'11. Reference Data'!D12,0))))` | `bp.rejection_opex_rate_gbp_per_kwth_per_yr = ifelse(bp.rejection_method=="-",0,ifelse(bp.rejection_method=="Dry cooler",ref.dry_cooler__opex_gbp_per_kwth_per_yr,ifelse(bp.rejection_method=="Adiabatic cooler",ref.adiabatic_cooler__opex_gbp_per_kwth_per_yr,ifelse(bp.rejection_method=="Cooling tower",ref.cooling_tower__opex_gbp_per_kwth_per_yr,0))));` |  |
| `5. Buyer Profile!B57` | Rejection capex (£) | `=B54*B55` | `bp.rejection_capex_gbp = bp.rejection_capacity_required_kwth*bp.rejection_capex_rate_gbp_per_kwth;` |  |
| `5. Buyer Profile!B58` | Annual rejection opex (£/yr) | `=B54*B56` | `bp.annual_rejection_opex_gbp_per_yr = bp.rejection_capacity_required_kwth*bp.rejection_opex_rate_gbp_per_kwth_per_yr;` |  |
| `5. Buyer Profile!B66` | Total modules required | `=B36` | `bp.total_modules_required = bp.modules_required;` |  |
| `5. Buyer Profile!B67` | Total IT capacity (kW) | `=B36*'1. Module Criteria'!B5` | `bp.total_it_capacity_kw = bp.modules_required*mc.module_it_capacity_kw;` |  |
| `5. Buyer Profile!B68` | Total rack units (42U racks @ 10kW) | `=ROUNDUP(B67/10,0)` | `bp.total_rack_units_42u_racks_10kw = roundup(bp.total_it_capacity_kw/10,0);` | rounding |
| `5. Buyer Profile!B71` | Heat pump required? | `=IF(B16>'1. Module Criteria'!B12,"YES","NO - direct heat sufficient")` | `bp.heat_pump_required = ifelse(bp.required_temperature_c>mc.capture_temperature_c,"YES","NO - direct heat sufficient");` |  |
| `5. Buyer Profile!B72` | Temperature lift required (K) | `=IF(B16>'1. Module Criteria'!B12,B16-'1. Module Criteria'!B12,0)` | `bp.temperature_lift_required_k = ifelse(bp.required_temperature_c>mc.capture_temperature_c,bp.required_temperature_c-mc.capture_temperature_c,0);` |  |
| `5. Buyer Profile!B73` | Heat pump units | `=B36` | `bp.heat_pump_units = bp.modules_required;` |  |
| `5. Buyer Profile!B74` | Total HP capacity (kWth) | `=B36*'1. Module Criteria'!B18` | `bp.total_hp_capacity_kwth = bp.modules_required*mc.heat_pump_capacity_kwth;` |  |
| `5. Buyer Profile!B75` | HP electrical demand (kW) | `=IF(OR(NOT(ISNUMBER('1. Module Criteria'!B17)),'1. Module Criteria'!B17<=1),0,B41/'1. Module Criteria'!B17)` | `bp.hp_electrical_demand_kw = ifelse(or_(not_(isnumber(mc.heat_pump_cop)),mc.heat_pump_cop<=1),0,bp.system_thermal_capacity_kwth/mc.heat_pump_cop);` | ISNUMBER guard |
| `5. Buyer Profile!B78` | Source loop pumps | `=B36` | `bp.source_loop_pumps = bp.modules_required;` |  |
| `5. Buyer Profile!B79` | Sink loop pumps | `=B36` | `bp.sink_loop_pumps = bp.modules_required;` |  |
| `5. Buyer Profile!B80` | Total system flow (m³/hr) | `=B42` | `bp.total_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr;` |  |
| `5. Buyer Profile!B81` | Header pipe size estimate (DN) | `=IF(B42<10,"DN50",IF(B42<25,"DN65",IF(B42<50,"DN80",IF(B42<100,"DN100","DN125+"))))` | `bp.header_pipe_size_estimate_dn = ifelse(bp.system_flow_capacity_m3_per_hr<10,"dn50",ifelse(bp.system_flow_capacity_m3_per_hr<25,"dn65",ifelse(bp.system_flow_capacity_m3_per_hr<50,"dn80",ifelse(bp.system_flow_capacity_m3_per_hr<100,"dn100","dn125+"))));` |  |
| `5. Buyer Profile!B82` | Buffer tank recommended? | `=IF(B36>2,"YES - system balancing","OPTIONAL")` | `bp.buffer_tank_recommended = ifelse(bp.modules_required>2,"YES - system balancing","OPTIONAL");` |  |
| `5. Buyer Profile!B83` | Flow augmentation pump (m³/hr) | `=B37` | `bp.flow_augmentation_pump_m3_per_hr = bp.flow_deficit_m3_per_hr;` |  |
| `5. Buyer Profile!B84` | Mixing valve required? | `=IF(B37>0,"YES","NO")` | `bp.mixing_valve_required = ifelse(bp.flow_deficit_m3_per_hr>0,"YES","NO");` |  |
| `5. Buyer Profile!B85` | Augmentation pump power (kW) | `=B87*'11. Reference Data'!B121` | `bp.augmentation_pump_power_kw = bp.augmentation_pump_capacity_m3_per_hr*ref.augmentation_pump_power_kw_per_m3_per_hr;` |  |
| `5. Buyer Profile!B86` | Augmentation pumps required | `=IF(B37>0,ROUNDUP(B37/'11. Reference Data'!B124,0),0)` | `bp.augmentation_pumps_required = ifelse(bp.flow_deficit_m3_per_hr>0,roundup(bp.flow_deficit_m3_per_hr/ref.standard_augmentation_pump_capacity_m3_per_hr,0),0);` | rounding |
| `5. Buyer Profile!B87` | Augmentation pump capacity (m³/hr) | `=B86*'11. Reference Data'!B124` | `bp.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pumps_required*ref.standard_augmentation_pump_capacity_m3_per_hr;` |  |
| `5. Buyer Profile!B88` | Augmented system flow (m³/hr) | `=B42+B87` | `bp.augmented_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr+bp.augmentation_pump_capacity_m3_per_hr;` |  |
| `5. Buyer Profile!B89` | Flow requirement met? | `=IF(B88>=B26,"YES","NO - shortfall of "&ROUND(B26-B88,1)&" m³/hr")` | `bp.flow_requirement_met = string(ifelse(bp.augmented_system_flow_m3_per_hr>=bp.required_flow_rate_m3_per_hr,"YES","NO - shortfall of ") + string(round(bp.required_flow_rate_m3_per_hr-bp.augmented_system_flow_m3_per_hr,1)) + string(" m³/hr"));` | text concat |
| `5. Buyer Profile!B93` | IT load (kW) | `=B67` | `bp.it_load_kw = bp.total_it_capacity_kw;` |  |
| `5. Buyer Profile!B94` | Cooling infrastructure (kW) | `=B67*'1. Module Criteria'!B7*0.05` | `bp.cooling_infrastructure_kw = bp.total_it_capacity_kw*mc.target_utilisation_rate_pct*0.05;` |  |
| `5. Buyer Profile!B95` | Heat pump load (kW) | `=B75` | `bp.heat_pump_load_kw = bp.hp_electrical_demand_kw;` |  |
| `5. Buyer Profile!B96` | Total electrical demand (kW) | `=B93+B94+B95` | `bp.total_electrical_demand_kw = bp.it_load_kw+bp.cooling_infrastructure_kw+bp.heat_pump_load_kw;` |  |
| `5. Buyer Profile!B97` | Grid connection (kVA @ 0.9 PF) | `=ROUNDUP(B96/0.9,-1)` | `bp.grid_connection_kva_0_9_pf = roundup(bp.total_electrical_demand_kw/0.9,-1);` | rounding |
| `5. Buyer Profile!B101` | Total module footprint (m²) | `=B36*B100` | `bp.total_module_footprint_m = bp.modules_required*bp.module_footprint_each_m;` |  |
| `5. Buyer Profile!B102` | Plant room allowance (m²) | `=IF(B36>2,25,15)` | `bp.plant_room_allowance_m = ifelse(bp.modules_required>2,25,15);` |  |
| `5. Buyer Profile!B103` | Total site area (m²) | `=B101+B102` | `bp.total_site_area_m = bp.total_module_footprint_m+bp.plant_room_allowance_m;` |  |
| `5. Buyer Profile!B107` | Modular DC units (250kW IT) | `=B36` | `bp.modular_dc_units_250kw_it = bp.modules_required;` |  |
| `5. Buyer Profile!B108` | Heat pump units | `=B73` | `bp.heat_pump_units__b108 = bp.heat_pump_units;` |  |
| `5. Buyer Profile!B109` | 42U server racks | `=B68` | `bp.42u_server_racks = bp.total_rack_units_42u_racks_10kw;` |  |
| `5. Buyer Profile!B110` | Source circulation pumps | `=B78` | `bp.source_circulation_pumps = bp.source_loop_pumps;` |  |
| `5. Buyer Profile!B111` | Sink circulation pumps | `=B79` | `bp.sink_circulation_pumps = bp.sink_loop_pumps;` |  |
| `5. Buyer Profile!B112` | Plate heat exchangers | `=B36` | `bp.plate_heat_exchangers = bp.modules_required;` |  |
| `5. Buyer Profile!B113` | Buffer tank | `=IF(B82="YES - system balancing",1,0)` | `bp.buffer_tank = ifelse(bp.buffer_tank_recommended=="YES - system balancing",1,0);` |  |
| `5. Buyer Profile!B115` | Flow augmentation pumps | `=B86` | `bp.flow_augmentation_pumps = bp.augmentation_pumps_required;` |  |
| `5. Buyer Profile!B116` | Mixing valves | `=IF(B86>0,1,0)` | `bp.mixing_valves = ifelse(bp.augmentation_pumps_required>0,1,0);` |  |

## Validation Criteria

- Default process `Pasteurisation - Medium` matches Excel for all Buyer Profile outputs.
- Test at least 3 additional processes spanning low ΔT (flow-heavy) and high ΔT (thermal-heavy).

