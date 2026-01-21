# Phase 3 — Rack Profile

## Scope

- Implement `0. Rack Profile` sheet calculations in `tribe.calc.calcRackProfile`.

## Dependencies

- Phase 2: `ReferenceData` (chipsets, cooling methods, HP η/min/max).

## Inputs

- `chipset` (string) — corresponds to `0. Rack Profile!B6`
- `cooling_method` (string) — corresponds to `0. Rack Profile!B17`
- `module_it_target` (double, kW) — corresponds to `0. Rack Profile!B36`
- `electricity_price` (double, £/kWh) — corresponds to `0. Rack Profile!B58`
- `annual_hours` (double, hours/yr) — corresponds to `0. Rack Profile!B67`

## Output

- `rp` struct matching the `RackProfile` field inventory in `02_architecture.md`.

## Formula Transcription List

| Sheet!Cell | Label | Excel formula | MATLAB transcription | Notes |
|---|---|---|---|---|
| `0. Rack Profile!B9` | TDP per chip (W) | `=IF(B6="NVIDIA H100",700,IF(B6="NVIDIA H200",700,IF(B6="NVIDIA B200",1000,IF(B6="AMD MI300X",750,IF(B6="Intel Gaudi 3",600,500)))))` | `rp.tdp_per_chip_w = ifelse(rp.chipset_type=="NVIDIA H100",700,ifelse(rp.chipset_type=="NVIDIA H200",700,ifelse(rp.chipset_type=="NVIDIA B200",1000,ifelse(rp.chipset_type=="AMD MI300X",750,ifelse(rp.chipset_type=="Intel Gaudi 3",600,500)))));` |  |
| `0. Rack Profile!B10` | Chips per server | `=IF(B6="NVIDIA H100",8,IF(B6="NVIDIA H200",8,IF(B6="NVIDIA B200",8,IF(B6="AMD MI300X",8,IF(B6="Intel Gaudi 3",8,8)))))` | `rp.chips_per_server = ifelse(rp.chipset_type=="NVIDIA H100",8,ifelse(rp.chipset_type=="NVIDIA H200",8,ifelse(rp.chipset_type=="NVIDIA B200",8,ifelse(rp.chipset_type=="AMD MI300X",8,ifelse(rp.chipset_type=="Intel Gaudi 3",8,8)))));` |  |
| `0. Rack Profile!B11` | Server power (kW) | `=B9*B10/1000*1.15` | `rp.server_power_kw = rp.tdp_per_chip_w*rp.chips_per_server/1000*1.15;` |  |
| `0. Rack Profile!B12` | Max junction temp (°C) | `=IF(B6="NVIDIA H100",83,IF(B6="NVIDIA H200",83,IF(B6="NVIDIA B200",85,IF(B6="AMD MI300X",90,IF(B6="Intel Gaudi 3",95,85)))))` | `rp.max_junction_temp_c = ifelse(rp.chipset_type=="NVIDIA H100",83,ifelse(rp.chipset_type=="NVIDIA H200",83,ifelse(rp.chipset_type=="NVIDIA B200",85,ifelse(rp.chipset_type=="AMD MI300X",90,ifelse(rp.chipset_type=="Intel Gaudi 3",95,85)))));` |  |
| `0. Rack Profile!B13` | Recommended coolant inlet (°C) | `=B12-25` | `rp.recommended_coolant_inlet_c = rp.max_junction_temp_c-25;` |  |
| `0. Rack Profile!B20` | Heat capture rate (%) | `=IF(B17="Direct-to-Chip (DTC)",0.75,IF(B17="Single-Phase Immersion",0.95,IF(B17="Two-Phase Immersion",0.98,IF(B17="Rear Door Heat Exchanger",0.5,0.05))))` | `rp.heat_capture_rate_pct = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",0.75,ifelse(rp.cooling_method=="Single-Phase Immersion",0.95,ifelse(rp.cooling_method=="Two-Phase Immersion",0.98,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",0.5,0.05))));` |  |
| `0. Rack Profile!B21` | Capture temperature (°C) | `=IF(B17="Direct-to-Chip (DTC)",57.5,IF(B17="Single-Phase Immersion",50,IF(B17="Two-Phase Immersion",55,IF(B17="Rear Door Heat Exchanger",45,35))))` | `rp.capture_temperature_c = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",57.5,ifelse(rp.cooling_method=="Single-Phase Immersion",50,ifelse(rp.cooling_method=="Two-Phase Immersion",55,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",45,35))));` |  |
| `0. Rack Profile!B22` | Coolant type | `=IF(B17="Direct-to-Chip (DTC)","Water/Glycol",IF(B17="Single-Phase Immersion","Dielectric fluid",IF(B17="Two-Phase Immersion","Fluorocarbon",IF(B17="Rear Door Heat Exchanger","Water/Glycol","Air"))))` | `rp.coolant_type = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)","Water/Glycol",ifelse(rp.cooling_method=="Single-Phase Immersion","Dielectric fluid",ifelse(rp.cooling_method=="Two-Phase Immersion","Fluorocarbon",ifelse(rp.cooling_method=="Rear Door Heat Exchanger","Water/Glycol","Air"))));` |  |
| `0. Rack Profile!B23` | PUE contribution | `=IF(B17="Direct-to-Chip (DTC)",1.05,IF(B17="Single-Phase Immersion",1.03,IF(B17="Two-Phase Immersion",1.02,IF(B17="Rear Door Heat Exchanger",1.1,1.4))))` | `rp.pue_contribution = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",1.05,ifelse(rp.cooling_method=="Single-Phase Immersion",1.03,ifelse(rp.cooling_method=="Two-Phase Immersion",1.02,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",1.1,1.4))));` |  |
| `0. Rack Profile!B24` | Capex premium vs air-cooled (%) | `=IF(B17="Direct-to-Chip (DTC)",15,IF(B17="Single-Phase Immersion",25,IF(B17="Two-Phase Immersion",40,IF(B17="Rear Door Heat Exchanger",10,0))))` | `rp.capex_premium_vs_air_cooled_pct = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",15,ifelse(rp.cooling_method=="Single-Phase Immersion",25,ifelse(rp.cooling_method=="Two-Phase Immersion",40,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",10,0))));` |  |
| `0. Rack Profile!B25` | Rack thermal limit (kW/rack) | `=IF(B17="Direct-to-Chip (DTC)",80,IF(B17="Single-Phase Immersion",100,IF(B17="Two-Phase Immersion",120,IF(B17="Rear Door Heat Exchanger",40,20))))` | `rp.rack_thermal_limit_kw_per_rack = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",80,ifelse(rp.cooling_method=="Single-Phase Immersion",100,ifelse(rp.cooling_method=="Two-Phase Immersion",120,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",40,20))));` |  |
| `0. Rack Profile!B29` | Servers per rack | `=ROUNDDOWN(B25/B11,0)` | `rp.servers_per_rack = rounddown(rp.rack_thermal_limit_kw_per_rack/rp.server_power_kw,0);` | rounding |
| `0. Rack Profile!B30` | GPUs per rack | `=B29*B10` | `rp.gpus_per_rack = rp.servers_per_rack*rp.chips_per_server;` |  |
| `0. Rack Profile!B31` | Actual rack power (kW) | `=B29*B11` | `rp.actual_rack_power_kw = rp.servers_per_rack*rp.server_power_kw;` |  |
| `0. Rack Profile!B32` | Rack thermal utilisation (%) | `=B31/B25` | `rp.rack_thermal_utilisation_pct = rp.actual_rack_power_kw/rp.rack_thermal_limit_kw_per_rack;` |  |
| `0. Rack Profile!B37` | Racks per module | `=ROUNDUP(B36/B31,0)` | `rp.racks_per_module = roundup(rp.module_it_capacity_target_kw/rp.actual_rack_power_kw,0);` | rounding |
| `0. Rack Profile!B38` | Servers per module | `=B37*B29` | `rp.servers_per_module = rp.racks_per_module*rp.servers_per_rack;` |  |
| `0. Rack Profile!B39` | GPUs per module | `=B37*B30` | `rp.gpus_per_module = rp.racks_per_module*rp.gpus_per_rack;` |  |
| `0. Rack Profile!B40` | Actual module IT capacity (kW) | `=B37*B31` | `rp.actual_module_it_capacity_kw = rp.racks_per_module*rp.actual_rack_power_kw;` |  |
| `0. Rack Profile!B43` | Captured heat (kWth) | `=B40*B20` | `rp.captured_heat_kwth = rp.actual_module_it_capacity_kw*rp.heat_capture_rate_pct;` |  |
| `0. Rack Profile!B44` | Capture temperature (°C) | `=B21` | `rp.capture_temperature_c__b44 = rp.capture_temperature_c;` |  |
| `0. Rack Profile!B45` | Residual heat to air (kWth) | `=B40*(1-B20)` | `rp.residual_heat_to_air_kwth = rp.actual_module_it_capacity_kw*(1-rp.heat_capture_rate_pct);` |  |
| `0. Rack Profile!B49` | Heat capture quality | `=IF(B21>=55,"HIGH - Suitable for process heat",IF(B21>=45,"MEDIUM - District heating suitable","LOW - Limited applications"))` | `rp.heat_capture_quality = ifelse(rp.capture_temperature_c>=55,"HIGH - Suitable for process heat",ifelse(rp.capture_temperature_c>=45,"MEDIUM - District heating suitable","LOW - Limited applications"));` |  |
| `0. Rack Profile!B50` | Heat pump requirement | `=IF(B21>=70,"Optional - direct use possible",IF(B21>=50,"Recommended for industrial use","Required for most applications"))` | `rp.heat_pump_requirement = ifelse(rp.capture_temperature_c>=70,"Optional - direct use possible",ifelse(rp.capture_temperature_c>=50,"Recommended for industrial use","Required for most applications"));` |  |
| `0. Rack Profile!B51` | Recommended HP output (°C) | `=IF(B21>=70,B21,IF(B21>=50,90,80))` | `rp.recommended_hp_output_c = ifelse(rp.capture_temperature_c>=70,rp.capture_temperature_c,ifelse(rp.capture_temperature_c>=50,90,80));` |  |
| `0. Rack Profile!B52` | Estimated COP at recommended output | `=IF(B50="Optional - direct use possible","-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B51+273.15)/(B51-B21),2))))` | `rp.estimated_cop_at_recommended_output = ifelse(rp.heat_pump_requirement=="Optional - direct use possible","-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(rp.recommended_hp_output_c+273.15)/(rp.recommended_hp_output_c-rp.capture_temperature_c),2))));` |  |
| `0. Rack Profile!B57` | Target output temperature (°C) | `=B51` | `rp.target_output_temperature_c = rp.recommended_hp_output_c;` |  |
| `0. Rack Profile!B60` | Temperature lift (K) | `=B57-B21` | `rp.temperature_lift_k = rp.target_output_temperature_c-rp.capture_temperature_c;` |  |
| `0. Rack Profile!B61` | COP at this lift | `=IF(B60<=0,"-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B57+273.15)/B60,2))))` | `rp.cop_at_this_lift = ifelse(rp.temperature_lift_k<=0,"-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(rp.target_output_temperature_c+273.15)/rp.temperature_lift_k,2))));` |  |
| `0. Rack Profile!B62` | HP electricity per kWth captured | `=IF(B61="-","-",ROUND(1/(B61-1),3))` | `rp.hp_electricity_per_kwth_captured = ifelse(rp.cop_at_this_lift=="-","-",round(1/(rp.cop_at_this_lift-1),3));` |  |
| `0. Rack Profile!B63` | Total heat output (per kW IT) | `=IF(B61="-",B20,ROUND(B20*B61/(B61-1),3))` | `rp.total_heat_output_per_kw_it = ifelse(rp.cop_at_this_lift=="-",rp.heat_capture_rate_pct,round(rp.heat_capture_rate_pct*rp.cop_at_this_lift/(rp.cop_at_this_lift-1),3));` |  |
| `0. Rack Profile!B64` | HP electricity cost (£/kWth·hr) | `=IF(B62="-","-",ROUND(B62*B58,4))` | `rp.hp_electricity_cost_gbp_per_kwth_hr = ifelse(rp.hp_electricity_per_kwth_captured=="-","-",round(rp.hp_electricity_per_kwth_captured*rp.electricity_price_gbp_per_kwh,4));` |  |
| `0. Rack Profile!B68` | Heat delivered (MWh/yr) | `=IF(B63="-","-",ROUND(B40*B63*B67/1000,0))` | `rp.heat_delivered_mwh_per_yr = ifelse(rp.total_heat_output_per_kw_it=="-","-",round(rp.actual_module_it_capacity_kw*rp.total_heat_output_per_kw_it*rp.annual_operating_hours/1000,0));` |  |
| `0. Rack Profile!B69` | HP electricity (MWh/yr) | `=IF(B62="-",0,ROUND(B43*B62*B67/1000,0))` | `rp.hp_electricity_mwh_per_yr = ifelse(rp.hp_electricity_per_kwth_captured=="-",0,round(rp.captured_heat_kwth*rp.hp_electricity_per_kwth_captured*rp.annual_operating_hours/1000,0));` |  |
| `0. Rack Profile!B70` | HP electricity cost (£/yr) | `=B69*1000*B58` | `rp.hp_electricity_cost_gbp_per_yr = rp.hp_electricity_mwh_per_yr*1000*rp.electricity_price_gbp_per_kwh;` |  |

## Validation Criteria

- Reproduce all `0. Rack Profile` formula cell results for the default workbook inputs.
- Include edge-case guards for temperature lift ≤ 0 and COP bounds (min/max from Reference Data).

