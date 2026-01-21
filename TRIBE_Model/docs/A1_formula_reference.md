# Formula Reference (All Sheets)

This is a complete catalog of every Excel formula cell in `Tribe_model_20.1.26.xlsx`.

Notes:
- `MATLAB transcription` is a best-effort mechanical transcription for implementation guidance (not drop-in code).
- Whole-column `INDEX(...A:A...)` patterns are best implemented via `ProcessLibrary.getProcess()`.

## Summary

### Formula Counts by Sheet

| Sheet | # formulas |
|---|---:|
| 0. Rack Profile | 35 |
| 1. Module Criteria | 10 |
| 2. Module Capex | 46 |
| 3. Module Opex | 10 |
| 4. Module Flow | 20 |
| 5. Buyer Profile | 77 |
| 6. System Capex | 31 |
| 7. System Opex | 22 |
| 8. System Flow | 32 |
| 9. System P&L | 36 |
| 11. Reference Data | 12 |

### Formula Types

| Type | # formulas |
|---|---:|
| arithmetic | 215 |
| conditional | 77 |
| rounding | 14 |
| aggregation | 12 |
| lookup | 9 |
| math | 3 |
| text | 1 |

## Full Catalog

| # | Sheet!Cell | Label | Type | Excel formula | MATLAB transcription | Notes |
|---:|---|---|---|---|---|---|
| 1 | `0. Rack Profile!B10` | Chips per server | conditional | `=IF(B6="NVIDIA H100",8,IF(B6="NVIDIA H200",8,IF(B6="NVIDIA B200",8,IF(B6="AMD MI300X",8,IF(B6="Intel Gaudi 3",8,8)))))` | `rp.chips_per_server = ifelse(rp.chipset_type=="NVIDIA H100",8,ifelse(rp.chipset_type=="NVIDIA H200",8,ifelse(rp.chipset_type=="NVIDIA B200",8,ifelse(rp.chipset_type=="AMD MI300X",8,ifelse(rp.chipset_type=="Intel Gaudi 3",8,8)))));` |  |
| 2 | `0. Rack Profile!B11` | Server power (kW) | arithmetic | `=B9*B10/1000*1.15` | `rp.server_power_kw = rp.tdp_per_chip_w*rp.chips_per_server/1000*1.15;` |  |
| 3 | `0. Rack Profile!B12` | Max junction temp (°C) | conditional | `=IF(B6="NVIDIA H100",83,IF(B6="NVIDIA H200",83,IF(B6="NVIDIA B200",85,IF(B6="AMD MI300X",90,IF(B6="Intel Gaudi 3",95,85)))))` | `rp.max_junction_temp_c = ifelse(rp.chipset_type=="NVIDIA H100",83,ifelse(rp.chipset_type=="NVIDIA H200",83,ifelse(rp.chipset_type=="NVIDIA B200",85,ifelse(rp.chipset_type=="AMD MI300X",90,ifelse(rp.chipset_type=="Intel Gaudi 3",95,85)))));` |  |
| 4 | `0. Rack Profile!B13` | Recommended coolant inlet (°C) | arithmetic | `=B12-25` | `rp.recommended_coolant_inlet_c = rp.max_junction_temp_c-25;` |  |
| 5 | `0. Rack Profile!B20` | Heat capture rate (%) | conditional | `=IF(B17="Direct-to-Chip (DTC)",0.75,IF(B17="Single-Phase Immersion",0.95,IF(B17="Two-Phase Immersion",0.98,IF(B17="Rear Door Heat Exchanger",0.5,0.05))))` | `rp.heat_capture_rate_pct = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",0.75,ifelse(rp.cooling_method=="Single-Phase Immersion",0.95,ifelse(rp.cooling_method=="Two-Phase Immersion",0.98,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",0.5,0.05))));` |  |
| 6 | `0. Rack Profile!B21` | Capture temperature (°C) | conditional | `=IF(B17="Direct-to-Chip (DTC)",57.5,IF(B17="Single-Phase Immersion",50,IF(B17="Two-Phase Immersion",55,IF(B17="Rear Door Heat Exchanger",45,35))))` | `rp.capture_temperature_c = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",57.5,ifelse(rp.cooling_method=="Single-Phase Immersion",50,ifelse(rp.cooling_method=="Two-Phase Immersion",55,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",45,35))));` |  |
| 7 | `0. Rack Profile!B22` | Coolant type | conditional | `=IF(B17="Direct-to-Chip (DTC)","Water/Glycol",IF(B17="Single-Phase Immersion","Dielectric fluid",IF(B17="Two-Phase Immersion","Fluorocarbon",IF(B17="Rear Door Heat Exchanger","Water/Glycol","Air"))))` | `rp.coolant_type = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)","Water/Glycol",ifelse(rp.cooling_method=="Single-Phase Immersion","Dielectric fluid",ifelse(rp.cooling_method=="Two-Phase Immersion","Fluorocarbon",ifelse(rp.cooling_method=="Rear Door Heat Exchanger","Water/Glycol","Air"))));` |  |
| 8 | `0. Rack Profile!B23` | PUE contribution | conditional | `=IF(B17="Direct-to-Chip (DTC)",1.05,IF(B17="Single-Phase Immersion",1.03,IF(B17="Two-Phase Immersion",1.02,IF(B17="Rear Door Heat Exchanger",1.1,1.4))))` | `rp.pue_contribution = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",1.05,ifelse(rp.cooling_method=="Single-Phase Immersion",1.03,ifelse(rp.cooling_method=="Two-Phase Immersion",1.02,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",1.1,1.4))));` |  |
| 9 | `0. Rack Profile!B24` | Capex premium vs air-cooled (%) | conditional | `=IF(B17="Direct-to-Chip (DTC)",15,IF(B17="Single-Phase Immersion",25,IF(B17="Two-Phase Immersion",40,IF(B17="Rear Door Heat Exchanger",10,0))))` | `rp.capex_premium_vs_air_cooled_pct = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",15,ifelse(rp.cooling_method=="Single-Phase Immersion",25,ifelse(rp.cooling_method=="Two-Phase Immersion",40,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",10,0))));` |  |
| 10 | `0. Rack Profile!B25` | Rack thermal limit (kW/rack) | conditional | `=IF(B17="Direct-to-Chip (DTC)",80,IF(B17="Single-Phase Immersion",100,IF(B17="Two-Phase Immersion",120,IF(B17="Rear Door Heat Exchanger",40,20))))` | `rp.rack_thermal_limit_kw_per_rack = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",80,ifelse(rp.cooling_method=="Single-Phase Immersion",100,ifelse(rp.cooling_method=="Two-Phase Immersion",120,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",40,20))));` |  |
| 11 | `0. Rack Profile!B29` | Servers per rack | rounding | `=ROUNDDOWN(B25/B11,0)` | `rp.servers_per_rack = rounddown(rp.rack_thermal_limit_kw_per_rack/rp.server_power_kw,0);` | rounding |
| 12 | `0. Rack Profile!B30` | GPUs per rack | arithmetic | `=B29*B10` | `rp.gpus_per_rack = rp.servers_per_rack*rp.chips_per_server;` |  |
| 13 | `0. Rack Profile!B31` | Actual rack power (kW) | arithmetic | `=B29*B11` | `rp.actual_rack_power_kw = rp.servers_per_rack*rp.server_power_kw;` |  |
| 14 | `0. Rack Profile!B32` | Rack thermal utilisation (%) | arithmetic | `=B31/B25` | `rp.rack_thermal_utilisation_pct = rp.actual_rack_power_kw/rp.rack_thermal_limit_kw_per_rack;` |  |
| 15 | `0. Rack Profile!B37` | Racks per module | rounding | `=ROUNDUP(B36/B31,0)` | `rp.racks_per_module = roundup(rp.module_it_capacity_target_kw/rp.actual_rack_power_kw,0);` | rounding |
| 16 | `0. Rack Profile!B38` | Servers per module | arithmetic | `=B37*B29` | `rp.servers_per_module = rp.racks_per_module*rp.servers_per_rack;` |  |
| 17 | `0. Rack Profile!B39` | GPUs per module | arithmetic | `=B37*B30` | `rp.gpus_per_module = rp.racks_per_module*rp.gpus_per_rack;` |  |
| 18 | `0. Rack Profile!B40` | Actual module IT capacity (kW) | arithmetic | `=B37*B31` | `rp.actual_module_it_capacity_kw = rp.racks_per_module*rp.actual_rack_power_kw;` |  |
| 19 | `0. Rack Profile!B43` | Captured heat (kWth) | arithmetic | `=B40*B20` | `rp.captured_heat_kwth = rp.actual_module_it_capacity_kw*rp.heat_capture_rate_pct;` |  |
| 20 | `0. Rack Profile!B44` | Capture temperature (°C) | arithmetic | `=B21` | `rp.capture_temperature_c__b44 = rp.capture_temperature_c;` |  |
| 21 | `0. Rack Profile!B45` | Residual heat to air (kWth) | arithmetic | `=B40*(1-B20)` | `rp.residual_heat_to_air_kwth = rp.actual_module_it_capacity_kw*(1-rp.heat_capture_rate_pct);` |  |
| 22 | `0. Rack Profile!B49` | Heat capture quality | conditional | `=IF(B21>=55,"HIGH - Suitable for process heat",IF(B21>=45,"MEDIUM - District heating suitable","LOW - Limited applications"))` | `rp.heat_capture_quality = ifelse(rp.capture_temperature_c>=55,"HIGH - Suitable for process heat",ifelse(rp.capture_temperature_c>=45,"MEDIUM - District heating suitable","LOW - Limited applications"));` |  |
| 23 | `0. Rack Profile!B50` | Heat pump requirement | conditional | `=IF(B21>=70,"Optional - direct use possible",IF(B21>=50,"Recommended for industrial use","Required for most applications"))` | `rp.heat_pump_requirement = ifelse(rp.capture_temperature_c>=70,"Optional - direct use possible",ifelse(rp.capture_temperature_c>=50,"Recommended for industrial use","Required for most applications"));` |  |
| 24 | `0. Rack Profile!B51` | Recommended HP output (°C) | conditional | `=IF(B21>=70,B21,IF(B21>=50,90,80))` | `rp.recommended_hp_output_c = ifelse(rp.capture_temperature_c>=70,rp.capture_temperature_c,ifelse(rp.capture_temperature_c>=50,90,80));` |  |
| 25 | `0. Rack Profile!B52` | Estimated COP at recommended output | conditional | `=IF(B50="Optional - direct use possible","-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B51+273.15)/(B51-B21),2))))` | `rp.estimated_cop_at_recommended_output = ifelse(rp.heat_pump_requirement=="Optional - direct use possible","-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(rp.recommended_hp_output_c+273.15)/(rp.recommended_hp_output_c-rp.capture_temperature_c),2))));` |  |
| 26 | `0. Rack Profile!B57` | Target output temperature (°C) | arithmetic | `=B51` | `rp.target_output_temperature_c = rp.recommended_hp_output_c;` |  |
| 27 | `0. Rack Profile!B60` | Temperature lift (K) | arithmetic | `=B57-B21` | `rp.temperature_lift_k = rp.target_output_temperature_c-rp.capture_temperature_c;` |  |
| 28 | `0. Rack Profile!B61` | COP at this lift | conditional | `=IF(B60<=0,"-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B57+273.15)/B60,2))))` | `rp.cop_at_this_lift = ifelse(rp.temperature_lift_k<=0,"-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(rp.target_output_temperature_c+273.15)/rp.temperature_lift_k,2))));` |  |
| 29 | `0. Rack Profile!B62` | HP electricity per kWth captured | conditional | `=IF(B61="-","-",ROUND(1/(B61-1),3))` | `rp.hp_electricity_per_kwth_captured = ifelse(rp.cop_at_this_lift=="-","-",round(1/(rp.cop_at_this_lift-1),3));` |  |
| 30 | `0. Rack Profile!B63` | Total heat output (per kW IT) | conditional | `=IF(B61="-",B20,ROUND(B20*B61/(B61-1),3))` | `rp.total_heat_output_per_kw_it = ifelse(rp.cop_at_this_lift=="-",rp.heat_capture_rate_pct,round(rp.heat_capture_rate_pct*rp.cop_at_this_lift/(rp.cop_at_this_lift-1),3));` |  |
| 31 | `0. Rack Profile!B64` | HP electricity cost (£/kWth·hr) | conditional | `=IF(B62="-","-",ROUND(B62*B58,4))` | `rp.hp_electricity_cost_gbp_per_kwth_hr = ifelse(rp.hp_electricity_per_kwth_captured=="-","-",round(rp.hp_electricity_per_kwth_captured*rp.electricity_price_gbp_per_kwh,4));` |  |
| 32 | `0. Rack Profile!B68` | Heat delivered (MWh/yr) | conditional | `=IF(B63="-","-",ROUND(B40*B63*B67/1000,0))` | `rp.heat_delivered_mwh_per_yr = ifelse(rp.total_heat_output_per_kw_it=="-","-",round(rp.actual_module_it_capacity_kw*rp.total_heat_output_per_kw_it*rp.annual_operating_hours/1000,0));` |  |
| 33 | `0. Rack Profile!B69` | HP electricity (MWh/yr) | conditional | `=IF(B62="-",0,ROUND(B43*B62*B67/1000,0))` | `rp.hp_electricity_mwh_per_yr = ifelse(rp.hp_electricity_per_kwth_captured=="-",0,round(rp.captured_heat_kwth*rp.hp_electricity_per_kwth_captured*rp.annual_operating_hours/1000,0));` |  |
| 34 | `0. Rack Profile!B70` | HP electricity cost (£/yr) | arithmetic | `=B69*1000*B58` | `rp.hp_electricity_cost_gbp_per_yr = rp.hp_electricity_mwh_per_yr*1000*rp.electricity_price_gbp_per_kwh;` |  |
| 35 | `0. Rack Profile!B9` | TDP per chip (W) | conditional | `=IF(B6="NVIDIA H100",700,IF(B6="NVIDIA H200",700,IF(B6="NVIDIA B200",1000,IF(B6="AMD MI300X",750,IF(B6="Intel Gaudi 3",600,500)))))` | `rp.tdp_per_chip_w = ifelse(rp.chipset_type=="NVIDIA H100",700,ifelse(rp.chipset_type=="NVIDIA H200",700,ifelse(rp.chipset_type=="NVIDIA B200",1000,ifelse(rp.chipset_type=="AMD MI300X",750,ifelse(rp.chipset_type=="Intel Gaudi 3",600,500)))));` |  |
| 36 | `1. Module Criteria!B10` | Heat capture rate (%) | arithmetic | `='0. Rack Profile'!B20` | `mc.heat_capture_rate_pct = rp.heat_capture_rate_pct;` |  |
| 37 | `1. Module Criteria!B11` | Captured heat (kWth) | arithmetic | `=B5*B10` | `mc.captured_heat_kwth = mc.module_it_capacity_kw*mc.heat_capture_rate_pct;` |  |
| 38 | `1. Module Criteria!B12` | Capture temperature (°C) | arithmetic | `='0. Rack Profile'!B21` | `mc.capture_temperature_c = rp.capture_temperature_c;` |  |
| 39 | `1. Module Criteria!B17` | Heat pump COP | conditional | `=IF(B15=0,"-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B16+273.15)/(B16-B12),2))))` | `mc.heat_pump_cop = ifelse(mc.heat_pump_enabled==0,"-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(mc.heat_pump_output_temperature_c+273.15)/(mc.heat_pump_output_temperature_c-mc.capture_temperature_c),2))));` |  |
| 40 | `1. Module Criteria!B18` | Heat pump capacity (kWth) | arithmetic | `=B11` | `mc.heat_pump_capacity_kwth = mc.captured_heat_kwth;` |  |
| 41 | `1. Module Criteria!B21` | Thermal output (kWth) | conditional | `=IF(B15=1,IF(B17<=1,B11,B11*B17/(B17-1)),B11)` | `mc.thermal_output_kwth = ifelse(mc.heat_pump_enabled==1,ifelse(mc.heat_pump_cop<=1,mc.captured_heat_kwth,mc.captured_heat_kwth*mc.heat_pump_cop/(mc.heat_pump_cop-1)),mc.captured_heat_kwth);` |  |
| 42 | `1. Module Criteria!B22` | Delivery temperature (°C) | conditional | `=IF(B15=1,B16,B12)` | `mc.delivery_temperature_c = ifelse(mc.heat_pump_enabled==1,mc.heat_pump_output_temperature_c,mc.capture_temperature_c);` |  |
| 43 | `1. Module Criteria!B24` | Annual heat output (MWh) | arithmetic | `=B21*B23*B7/1000` | `mc.annual_heat_output_mwh = mc.thermal_output_kwth*mc.hours_per_year*mc.target_utilisation_rate_pct/1000;` |  |
| 44 | `1. Module Criteria!B29` | Effective heat price (£/MWh) | conditional | `=IF(B15=1,B28,B27)` | `mc.effective_heat_price_gbp_per_mwh = ifelse(mc.heat_pump_enabled==1,mc.premium_heat_price_with_hp_gbp_per_mwh,mc.base_heat_price_no_hp_gbp_per_mwh);` |  |
| 45 | `1. Module Criteria!B5` | Module IT capacity (kW) | arithmetic | `='0. Rack Profile'!B40` | `mc.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| 46 | `2. Module Capex!B10` | Captured heat (kWth) | arithmetic | `='0. Rack Profile'!B43` | `mcapex.captured_heat_kwth = rp.captured_heat_kwth;` |  |
| 47 | `2. Module Capex!B13` | Container shell | arithmetic | `='11. Reference Data'!B71` | `mcapex.container_shell = ref.container_shell_40ft;` |  |
| 48 | `2. Module Capex!B14` | Container fit-out | arithmetic | `='11. Reference Data'!B72` | `mcapex.container_fit_out = ref.container_fit_out_electrical_hvac_prep;` |  |
| 49 | `2. Module Capex!B15` | Rack enclosures | arithmetic | `=B7*'11. Reference Data'!B73` | `mcapex.rack_enclosures = mcapex.racks_per_module*ref.rack_enclosure_42u_enclosed;` |  |
| 50 | `2. Module Capex!B16` | SUBTOTAL: ENCLOSURE | aggregation | `=SUM(B13:B15)` | `mcapex.subtotal_enclosure = sum([mcapex.container_shell, mcapex.container_fit_out, mcapex.rack_enclosures]);` |  |
| 51 | `2. Module Capex!B19` | Cold plate kits | conditional | `=IF(B6="Direct-to-Chip (DTC)",B8*'11. Reference Data'!B76,0)` | `mcapex.cold_plate_kits = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.servers_per_module*ref.cold_plate_kit_per_server,0);` |  |
| 52 | `2. Module Capex!B20` | CDU (base) | conditional | `=IF(B6="Direct-to-Chip (DTC)",'11. Reference Data'!B77,0)` | `mcapex.cdu_base = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",ref.cdu_coolant_distribution_unit,0);` |  |
| 53 | `2. Module Capex!B21` | CDU (capacity scaling) | conditional | `=IF(B6="Direct-to-Chip (DTC)",B9*'11. Reference Data'!B78,0)` | `mcapex.cdu_capacity_scaling = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.module_it_capacity_kw*ref.cdu_capacity_scaling,0);` |  |
| 54 | `2. Module Capex!B22` | Manifolds & quick-connects | conditional | `=IF(B6="Direct-to-Chip (DTC)",B8*'11. Reference Data'!B79,0)` | `mcapex.manifolds_quick_connects = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.servers_per_module*ref.manifolds_quick_connects,0);` |  |
| 55 | `2. Module Capex!B23` | Primary loop piping | conditional | `=IF(B6="Direct-to-Chip (DTC)",'11. Reference Data'!B80,0)` | `mcapex.primary_loop_piping = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",ref.primary_loop_piping,0);` |  |
| 56 | `2. Module Capex!B24` | SUBTOTAL: DTC COOLING | aggregation | `=SUM(B19:B23)` | `mcapex.subtotal_dtc_cooling = sum([mcapex.cold_plate_kits, mcapex.cdu_base, mcapex.cdu_capacity_scaling, mcapex.manifolds_quick_connects, mcapex.primary_loop_piping]);` |  |
| 57 | `2. Module Capex!B27` | Immersion tanks | conditional | `=IF(B6="Single-Phase Immersion",B7*'11. Reference Data'!B83,IF(B6="Two-Phase Immersion",B7*'11. Reference Data'!B84,0))` | `mcapex.immersion_tanks = ifelse(mcapex.cooling_method=="Single-Phase Immersion",mcapex.racks_per_module*ref.single_phase_immersion_tank,ifelse(mcapex.cooling_method=="Two-Phase Immersion",mcapex.racks_per_module*ref.two_phase_immersion_tank,0));` |  |
| 58 | `2. Module Capex!B28` | Dielectric fluid (initial fill) | conditional | `=IF(B6="Single-Phase Immersion",B7*'11. Reference Data'!B87*'11. Reference Data'!B85,IF(B6="Two-Phase Immersion",B7*'11. Reference Data'!B88*'11. Reference Data'!B86,0))` | `mcapex.dielectric_fluid_initial_fill = ifelse(mcapex.cooling_method=="Single-Phase Immersion",mcapex.racks_per_module*ref.fluid_volume_per_rack_single_phase*ref.dielectric_fluid_single_phase,ifelse(mcapex.cooling_method=="Two-Phase Immersion",mcapex.racks_per_module*ref.fluid_volume_per_rack_two_phase*ref.dielectric_fluid_two_phase,0));` |  |
| 59 | `2. Module Capex!B29` | Fluid management system | conditional | `=IF(OR(B6="Single-Phase Immersion",B6="Two-Phase Immersion"),'11. Reference Data'!B89,0)` | `mcapex.fluid_management_system = ifelse(or(mcapex.cooling_method=="Single-Phase Immersion",mcapex.cooling_method=="Two-Phase Immersion"),ref.fluid_management_system,0);` |  |
| 60 | `2. Module Capex!B30` | SUBTOTAL: IMMERSION COOLING | aggregation | `=SUM(B27:B29)` | `mcapex.subtotal_immersion_cooling = sum([mcapex.immersion_tanks, mcapex.dielectric_fluid_initial_fill, mcapex.fluid_management_system]);` |  |
| 61 | `2. Module Capex!B33` | Rack PDUs | arithmetic | `=B7*'11. Reference Data'!B92` | `mcapex.rack_pdus = mcapex.racks_per_module*ref.high_density_pdu_per_rack;` |  |
| 62 | `2. Module Capex!B34` | Module power distribution | arithmetic | `=B9*'11. Reference Data'!B93` | `mcapex.module_power_distribution = mcapex.module_it_capacity_kw*ref.module_power_distribution;` |  |
| 63 | `2. Module Capex!B35` | Electrical panels & switchgear | arithmetic | `='11. Reference Data'!B94` | `mcapex.electrical_panels_switchgear = ref.electrical_panels_switchgear;` |  |
| 64 | `2. Module Capex!B36` | SUBTOTAL: POWER | aggregation | `=SUM(B33:B35)` | `mcapex.subtotal_power = sum([mcapex.rack_pdus, mcapex.module_power_distribution, mcapex.electrical_panels_switchgear]);` |  |
| 65 | `2. Module Capex!B39` | Primary heat exchanger (base) | arithmetic | `='11. Reference Data'!B97` | `mcapex.primary_heat_exchanger_base = ref.primary_heat_exchanger;` |  |
| 66 | `2. Module Capex!B40` | Heat exchanger (capacity scaling) | arithmetic | `=B10*'11. Reference Data'!B98` | `mcapex.heat_exchanger_capacity_scaling = mcapex.captured_heat_kwth*ref.heat_exchanger_scaling;` |  |
| 67 | `2. Module Capex!B41` | Thermal integration skid | arithmetic | `='11. Reference Data'!B99` | `mcapex.thermal_integration_skid = ref.thermal_integration_skid_pumps_valves;` |  |
| 68 | `2. Module Capex!B42` | Instrumentation & sensors | arithmetic | `='11. Reference Data'!B100` | `mcapex.instrumentation_sensors = ref.instrumentation_sensors;` |  |
| 69 | `2. Module Capex!B43` | SUBTOTAL: THERMAL | aggregation | `=SUM(B39:B42)` | `mcapex.subtotal_thermal = sum([mcapex.primary_heat_exchanger_base, mcapex.heat_exchanger_capacity_scaling, mcapex.thermal_integration_skid, mcapex.instrumentation_sensors]);` |  |
| 70 | `2. Module Capex!B46` | BMS base system | arithmetic | `='11. Reference Data'!B103` | `mcapex.bms_base_system = ref.bms_base_system;` |  |
| 71 | `2. Module Capex!B47` | Per-rack monitoring | arithmetic | `=B7*'11. Reference Data'!B104` | `mcapex.per_rack_monitoring = mcapex.racks_per_module*ref.per_rack_monitoring;` |  |
| 72 | `2. Module Capex!B48` | Network infrastructure | arithmetic | `='11. Reference Data'!B105` | `mcapex.network_infrastructure = ref.network_infrastructure;` |  |
| 73 | `2. Module Capex!B49` | SUBTOTAL: MONITORING | aggregation | `=SUM(B46:B48)` | `mcapex.subtotal_monitoring = sum([mcapex.bms_base_system, mcapex.per_rack_monitoring, mcapex.network_infrastructure]);` |  |
| 74 | `2. Module Capex!B5` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `mcapex.chipset = rp.chipset_type;` |  |
| 75 | `2. Module Capex!B53` | Heat pump unit | conditional | `=IF('1. Module Criteria'!B15=1,'1. Module Criteria'!B18*B52,0)` | `mcapex.heat_pump_unit = ifelse(mc.heat_pump_enabled==1,mc.heat_pump_capacity_kwth*mcapex.heat_pump_capex_rate_gbp_per_kwth,0);` |  |
| 76 | `2. Module Capex!B54` | Heat pump installation | conditional | `=IF('1. Module Criteria'!B15=1,B53*0.15,0)` | `mcapex.heat_pump_installation = ifelse(mc.heat_pump_enabled==1,mcapex.heat_pump_unit*0.15,0);` |  |
| 77 | `2. Module Capex!B55` | Heat pump controls | conditional | `=IF('1. Module Criteria'!B15=1,15000,0)` | `mcapex.heat_pump_controls = ifelse(mc.heat_pump_enabled==1,15000,0);` |  |
| 78 | `2. Module Capex!B56` | SUBTOTAL: HEAT PUMP | aggregation | `=SUM(B53:B55)` | `mcapex.subtotal_heat_pump = sum([mcapex.heat_pump_unit, mcapex.heat_pump_installation, mcapex.heat_pump_controls]);` |  |
| 79 | `2. Module Capex!B59` | Premium rate (%) | arithmetic | `='0. Rack Profile'!B24/100` | `mcapex.premium_rate_pct = rp.capex_premium_vs_air_cooled_pct/100;` |  |
| 80 | `2. Module Capex!B6` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `mcapex.cooling_method = rp.cooling_method;` |  |
| 81 | `2. Module Capex!B60` | Applied to base infrastructure | arithmetic | `=(B16+B24+B30)*B59` | `mcapex.applied_to_base_infrastructure = (mcapex.subtotal_enclosure+mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling)*mcapex.premium_rate_pct;` |  |
| 82 | `2. Module Capex!B63` | Base infrastructure | arithmetic | `=B16+B24+B30+B36+B43+B49` | `mcapex.base_infrastructure = mcapex.subtotal_enclosure+mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling+mcapex.subtotal_power+mcapex.subtotal_thermal+mcapex.subtotal_monitoring;` |  |
| 83 | `2. Module Capex!B64` | Cooling premium | arithmetic | `=B60` | `mcapex.cooling_premium = mcapex.applied_to_base_infrastructure;` |  |
| 84 | `2. Module Capex!B65` | Heat pump | arithmetic | `=B56` | `mcapex.heat_pump = mcapex.subtotal_heat_pump;` |  |
| 85 | `2. Module Capex!B66` | TOTAL MODULE CAPEX | arithmetic | `=B63+B64+B65` | `mcapex.total_module_capex = mcapex.base_infrastructure+mcapex.cooling_premium+mcapex.heat_pump;` |  |
| 86 | `2. Module Capex!B68` | Capex per IT kW (£/kW) | arithmetic | `=B66/B9` | `mcapex.capex_per_it_kw_gbp_per_kw = mcapex.total_module_capex/mcapex.module_it_capacity_kw;` |  |
| 87 | `2. Module Capex!B69` | Capex per GPU (£/GPU) | arithmetic | `=B66/('0. Rack Profile'!B39)` | `mcapex.capex_per_gpu_gbp_per_gpu = mcapex.total_module_capex/(rp.gpus_per_module);` |  |
| 88 | `2. Module Capex!B7` | Racks per module | arithmetic | `='0. Rack Profile'!B37` | `mcapex.racks_per_module = rp.racks_per_module;` |  |
| 89 | `2. Module Capex!B8` | Servers per module | arithmetic | `='0. Rack Profile'!B38` | `mcapex.servers_per_module = rp.servers_per_module;` |  |
| 90 | `2. Module Capex!B9` | Module IT capacity (kW) | arithmetic | `='0. Rack Profile'!B40` | `mcapex.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| 91 | `2. Module Capex!C15` | Rack enclosures | text | `=B7&" racks × £"&'11. Reference Data'!B73` | `mcapex.rack_enclosures__fixed_per_module = string(mcapex.racks_per_module) + " racks × £" + string(ref.rack_enclosure_42u_enclosed);` | text concat |
| 92 | `3. Module Opex!B10` | SUBTOTAL: ELECTRICITY | arithmetic | `=B7+B9` | `mopex.subtotal_electricity = mopex.infrastructure_power_cost_gbp_per_yr+mopex.heat_pump_electricity_gbp_per_yr;` |  |
| 93 | `3. Module Opex!B16` | Base maintenance (£/yr) | arithmetic | `='2. Module Capex'!B63*B15` | `mopex.base_maintenance_gbp_per_yr = mcapex.base_infrastructure*mopex.base_maintenance_pct_of_base_capex;` |  |
| 94 | `3. Module Opex!B18` | Heat pump maintenance (£/yr) | conditional | `=IF('1. Module Criteria'!B15=1,'2. Module Capex'!B53*B17,0)` | `mopex.heat_pump_maintenance_gbp_per_yr = ifelse(mc.heat_pump_enabled==1,mcapex.heat_pump_unit*mopex.heat_pump_maintenance_pct_of_hp_capex,0);` |  |
| 95 | `3. Module Opex!B20` | Insurance (£/yr) | arithmetic | `='2. Module Capex'!B66*B19` | `mopex.insurance_gbp_per_yr = mcapex.total_module_capex*mopex.insurance_pct_of_total_capex;` |  |
| 96 | `3. Module Opex!B21` | SUBTOTAL: MAINTENANCE & INSURANCE | arithmetic | `=B16+B18+B20` | `mopex.subtotal_maintenance_insurance = mopex.base_maintenance_gbp_per_yr+mopex.heat_pump_maintenance_gbp_per_yr+mopex.insurance_gbp_per_yr;` |  |
| 97 | `3. Module Opex!B27` | SUBTOTAL: OTHER | aggregation | `=SUM(B24:B26)` | `mopex.subtotal_other = sum([mopex.site_lease_per_licence_gbp_per_yr, mopex.remote_monitoring_noc_gbp_per_yr, mopex.connectivity_admin_gbp_per_yr]);` |  |
| 98 | `3. Module Opex!B29` | TOTAL MODULE OPEX (£/yr) | arithmetic | `=B10+B21+B27` | `mopex.total_module_opex_gbp_per_yr = mopex.subtotal_electricity+mopex.subtotal_maintenance_insurance+mopex.subtotal_other;` |  |
| 99 | `3. Module Opex!B6` | Infrastructure power (from PUE) | arithmetic | `='0. Rack Profile'!B23-1` | `mopex.infrastructure_power_from_pue = rp.pue_contribution-1;` |  |
| 100 | `3. Module Opex!B7` | Infrastructure power cost (£/yr) | arithmetic | `='1. Module Criteria'!B5*B6*'1. Module Criteria'!B23*B5*'1. Module Criteria'!B7` | `mopex.infrastructure_power_cost_gbp_per_yr = mc.module_it_capacity_kw*mopex.infrastructure_power_from_pue*mc.hours_per_year*mopex.electricity_rate_gbp_per_kwh*mc.target_utilisation_rate_pct;` |  |
| 101 | `3. Module Opex!B9` | Heat pump electricity (£/yr) | conditional | `=IF('1. Module Criteria'!B15=1,('1. Module Criteria'!B21/'1. Module Criteria'!B17)*'1. Module Criteria'!B23*'1. Module Criteria'!B7*B5,0)` | `mopex.heat_pump_electricity_gbp_per_yr = ifelse(mc.heat_pump_enabled==1,(mc.thermal_output_kwth/mc.heat_pump_cop)*mc.hours_per_year*mc.target_utilisation_rate_pct*mopex.electricity_rate_gbp_per_kwh,0);` |  |
| 102 | `4. Module Flow!B10` | Inlet temperature (°C) | arithmetic | `='1. Module Criteria'!B12` | `mflow.inlet_temperature_c = mc.capture_temperature_c;` |  |
| 103 | `4. Module Flow!B11` | Source loop ΔT (°C) | conditional | `=IF('0. Rack Profile'!B17="Direct-to-Chip (DTC)",'11. Reference Data'!E23,IF('0. Rack Profile'!B17="Single-Phase Immersion",'11. Reference Data'!E24,IF('0. Rack Profile'!B17="Two-Phase Immersion",'11. Reference Data'!E25,IF('0. Rack Profile'!B17="Rear Door Heat Exchanger",'11. Reference Data'!E26,'11. Reference Data'!E27))))` | `mflow.source_loop_deltat_c = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",ref.direct_to_chip_dtc__source_deltat_c,ifelse(rp.cooling_method=="Single-Phase Immersion",ref.single_phase_immersion__source_deltat_c,ifelse(rp.cooling_method=="Two-Phase Immersion",ref.two_phase_immersion__source_deltat_c,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",ref.rear_door_heat_exchanger__source_deltat_c,ref.air_cooled_reference__source_deltat_c))));` |  |
| 104 | `4. Module Flow!B12` | Outlet temperature (°C) | arithmetic | `=B10-B11` | `mflow.outlet_temperature_c = mflow.inlet_temperature_c-mflow.source_loop_deltat_c;` |  |
| 105 | `4. Module Flow!B14` | Mass flow rate (kg/s) | arithmetic | `=B9/(B5*B11)` | `mflow.mass_flow_rate_kg_per_s = mflow.thermal_power_kwth/(mflow.specific_heat_of_water_kj_per_kg_k*mflow.source_loop_deltat_c);` |  |
| 106 | `4. Module Flow!B15` | Volume flow rate (L/s) | arithmetic | `=B14/B6` | `mflow.volume_flow_rate_l_per_s = mflow.mass_flow_rate_kg_per_s/mflow.water_density_kg_per_l;` |  |
| 107 | `4. Module Flow!B16` | Volume flow rate (m³/hr) | arithmetic | `=B15*3.6` | `mflow.volume_flow_rate_m3_per_hr = mflow.volume_flow_rate_l_per_s*3.6;` |  |
| 108 | `4. Module Flow!B19` | Thermal power delivered (kWth) | arithmetic | `='1. Module Criteria'!B21` | `mflow.thermal_power_delivered_kwth = mc.thermal_output_kwth;` |  |
| 109 | `4. Module Flow!B20` | Outlet temperature (°C) | arithmetic | `='1. Module Criteria'!B22` | `mflow.outlet_temperature_c__b20 = mc.delivery_temperature_c;` |  |
| 110 | `4. Module Flow!B22` | Return temperature (°C) | arithmetic | `=B20-B21` | `mflow.return_temperature_c = mflow.outlet_temperature_c__b20-mflow.sink_loop_deltat_c;` |  |
| 111 | `4. Module Flow!B24` | Mass flow rate (kg/s) | arithmetic | `=B19/(B5*B21)` | `mflow.mass_flow_rate_kg_per_s__b24 = mflow.thermal_power_delivered_kwth/(mflow.specific_heat_of_water_kj_per_kg_k*mflow.sink_loop_deltat_c);` |  |
| 112 | `4. Module Flow!B25` | Volume flow rate (L/s) | arithmetic | `=B24/B6` | `mflow.volume_flow_rate_l_per_s__b25 = mflow.mass_flow_rate_kg_per_s__b24/mflow.water_density_kg_per_l;` |  |
| 113 | `4. Module Flow!B26` | Volume flow rate (m³/hr) | arithmetic | `=B25*3.6` | `mflow.volume_flow_rate_m3_per_hr__b26 = mflow.volume_flow_rate_l_per_s__b25*3.6;` |  |
| 114 | `4. Module Flow!B30` | Source loop pipe ID (mm) | math | `=SQRT((B15/1000)/(B29*3.14159/4))*1000` | `mflow.source_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s/1000)/(mflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| 115 | `4. Module Flow!B31` | Sink loop pipe ID (mm) | math | `=SQRT((B25/1000)/(B29*3.14159/4))*1000` | `mflow.sink_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s__b25/1000)/(mflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| 116 | `4. Module Flow!B33` | Source loop - nearest DN | conditional | `=IF(B30<28,"DN25",IF(B30<36,"DN32",IF(B30<42,"DN40",IF(B30<54,"DN50",IF(B30<68,"DN65",IF(B30<82,"DN80",IF(B30<107,"DN100","DN125+")))))))` | `mflow.source_loop_nearest_dn = ifelse(mflow.source_loop_pipe_id_mm<28,"DN25",ifelse(mflow.source_loop_pipe_id_mm<36,"DN32",ifelse(mflow.source_loop_pipe_id_mm<42,"DN40",ifelse(mflow.source_loop_pipe_id_mm<54,"DN50",ifelse(mflow.source_loop_pipe_id_mm<68,"DN65",ifelse(mflow.source_loop_pipe_id_mm<82,"DN80",ifelse(mflow.source_loop_pipe_id_mm<107,"DN100","DN125+")))))));` |  |
| 117 | `4. Module Flow!B34` | Sink loop - nearest DN | conditional | `=IF(B31<28,"DN25",IF(B31<36,"DN32",IF(B31<42,"DN40",IF(B31<54,"DN50",IF(B31<68,"DN65",IF(B31<82,"DN80",IF(B31<107,"DN100","DN125+")))))))` | `mflow.sink_loop_nearest_dn = ifelse(mflow.sink_loop_pipe_id_mm<28,"DN25",ifelse(mflow.sink_loop_pipe_id_mm<36,"DN32",ifelse(mflow.sink_loop_pipe_id_mm<42,"DN40",ifelse(mflow.sink_loop_pipe_id_mm<54,"DN50",ifelse(mflow.sink_loop_pipe_id_mm<68,"DN65",ifelse(mflow.sink_loop_pipe_id_mm<82,"DN80",ifelse(mflow.sink_loop_pipe_id_mm<107,"DN100","DN125+")))))));` |  |
| 118 | `4. Module Flow!B37` | Thermal capacity (kWth) | arithmetic | `=B19` | `mflow.thermal_capacity_kwth = mflow.thermal_power_delivered_kwth;` |  |
| 119 | `4. Module Flow!B38` | Delivery temperature (°C) | arithmetic | `=B20` | `mflow.delivery_temperature_c = mflow.outlet_temperature_c__b20;` |  |
| 120 | `4. Module Flow!B39` | Flow capacity (m³/hr) | arithmetic | `=B26` | `mflow.flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;` |  |
| 121 | `4. Module Flow!B9` | Thermal power (kWth) | arithmetic | `='1. Module Criteria'!B11` | `mflow.thermal_power_kwth = mc.captured_heat_kwth;` |  |
| 122 | `5. Buyer Profile!B101` | Total module footprint (m²) | arithmetic | `=B36*B100` | `bp.total_module_footprint_m = bp.modules_required*bp.module_footprint_each_m;` |  |
| 123 | `5. Buyer Profile!B102` | Plant room allowance (m²) | conditional | `=IF(B36>2,25,15)` | `bp.plant_room_allowance_m = ifelse(bp.modules_required>2,25,15);` |  |
| 124 | `5. Buyer Profile!B103` | Total site area (m²) | arithmetic | `=B101+B102` | `bp.total_site_area_m = bp.total_module_footprint_m+bp.plant_room_allowance_m;` |  |
| 125 | `5. Buyer Profile!B107` | Modular DC units (250kW IT) | arithmetic | `=B36` | `bp.modular_dc_units_250kw_it = bp.modules_required;` |  |
| 126 | `5. Buyer Profile!B108` | Heat pump units | arithmetic | `=B73` | `bp.heat_pump_units__b108 = bp.heat_pump_units;` |  |
| 127 | `5. Buyer Profile!B109` | 42U server racks | arithmetic | `=B68` | `bp.42u_server_racks = bp.total_rack_units_42u_racks_10kw;` |  |
| 128 | `5. Buyer Profile!B110` | Source circulation pumps | arithmetic | `=B78` | `bp.source_circulation_pumps = bp.source_loop_pumps;` |  |
| 129 | `5. Buyer Profile!B111` | Sink circulation pumps | arithmetic | `=B79` | `bp.sink_circulation_pumps = bp.sink_loop_pumps;` |  |
| 130 | `5. Buyer Profile!B112` | Plate heat exchangers | arithmetic | `=B36` | `bp.plate_heat_exchangers = bp.modules_required;` |  |
| 131 | `5. Buyer Profile!B113` | Buffer tank | conditional | `=IF(B82="YES - system balancing",1,0)` | `bp.buffer_tank = ifelse(bp.buffer_tank_recommended=="YES - system balancing",1,0);` |  |
| 132 | `5. Buyer Profile!B115` | Flow augmentation pumps | arithmetic | `=B86` | `bp.flow_augmentation_pumps = bp.augmentation_pumps_required;` |  |
| 133 | `5. Buyer Profile!B116` | Mixing valves | conditional | `=IF(B86>0,1,0)` | `bp.mixing_valves = ifelse(bp.augmentation_pumps_required>0,1,0);` |  |
| 134 | `5. Buyer Profile!B14` | Process name | lookup | `=IFERROR(INDEX('12. Process Library'!A:A,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.process_name = iferror(process.name, "-");` | IFERROR guard |
| 135 | `5. Buyer Profile!B15` | Size category | lookup | `=IFERROR(INDEX('12. Process Library'!B:B,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.size_category = iferror(process.size_category, "-");` | IFERROR guard |
| 136 | `5. Buyer Profile!B16` | Required temperature (°C) | lookup | `=IFERROR(INDEX('12. Process Library'!$C$4:$C$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.required_temperature_c = iferror(process.required_temp_c, "");` | IFERROR guard |
| 137 | `5. Buyer Profile!B17` | Heat demand (kWth) | lookup | `=IFERROR(INDEX('12. Process Library'!$D$4:$D$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.heat_demand_kwth = iferror(process.heat_demand_kwth, "");` | IFERROR guard |
| 138 | `5. Buyer Profile!B18` | Operating hours/year | lookup | `=IFERROR(INDEX('12. Process Library'!$E$4:$E$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.operating_hours_per_year = iferror(process.operating_hours_per_year, "");` | IFERROR guard |
| 139 | `5. Buyer Profile!B19` | Notes | lookup | `=IFERROR(INDEX('12. Process Library'!F:F,MATCH(B11,'12. Process Library'!G:G,0)),"-")` | `bp.notes = iferror(process.notes, "-");` | IFERROR guard |
| 140 | `5. Buyer Profile!B20` | Source: | lookup | `=IFERROR(INDEX('12. Process Library'!$H$4:$H$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.source = iferror(process.source, "");` | IFERROR guard |
| 141 | `5. Buyer Profile!B21` | Source URL: | lookup | `=IFERROR(INDEX('12. Process Library'!$J$4:$J$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),"")` | `bp.source_url = iferror(process.source_url, "");` | IFERROR guard |
| 142 | `5. Buyer Profile!B24` | Annual heat demand (MWh) | arithmetic | `=B17*B18/1000` | `bp.annual_heat_demand_mwh = bp.heat_demand_kwth*bp.operating_hours_per_year/1000;` |  |
| 143 | `5. Buyer Profile!B25` | Process ΔT (°C) | lookup | `=IFERROR(INDEX('12. Process Library'!$I$4:$I$45,MATCH(B11,'12. Process Library'!$G$4:$G$45,0)),10)` | `bp.process_delta_t_c = iferror(process.delta_t_c, 10);` | IFERROR guard |
| 144 | `5. Buyer Profile!B26` | Required flow rate (m³/hr) | arithmetic | `=B17/(4.18*B25)*3.6` | `bp.required_flow_rate_m3_per_hr = bp.heat_demand_kwth/(4.18*bp.process_deltat_c)*3.6;` |  |
| 145 | `5. Buyer Profile!B29` | Module thermal capacity (kWth) | arithmetic | `='1. Module Criteria'!B21` | `bp.module_thermal_capacity_kwth = mc.thermal_output_kwth;` |  |
| 146 | `5. Buyer Profile!B30` | Module delivery temp (°C) | arithmetic | `='1. Module Criteria'!B22` | `bp.module_delivery_temp_c = mc.delivery_temperature_c;` |  |
| 147 | `5. Buyer Profile!B31` | Module flow capacity (m³/hr) | arithmetic | `='4. Module Flow'!B26` | `bp.module_flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;` |  |
| 148 | `5. Buyer Profile!B33` | Temperature compatible? | conditional | `=IF(B30>=B16,"YES","NO - need higher temp")` | `bp.temperature_compatible = ifelse(bp.module_delivery_temp_c>=bp.required_temperature_c,"YES","NO - need higher temp");` |  |
| 149 | `5. Buyer Profile!B34` | Modules needed (thermal) | rounding | `=ROUNDUP(B17/B29,0)` | `bp.modules_needed_thermal = roundup(bp.heat_demand_kwth/bp.module_thermal_capacity_kwth,0);` | rounding |
| 150 | `5. Buyer Profile!B35` | Modules if flow-constrained (reference) | rounding | `=ROUNDUP(B26/B31,0)` | `bp.modules_if_flow_constrained_reference = roundup(bp.required_flow_rate_m3_per_hr/bp.module_flow_capacity_m3_per_hr,0);` | rounding |
| 151 | `5. Buyer Profile!B36` | MODULES REQUIRED | arithmetic | `=B34` | `bp.modules_required = bp.modules_needed_thermal;` |  |
| 152 | `5. Buyer Profile!B37` | Flow deficit (m³/hr) | aggregation | `=MAX(0,B26-B36*B31)` | `bp.flow_deficit_m3_per_hr = max(0,bp.required_flow_rate_m3_per_hr-bp.modules_required*bp.module_flow_capacity_m3_per_hr);` |  |
| 153 | `5. Buyer Profile!B38` | Flow ratio (buyer/system) | conditional | `=IF(B36*B31>0,B26/(B36*B31),0)` | `bp.flow_ratio_buyer_per_system = ifelse(bp.modules_required*bp.module_flow_capacity_m3_per_hr>0,bp.required_flow_rate_m3_per_hr/(bp.modules_required*bp.module_flow_capacity_m3_per_hr),0);` |  |
| 154 | `5. Buyer Profile!B41` | System thermal capacity (kWth) | arithmetic | `=B36*B29` | `bp.system_thermal_capacity_kwth = bp.modules_required*bp.module_thermal_capacity_kwth;` |  |
| 155 | `5. Buyer Profile!B42` | System flow capacity (m³/hr) | arithmetic | `=B36*B31` | `bp.system_flow_capacity_m3_per_hr = bp.modules_required*bp.module_flow_capacity_m3_per_hr;` |  |
| 156 | `5. Buyer Profile!B43` | Thermal utilisation (%) | arithmetic | `=B17/B41` | `bp.thermal_utilisation_pct = bp.heat_demand_kwth/bp.system_thermal_capacity_kwth;` |  |
| 157 | `5. Buyer Profile!B44` | Flow utilisation (%) | conditional | `=IF(B88>0,B26/B88,B26/B42)` | `bp.flow_utilisation_pct = ifelse(bp.augmented_system_flow_m3_per_hr>0,bp.required_flow_rate_m3_per_hr/bp.augmented_system_flow_m3_per_hr,bp.required_flow_rate_m3_per_hr/bp.system_flow_capacity_m3_per_hr);` |  |
| 158 | `5. Buyer Profile!B45` | Hydraulic augmentation needed? | conditional | `=IF(B38>1,"YES - flow ratio "&ROUND(B38,2)&"x","NO")` | `bp.hydraulic_augmentation_needed = string(ifelse(bp.flow_ratio_buyer_per_system>1,"YES - flow ratio ") + string(round(bp.flow_ratio_buyer_per_system,2)) + string("x","NO"));` | text concat |
| 159 | `5. Buyer Profile!B48` | System heat generation (kWth) | arithmetic | `=B41` | `bp.system_heat_generation_kwth = bp.system_thermal_capacity_kwth;` |  |
| 160 | `5. Buyer Profile!B49` | Buyer heat absorption (kWth) | aggregation | `=MIN(B17,B41)` | `bp.buyer_heat_absorption_kwth = min(bp.heat_demand_kwth,bp.system_thermal_capacity_kwth);` |  |
| 161 | `5. Buyer Profile!B5` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `bp.chipset = rp.chipset_type;` |  |
| 162 | `5. Buyer Profile!B50` | Excess heat (kWth) | aggregation | `=MAX(0,B48-B49)` | `bp.excess_heat_kwth = max(0,bp.system_heat_generation_kwth-bp.buyer_heat_absorption_kwth);` |  |
| 163 | `5. Buyer Profile!B51` | Excess heat (%) | conditional | `=IF(B48>0,B50/B48,0)` | `bp.excess_heat_pct = ifelse(bp.system_heat_generation_kwth>0,bp.excess_heat_kwth/bp.system_heat_generation_kwth,0);` |  |
| 164 | `5. Buyer Profile!B52` | Heat rejection required? | conditional | `=IF(B50>0,"YES - "&ROUND(B50,0)&" kWth rejection needed","NO - full utilisation")` | `bp.heat_rejection_required = string(ifelse(bp.excess_heat_kwth>0,"YES - ") + string(round(bp.excess_heat_kwth,0)) + string(" kWth rejection needed","NO - full utilisation"));` | text concat |
| 165 | `5. Buyer Profile!B53` | Rejection method | conditional | `=IF(B50=0,"-",IF(B50<'11. Reference Data'!B15,"Dry cooler",IF(B50<'11. Reference Data'!B16,"Adiabatic cooler","Cooling tower")))` | `bp.rejection_method = ifelse(bp.excess_heat_kwth==0,"-",ifelse(bp.excess_heat_kwth<ref.dry_cooler_max_kwth,"Dry cooler",ifelse(bp.excess_heat_kwth<ref.adiabatic_cooler_max_kwth,"Adiabatic cooler","Cooling tower")));` |  |
| 166 | `5. Buyer Profile!B54` | Rejection capacity required (kWth) | arithmetic | `=B50` | `bp.rejection_capacity_required_kwth = bp.excess_heat_kwth;` |  |
| 167 | `5. Buyer Profile!B55` | Rejection capex rate (£/kWth) | conditional | `=IF(B53="-",0,IF(B53="Dry cooler",'11. Reference Data'!C10,IF(B53="Adiabatic cooler",'11. Reference Data'!C11,IF(B53="Cooling tower",'11. Reference Data'!C12,0))))` | `bp.rejection_capex_rate_gbp_per_kwth = ifelse(bp.rejection_method=="-",0,ifelse(bp.rejection_method=="Dry cooler",ref.dry_cooler__capex_gbp_per_kwth,ifelse(bp.rejection_method=="Adiabatic cooler",ref.adiabatic_cooler__capex_gbp_per_kwth,ifelse(bp.rejection_method=="Cooling tower",ref.cooling_tower__capex_gbp_per_kwth,0))));` |  |
| 168 | `5. Buyer Profile!B56` | Rejection opex rate (£/kWth/yr) | conditional | `=IF(B53="-",0,IF(B53="Dry cooler",'11. Reference Data'!D10,IF(B53="Adiabatic cooler",'11. Reference Data'!D11,IF(B53="Cooling tower",'11. Reference Data'!D12,0))))` | `bp.rejection_opex_rate_gbp_per_kwth_per_yr = ifelse(bp.rejection_method=="-",0,ifelse(bp.rejection_method=="Dry cooler",ref.dry_cooler__opex_gbp_per_kwth_per_yr,ifelse(bp.rejection_method=="Adiabatic cooler",ref.adiabatic_cooler__opex_gbp_per_kwth_per_yr,ifelse(bp.rejection_method=="Cooling tower",ref.cooling_tower__opex_gbp_per_kwth_per_yr,0))));` |  |
| 169 | `5. Buyer Profile!B57` | Rejection capex (£) | arithmetic | `=B54*B55` | `bp.rejection_capex_gbp = bp.rejection_capacity_required_kwth*bp.rejection_capex_rate_gbp_per_kwth;` |  |
| 170 | `5. Buyer Profile!B58` | Annual rejection opex (£/yr) | arithmetic | `=B54*B56` | `bp.annual_rejection_opex_gbp_per_yr = bp.rejection_capacity_required_kwth*bp.rejection_opex_rate_gbp_per_kwth_per_yr;` |  |
| 171 | `5. Buyer Profile!B6` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `bp.cooling_method = rp.cooling_method;` |  |
| 172 | `5. Buyer Profile!B66` | Total modules required | arithmetic | `=B36` | `bp.total_modules_required = bp.modules_required;` |  |
| 173 | `5. Buyer Profile!B67` | Total IT capacity (kW) | arithmetic | `=B36*'1. Module Criteria'!B5` | `bp.total_it_capacity_kw = bp.modules_required*mc.module_it_capacity_kw;` |  |
| 174 | `5. Buyer Profile!B68` | Total rack units (42U racks @ 10kW) | rounding | `=ROUNDUP(B67/10,0)` | `bp.total_rack_units_42u_racks_10kw = roundup(bp.total_it_capacity_kw/10,0);` | rounding |
| 175 | `5. Buyer Profile!B7` | GPUs per module | arithmetic | `='0. Rack Profile'!B39` | `bp.gpus_per_module = rp.gpus_per_module;` |  |
| 176 | `5. Buyer Profile!B71` | Heat pump required? | conditional | `=IF(B16>'1. Module Criteria'!B12,"YES","NO - direct heat sufficient")` | `bp.heat_pump_required = ifelse(bp.required_temperature_c>mc.capture_temperature_c,"YES","NO - direct heat sufficient");` |  |
| 177 | `5. Buyer Profile!B72` | Temperature lift required (K) | conditional | `=IF(B16>'1. Module Criteria'!B12,B16-'1. Module Criteria'!B12,0)` | `bp.temperature_lift_required_k = ifelse(bp.required_temperature_c>mc.capture_temperature_c,bp.required_temperature_c-mc.capture_temperature_c,0);` |  |
| 178 | `5. Buyer Profile!B73` | Heat pump units | arithmetic | `=B36` | `bp.heat_pump_units = bp.modules_required;` |  |
| 179 | `5. Buyer Profile!B74` | Total HP capacity (kWth) | arithmetic | `=B36*'1. Module Criteria'!B18` | `bp.total_hp_capacity_kwth = bp.modules_required*mc.heat_pump_capacity_kwth;` |  |
| 180 | `5. Buyer Profile!B75` | HP electrical demand (kW) | conditional | `=IF(OR(NOT(ISNUMBER('1. Module Criteria'!B17)),'1. Module Criteria'!B17<=1),0,B41/'1. Module Criteria'!B17)` | `bp.hp_electrical_demand_kw = ifelse(or(not(isnumber(mc.heat_pump_cop)),mc.heat_pump_cop<=1),0,bp.system_thermal_capacity_kwth/mc.heat_pump_cop);` | ISNUMBER guard |
| 181 | `5. Buyer Profile!B78` | Source loop pumps | arithmetic | `=B36` | `bp.source_loop_pumps = bp.modules_required;` |  |
| 182 | `5. Buyer Profile!B79` | Sink loop pumps | arithmetic | `=B36` | `bp.sink_loop_pumps = bp.modules_required;` |  |
| 183 | `5. Buyer Profile!B8` | Module IT capacity (kW) | arithmetic | `='0. Rack Profile'!B40` | `bp.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| 184 | `5. Buyer Profile!B80` | Total system flow (m³/hr) | arithmetic | `=B42` | `bp.total_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr;` |  |
| 185 | `5. Buyer Profile!B81` | Header pipe size estimate (DN) | conditional | `=IF(B42<10,"DN50",IF(B42<25,"DN65",IF(B42<50,"DN80",IF(B42<100,"DN100","DN125+"))))` | `bp.header_pipe_size_estimate_dn = ifelse(bp.system_flow_capacity_m3_per_hr<10,"DN50",ifelse(bp.system_flow_capacity_m3_per_hr<25,"DN65",ifelse(bp.system_flow_capacity_m3_per_hr<50,"DN80",ifelse(bp.system_flow_capacity_m3_per_hr<100,"DN100","DN125+"))));` |  |
| 186 | `5. Buyer Profile!B82` | Buffer tank recommended? | conditional | `=IF(B36>2,"YES - system balancing","OPTIONAL")` | `bp.buffer_tank_recommended = ifelse(bp.modules_required>2,"YES - system balancing","OPTIONAL");` |  |
| 187 | `5. Buyer Profile!B83` | Flow augmentation pump (m³/hr) | arithmetic | `=B37` | `bp.flow_augmentation_pump_m3_per_hr = bp.flow_deficit_m3_per_hr;` |  |
| 188 | `5. Buyer Profile!B84` | Mixing valve required? | conditional | `=IF(B37>0,"YES","NO")` | `bp.mixing_valve_required = ifelse(bp.flow_deficit_m3_per_hr>0,"YES","NO");` |  |
| 189 | `5. Buyer Profile!B85` | Augmentation pump power (kW) | arithmetic | `=B87*'11. Reference Data'!B121` | `bp.augmentation_pump_power_kw = bp.augmentation_pump_capacity_m3_per_hr*ref.augmentation_pump_power_kw_per_m3_per_hr;` |  |
| 190 | `5. Buyer Profile!B86` | Augmentation pumps required | conditional | `=IF(B37>0,ROUNDUP(B37/'11. Reference Data'!B124,0),0)` | `bp.augmentation_pumps_required = ifelse(bp.flow_deficit_m3_per_hr>0,roundup(bp.flow_deficit_m3_per_hr/ref.standard_augmentation_pump_capacity_m3_per_hr,0),0);` | rounding |
| 191 | `5. Buyer Profile!B87` | Augmentation pump capacity (m³/hr) | arithmetic | `=B86*'11. Reference Data'!B124` | `bp.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pumps_required*ref.standard_augmentation_pump_capacity_m3_per_hr;` |  |
| 192 | `5. Buyer Profile!B88` | Augmented system flow (m³/hr) | arithmetic | `=B42+B87` | `bp.augmented_system_flow_m3_per_hr = bp.system_flow_capacity_m3_per_hr+bp.augmentation_pump_capacity_m3_per_hr;` |  |
| 193 | `5. Buyer Profile!B89` | Flow requirement met? | conditional | `=IF(B88>=B26,"YES","NO - shortfall of "&ROUND(B26-B88,1)&" m³/hr")` | `bp.flow_requirement_met = string(ifelse(bp.augmented_system_flow_m3_per_hr>=bp.required_flow_rate_m3_per_hr,"YES","NO - shortfall of ") + string(round(bp.required_flow_rate_m3_per_hr-bp.augmented_system_flow_m3_per_hr,1)) + string(" m³/hr"));` | text concat |
| 194 | `5. Buyer Profile!B93` | IT load (kW) | arithmetic | `=B67` | `bp.it_load_kw = bp.total_it_capacity_kw;` |  |
| 195 | `5. Buyer Profile!B94` | Cooling infrastructure (kW) | arithmetic | `=B67*'1. Module Criteria'!B7*0.05` | `bp.cooling_infrastructure_kw = bp.total_it_capacity_kw*mc.target_utilisation_rate_pct*0.05;` |  |
| 196 | `5. Buyer Profile!B95` | Heat pump load (kW) | arithmetic | `=B75` | `bp.heat_pump_load_kw = bp.hp_electrical_demand_kw;` |  |
| 197 | `5. Buyer Profile!B96` | Total electrical demand (kW) | arithmetic | `=B93+B94+B95` | `bp.total_electrical_demand_kw = bp.it_load_kw+bp.cooling_infrastructure_kw+bp.heat_pump_load_kw;` |  |
| 198 | `5. Buyer Profile!B97` | Grid connection (kVA @ 0.9 PF) | rounding | `=ROUNDUP(B96/0.9,-1)` | `bp.grid_connection_kva_0_9_pf = roundup(bp.total_electrical_demand_kw/0.9,-1);` | rounding |
| 199 | `6. System Capex!B10` | Selected buyer profile | arithmetic | `='5. Buyer Profile'!B11` | `scapex.selected_buyer_profile = bp.select_process;` |  |
| 200 | `6. System Capex!B11` | Modules required | arithmetic | `='5. Buyer Profile'!B36` | `scapex.modules_required = bp.modules_required;` |  |
| 201 | `6. System Capex!B14` | Enclosure & structure | arithmetic | `='2. Module Capex'!B16` | `scapex.enclosure_structure = mcapex.subtotal_enclosure;` |  |
| 202 | `6. System Capex!B15` | Cooling system | arithmetic | `='2. Module Capex'!B24+'2. Module Capex'!B30` | `scapex.cooling_system = mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling;` |  |
| 203 | `6. System Capex!B16` | Power distribution | arithmetic | `='2. Module Capex'!B36` | `scapex.power_distribution = mcapex.subtotal_power;` |  |
| 204 | `6. System Capex!B17` | Thermal integration | arithmetic | `='2. Module Capex'!B43` | `scapex.thermal_integration = mcapex.subtotal_thermal;` |  |
| 205 | `6. System Capex!B18` | Monitoring & controls | arithmetic | `='2. Module Capex'!B49` | `scapex.monitoring_controls = mcapex.subtotal_monitoring;` |  |
| 206 | `6. System Capex!B19` | Cooling method premium | arithmetic | `='2. Module Capex'!B60` | `scapex.cooling_method_premium = mcapex.applied_to_base_infrastructure;` |  |
| 207 | `6. System Capex!B20` | Heat pump (if enabled) | arithmetic | `='2. Module Capex'!B56` | `scapex.heat_pump_if_enabled = mcapex.subtotal_heat_pump;` |  |
| 208 | `6. System Capex!B21` | TOTAL PER MODULE | arithmetic | `='2. Module Capex'!B66` | `scapex.total_per_module = mcapex.total_module_capex;` |  |
| 209 | `6. System Capex!B24` | Total module capex | arithmetic | `=B21*B11` | `scapex.total_module_capex = scapex.total_per_module*scapex.modules_required;` |  |
| 210 | `6. System Capex!B26` | Shared infrastructure (£) | arithmetic | `=B24*B25` | `scapex.shared_infrastructure_gbp = scapex.total_module_capex*scapex.shared_infrastructure_pct;` |  |
| 211 | `6. System Capex!B27` | Integration & commissioning | conditional | `=IF(B11>1,25000*(B11-1),0)` | `scapex.integration_commissioning = ifelse(scapex.modules_required>1,25000*(scapex.modules_required-1),0);` |  |
| 212 | `6. System Capex!B30` | Rejection capacity required (kWth) | arithmetic | `='5. Buyer Profile'!B54` | `scapex.rejection_capacity_required_kwth = bp.rejection_capacity_required_kwth;` |  |
| 213 | `6. System Capex!B31` | Rejection capex rate (£/kWth) | arithmetic | `='5. Buyer Profile'!B55` | `scapex.rejection_capex_rate_gbp_per_kwth = bp.rejection_capex_rate_gbp_per_kwth;` |  |
| 214 | `6. System Capex!B32` | Heat rejection capex | conditional | `=IF(B30>0,B30*B31,0)` | `scapex.heat_rejection_capex = ifelse(scapex.rejection_capacity_required_kwth>0,scapex.rejection_capacity_required_kwth*scapex.rejection_capex_rate_gbp_per_kwth,0);` |  |
| 215 | `6. System Capex!B35` | Flow deficit (m³/hr) | arithmetic | `='5. Buyer Profile'!B37` | `scapex.flow_deficit_m3_per_hr = bp.flow_deficit_m3_per_hr;` |  |
| 216 | `6. System Capex!B36` | Augmentation pumps required | arithmetic | `='5. Buyer Profile'!B86` | `scapex.augmentation_pumps_required = bp.augmentation_pumps_required;` |  |
| 217 | `6. System Capex!B37` | Augmentation pump capex | arithmetic | `=B36*'11. Reference Data'!B124*'11. Reference Data'!B120` | `scapex.augmentation_pump_capex = scapex.augmentation_pumps_required*ref.standard_augmentation_pump_capacity_m3_per_hr*ref.augmentation_pump_capex_gbp_per_m3_per_hr;` |  |
| 218 | `6. System Capex!B38` | Mixing valve + controls | conditional | `=IF(B35>0,'11. Reference Data'!B122,0)` | `scapex.mixing_valve_controls = ifelse(scapex.flow_deficit_m3_per_hr>0,ref.mixing_valve_controls_gbp,0);` |  |
| 219 | `6. System Capex!B39` | Pipe upsizing allowance | conditional | `=IF(B35>20,B35*'11. Reference Data'!B123,0)` | `scapex.pipe_upsizing_allowance = ifelse(scapex.flow_deficit_m3_per_hr>20,scapex.flow_deficit_m3_per_hr*ref.pipe_upsizing_allowance_gbp_per_m3_per_hr,0);` |  |
| 220 | `6. System Capex!B40` | SUBTOTAL: HYDRAULIC AUGMENTATION | aggregation | `=SUM(B37:B39)` | `scapex.subtotal_hydraulic_augmentation = sum([scapex.augmentation_pump_capex, scapex.mixing_valve_controls, scapex.pipe_upsizing_allowance]);` |  |
| 221 | `6. System Capex!B43` | Base system capex (excl. rejection) | arithmetic | `=B24+B26+B27` | `scapex.base_system_capex_excl_rejection = scapex.total_module_capex+scapex.shared_infrastructure_gbp+scapex.integration_commissioning;` |  |
| 222 | `6. System Capex!B44` | Heat rejection capex | arithmetic | `=B32` | `scapex.heat_rejection_capex__b44 = scapex.heat_rejection_capex;` |  |
| 223 | `6. System Capex!B45` | Hydraulic augmentation capex | arithmetic | `=B40` | `scapex.hydraulic_augmentation_capex = scapex.subtotal_hydraulic_augmentation;` |  |
| 224 | `6. System Capex!B46` | TOTAL SYSTEM CAPEX | arithmetic | `=B43+B44+B45` | `scapex.total_system_capex = scapex.base_system_capex_excl_rejection+scapex.heat_rejection_capex__b44+scapex.hydraulic_augmentation_capex;` |  |
| 225 | `6. System Capex!B48` | Capex per IT kW (£/kW) | arithmetic | `=B46/(B11*'0. Rack Profile'!B40)` | `scapex.capex_per_it_kw_gbp_per_kw = scapex.total_system_capex/(scapex.modules_required*rp.actual_module_it_capacity_kw);` |  |
| 226 | `6. System Capex!B49` | Capex per kWth delivered (£/kWth) | arithmetic | `=B46/'5. Buyer Profile'!B17` | `scapex.capex_per_kwth_delivered_gbp_per_kwth = scapex.total_system_capex/bp.heat_demand_kwth;` |  |
| 227 | `6. System Capex!B5` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `scapex.chipset = rp.chipset_type;` |  |
| 228 | `6. System Capex!B6` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `scapex.cooling_method = rp.cooling_method;` |  |
| 229 | `6. System Capex!B7` | GPUs per module | arithmetic | `='0. Rack Profile'!B39` | `scapex.gpus_per_module = rp.gpus_per_module;` |  |
| 230 | `7. System Opex!B10` | Selected buyer profile | arithmetic | `='5. Buyer Profile'!B11` | `sopex.selected_buyer_profile = bp.select_process;` |  |
| 231 | `7. System Opex!B11` | Modules in system | arithmetic | `='5. Buyer Profile'!B36` | `sopex.modules_in_system = bp.modules_required;` |  |
| 232 | `7. System Opex!B14` | Electricity (infra + HP) | arithmetic | `='3. Module Opex'!B10` | `sopex.electricity_infra_hp = mopex.subtotal_electricity;` |  |
| 233 | `7. System Opex!B15` | Maintenance & insurance | arithmetic | `='3. Module Opex'!B21` | `sopex.maintenance_insurance = mopex.subtotal_maintenance_insurance;` |  |
| 234 | `7. System Opex!B16` | Other (site, NOC, admin) | arithmetic | `='3. Module Opex'!B27` | `sopex.other_site_noc_admin = mopex.subtotal_other;` |  |
| 235 | `7. System Opex!B17` | TOTAL PER MODULE | arithmetic | `='3. Module Opex'!B29` | `sopex.total_per_module = mopex.total_module_opex_gbp_per_yr;` |  |
| 236 | `7. System Opex!B20` | Total module opex | arithmetic | `=B17*B11` | `sopex.total_module_opex = sopex.total_per_module*sopex.modules_in_system;` |  |
| 237 | `7. System Opex!B22` | Shared overhead (£/yr) | arithmetic | `=B20*B21` | `sopex.shared_overhead_gbp_per_yr = sopex.total_module_opex*sopex.shared_overhead_pct;` |  |
| 238 | `7. System Opex!B23` | Base system opex (excl. rejection) | arithmetic | `=B20+B22` | `sopex.base_system_opex_excl_rejection = sopex.total_module_opex+sopex.shared_overhead_gbp_per_yr;` |  |
| 239 | `7. System Opex!B26` | Excess heat (kWth) | arithmetic | `='5. Buyer Profile'!B50` | `sopex.excess_heat_kwth = bp.excess_heat_kwth;` |  |
| 240 | `7. System Opex!B27` | Rejection running cost (£/kWth/yr) | arithmetic | `='5. Buyer Profile'!B56` | `sopex.rejection_running_cost_gbp_per_kwth_per_yr = bp.rejection_opex_rate_gbp_per_kwth_per_yr;` |  |
| 241 | `7. System Opex!B28` | Heat rejection opex (£/yr) | conditional | `=IF(B26>0,B26*B27,0)` | `sopex.heat_rejection_opex_gbp_per_yr = ifelse(sopex.excess_heat_kwth>0,sopex.excess_heat_kwth*sopex.rejection_running_cost_gbp_per_kwth_per_yr,0);` |  |
| 242 | `7. System Opex!B29` | Heat rejection uplift (%) | conditional | `=IF(B23>0,B28/B23,0)` | `sopex.heat_rejection_uplift_pct = ifelse(sopex.base_system_opex_excl_rejection>0,sopex.heat_rejection_opex_gbp_per_yr/sopex.base_system_opex_excl_rejection,0);` |  |
| 243 | `7. System Opex!B31` | Augmentation pump capacity (m³/hr) | arithmetic | `='5. Buyer Profile'!B87` | `sopex.augmentation_pump_capacity_m3_per_hr = bp.augmentation_pump_capacity_m3_per_hr;` |  |
| 244 | `7. System Opex!B32` | Augmentation pump power (kW) | arithmetic | `='5. Buyer Profile'!B85` | `sopex.augmentation_pump_power_kw = bp.augmentation_pump_power_kw;` |  |
| 245 | `7. System Opex!B33` | Annual operating hours | arithmetic | `='5. Buyer Profile'!B18` | `sopex.annual_operating_hours = bp.operating_hours_per_year;` |  |
| 246 | `7. System Opex!B34` | Electricity rate (£/kWh) | arithmetic | `='3. Module Opex'!B5` | `sopex.electricity_rate_gbp_per_kwh = mopex.electricity_rate_gbp_per_kwh;` |  |
| 247 | `7. System Opex!B35` | Augmentation pump electricity (£/yr) | arithmetic | `=B32*B33*B34` | `sopex.augmentation_pump_electricity_gbp_per_yr = sopex.augmentation_pump_power_kw*sopex.annual_operating_hours*sopex.electricity_rate_gbp_per_kwh;` |  |
| 248 | `7. System Opex!B37` | TOTAL SYSTEM OPEX | arithmetic | `=B23+B28+B35` | `sopex.total_system_opex = sopex.base_system_opex_excl_rejection+sopex.heat_rejection_opex_gbp_per_yr+sopex.augmentation_pump_electricity_gbp_per_yr;` |  |
| 249 | `7. System Opex!B5` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `sopex.chipset = rp.chipset_type;` |  |
| 250 | `7. System Opex!B6` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `sopex.cooling_method = rp.cooling_method;` |  |
| 251 | `7. System Opex!B7` | GPUs per module | arithmetic | `='0. Rack Profile'!B39` | `sopex.gpus_per_module = rp.gpus_per_module;` |  |
| 252 | `8. System Flow!B10` | Selected buyer profile | arithmetic | `='5. Buyer Profile'!B11` | `sflow.selected_buyer_profile = bp.select_process;` |  |
| 253 | `8. System Flow!B11` | Modules in system | arithmetic | `='5. Buyer Profile'!B36` | `sflow.modules_in_system = bp.modules_required;` |  |
| 254 | `8. System Flow!B14` | Required temperature (°C) | arithmetic | `='5. Buyer Profile'!B16` | `sflow.required_temperature_c = bp.required_temperature_c;` |  |
| 255 | `8. System Flow!B15` | Required thermal load (kWth) | arithmetic | `='5. Buyer Profile'!B17` | `sflow.required_thermal_load_kwth = bp.heat_demand_kwth;` |  |
| 256 | `8. System Flow!B16` | Required flow rate (m³/hr) | arithmetic | `='5. Buyer Profile'!B26` | `sflow.required_flow_rate_m3_per_hr = bp.required_flow_rate_m3_per_hr;` |  |
| 257 | `8. System Flow!B17` | Annual heat demand (MWh) | arithmetic | `='5. Buyer Profile'!B24` | `sflow.annual_heat_demand_mwh = bp.annual_heat_demand_mwh;` |  |
| 258 | `8. System Flow!B20` | Delivery temperature (°C) | arithmetic | `='1. Module Criteria'!B22` | `sflow.delivery_temperature_c = mc.delivery_temperature_c;` |  |
| 259 | `8. System Flow!B21` | System thermal capacity (kWth) | arithmetic | `='5. Buyer Profile'!B41` | `sflow.system_thermal_capacity_kwth = bp.system_thermal_capacity_kwth;` |  |
| 260 | `8. System Flow!B22` | System flow capacity (m³/hr) | arithmetic | `='5. Buyer Profile'!B42` | `sflow.system_flow_capacity_m3_per_hr = bp.system_flow_capacity_m3_per_hr;` |  |
| 261 | `8. System Flow!B23` | Annual heat supply (MWh) | arithmetic | `=B21*'5. Buyer Profile'!B18/1000` | `sflow.annual_heat_supply_mwh = sflow.system_thermal_capacity_kwth*bp.operating_hours_per_year/1000;` |  |
| 262 | `8. System Flow!B26` | Temperature (°C) | arithmetic | `=B14` | `sflow.temperature_c = sflow.required_temperature_c;` |  |
| 263 | `8. System Flow!B27` | Thermal load (kWth) | arithmetic | `=B15` | `sflow.thermal_load_kwth = sflow.required_thermal_load_kwth;` |  |
| 264 | `8. System Flow!B28` | Flow rate (m³/hr) | arithmetic | `=B16` | `sflow.flow_rate_m3_per_hr = sflow.required_flow_rate_m3_per_hr;` |  |
| 265 | `8. System Flow!B29` | Annual energy (MWh) | arithmetic | `=B17` | `sflow.annual_energy_mwh = sflow.annual_heat_demand_mwh;` |  |
| 266 | `8. System Flow!B32` | Thermal utilisation | arithmetic | `='5. Buyer Profile'!B43` | `sflow.thermal_utilisation = bp.thermal_utilisation_pct;` |  |
| 267 | `8. System Flow!B33` | Flow utilisation | arithmetic | `='5. Buyer Profile'!B44` | `sflow.flow_utilisation = bp.flow_utilisation_pct;` |  |
| 268 | `8. System Flow!B34` | Binding constraint | conditional | `=IF(AND(ISNUMBER('5. Buyer Profile'!B43),ISNUMBER('5. Buyer Profile'!B44)),IF('5. Buyer Profile'!B43>='5. Buyer Profile'!B44,"Thermal","Flow"),"-")` | `sflow.binding_constraint = ifelse(and(isnumber(bp.thermal_utilisation_pct),isnumber(bp.flow_utilisation_pct)),ifelse(bp.thermal_utilisation_pct>=bp.flow_utilisation_pct,"Thermal","Flow"),"-");` | ISNUMBER guard |
| 269 | `8. System Flow!B36` | Spare capacity (kWth) | arithmetic | `=B21-B15` | `sflow.spare_capacity_kwth = sflow.system_thermal_capacity_kwth-sflow.required_thermal_load_kwth;` |  |
| 270 | `8. System Flow!B37` | Spare capacity (m³/hr) | arithmetic | `=B22-B16` | `sflow.spare_capacity_m3_per_hr = sflow.system_flow_capacity_m3_per_hr-sflow.required_flow_rate_m3_per_hr;` |  |
| 271 | `8. System Flow!B41` | Main header pipe ID (mm) | math | `=SQRT((B16/3600)/(B40*3.14159/4))*1000` | `sflow.main_header_pipe_id_mm = sqrt((sflow.required_flow_rate_m3_per_hr/3600)/(sflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| 272 | `8. System Flow!B42` | Nearest DN size | conditional | `=IF(B41<28,"DN25",IF(B41<36,"DN32",IF(B41<42,"DN40",IF(B41<54,"DN50",IF(B41<68,"DN65",IF(B41<82,"DN80",IF(B41<107,"DN100",IF(B41<131,"DN125",IF(B41<159,"DN150","DN200+")))))))))` | `sflow.nearest_dn_size = ifelse(sflow.main_header_pipe_id_mm<28,"DN25",ifelse(sflow.main_header_pipe_id_mm<36,"DN32",ifelse(sflow.main_header_pipe_id_mm<42,"DN40",ifelse(sflow.main_header_pipe_id_mm<54,"DN50",ifelse(sflow.main_header_pipe_id_mm<68,"DN65",ifelse(sflow.main_header_pipe_id_mm<82,"DN80",ifelse(sflow.main_header_pipe_id_mm<107,"DN100",ifelse(sflow.main_header_pipe_id_mm<131,"DN125",ifelse(sflow.main_header_pipe_id_mm<159,"DN150","DN200+")))))))));` |  |
| 273 | `8. System Flow!B5` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `sflow.chipset = rp.chipset_type;` |  |
| 274 | `8. System Flow!B6` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `sflow.cooling_method = rp.cooling_method;` |  |
| 275 | `8. System Flow!B7` | Capture temperature (°C) | arithmetic | `='0. Rack Profile'!B21` | `sflow.capture_temperature_c = rp.capture_temperature_c;` |  |
| 276 | `8. System Flow!C26` | Temperature (°C) | arithmetic | `=B20` | `sflow.temperature_c__supplied = sflow.delivery_temperature_c;` |  |
| 277 | `8. System Flow!C27` | Thermal load (kWth) | arithmetic | `=B21` | `sflow.thermal_load_kwth__supplied = sflow.system_thermal_capacity_kwth;` |  |
| 278 | `8. System Flow!C28` | Flow rate (m³/hr) | arithmetic | `=B22` | `sflow.flow_rate_m3_per_hr__supplied = sflow.system_flow_capacity_m3_per_hr;` |  |
| 279 | `8. System Flow!C29` | Annual energy (MWh) | arithmetic | `=B23` | `sflow.annual_energy_mwh__supplied = sflow.annual_heat_supply_mwh;` |  |
| 280 | `8. System Flow!D26` | Temperature (°C) | conditional | `=IF(C26>=B26,"✓ YES","✗ NO - need "&B26&"°C")` | `sflow.temperature_c__match = string(ifelse(sflow.temperature_c__supplied>=sflow.temperature_c,"✓ YES","✗ NO - need ") + string(sflow.temperature_c) + string("°C"));` | text concat |
| 281 | `8. System Flow!D27` | Thermal load (kWth) | conditional | `=IF(C27>=B27,"✓ YES - "&ROUND((C27-B27),0)&" kWth spare","✗ SHORT "&ROUND((B27-C27),0)&" kWth")` | `sflow.thermal_load_kwth__match = string(ifelse(sflow.thermal_load_kwth__supplied>=sflow.thermal_load_kwth,"✓ YES - ") + string(round((sflow.thermal_load_kwth__supplied-sflow.thermal_load_kwth),0)) + " kWth spare","✗ SHORT " + string(round((sflow.thermal_load_kwth-sflow.thermal_load_kwth__supplied),0)) + string(" kWth"));` | text concat |
| 282 | `8. System Flow!D28` | Flow rate (m³/hr) | conditional | `=IF(C28>=B28,"✓ YES - "&ROUND((C28-B28),1)&" m³/hr spare","✗ SHORT "&ROUND((B28-C28),1)&" m³/hr")` | `sflow.flow_rate_m3_per_hr__match = string(ifelse(sflow.flow_rate_m3_per_hr__supplied>=sflow.flow_rate_m3_per_hr,"✓ YES - ") + string(round((sflow.flow_rate_m3_per_hr__supplied-sflow.flow_rate_m3_per_hr),1)) + " m³/hr spare","✗ SHORT " + string(round((sflow.flow_rate_m3_per_hr-sflow.flow_rate_m3_per_hr__supplied),1)) + string(" m³/hr"));` | text concat |
| 283 | `8. System Flow!D29` | Annual energy (MWh) | conditional | `=IF(C29>=B29,"✓ YES - "&ROUND((C29-B29),0)&" MWh spare","✗ SHORT "&ROUND((B29-C29),0)&" MWh")` | `sflow.annual_energy_mwh__match = string(ifelse(sflow.annual_energy_mwh__supplied>=sflow.annual_energy_mwh,"✓ YES - ") + string(round((sflow.annual_energy_mwh__supplied-sflow.annual_energy_mwh),0)) + " MWh spare","✗ SHORT " + string(round((sflow.annual_energy_mwh-sflow.annual_energy_mwh__supplied),0)) + string(" MWh"));` | text concat |
| 284 | `9. System P&L!B12` | Module IT capacity (kW) | arithmetic | `='1. Module Criteria'!B5` | `spl.module_it_capacity_kw = mc.module_it_capacity_kw;` |  |
| 285 | `9. System P&L!B13` | Rack rate (£/kW/month) | arithmetic | `='1. Module Criteria'!B6` | `spl.rack_rate_gbp_per_kw_per_month = mc.compute_rate_gbp_per_kw_per_month;` |  |
| 286 | `9. System P&L!B14` | Operating hours/year | arithmetic | `='5. Buyer Profile'!B18` | `spl.operating_hours_per_year = bp.operating_hours_per_year;` |  |
| 287 | `9. System P&L!B15` | Utilisation assumption (%) | arithmetic | `='1. Module Criteria'!B7` | `spl.utilisation_assumption_pct = mc.target_utilisation_rate_pct;` |  |
| 288 | `9. System P&L!B16` | Compute revenue per module (£/yr) | arithmetic | `=B12*B13*12*B15` | `spl.compute_revenue_per_module_gbp_per_yr = spl.module_it_capacity_kw*spl.rack_rate_gbp_per_kw_per_month*12*spl.utilisation_assumption_pct;` |  |
| 289 | `9. System P&L!B17` | TOTAL COMPUTE REVENUE (£/yr) | arithmetic | `=B16*B7` | `spl.total_compute_revenue_gbp_per_yr = spl.compute_revenue_per_module_gbp_per_yr*spl.modules_in_system;` |  |
| 290 | `9. System P&L!B20` | Heat price (£/MWh) | arithmetic | `='1. Module Criteria'!B29` | `spl.heat_price_gbp_per_mwh = mc.effective_heat_price_gbp_per_mwh;` |  |
| 291 | `9. System P&L!B21` | Buyer operating hours/year | arithmetic | `='5. Buyer Profile'!B18` | `spl.buyer_operating_hours_per_year = bp.operating_hours_per_year;` |  |
| 292 | `9. System P&L!B23` | Theoretical heat output (kWth) | arithmetic | `='5. Buyer Profile'!B48` | `spl.theoretical_heat_output_kwth = bp.system_heat_generation_kwth;` |  |
| 293 | `9. System P&L!B24` | Theoretical heat revenue (£/yr) | arithmetic | `=B23*B21*B20/1000` | `spl.theoretical_heat_revenue_gbp_per_yr = spl.theoretical_heat_output_kwth*spl.buyer_operating_hours_per_year*spl.heat_price_gbp_per_mwh/1000;` |  |
| 294 | `9. System P&L!B26` | Actual buyer absorption (kWth) | arithmetic | `='5. Buyer Profile'!B49` | `spl.actual_buyer_absorption_kwth = bp.buyer_heat_absorption_kwth;` |  |
| 295 | `9. System P&L!B27` | ACTUAL HEAT REVENUE (£/yr) | arithmetic | `=B26*B21*B20/1000` | `spl.actual_heat_revenue_gbp_per_yr = spl.actual_buyer_absorption_kwth*spl.buyer_operating_hours_per_year*spl.heat_price_gbp_per_mwh/1000;` |  |
| 296 | `9. System P&L!B29` | Heat utilisation (%) | conditional | `=IF(B23>0,B26/B23,0)` | `spl.heat_utilisation_pct = ifelse(spl.theoretical_heat_output_kwth>0,spl.actual_buyer_absorption_kwth/spl.theoretical_heat_output_kwth,0);` |  |
| 297 | `9. System P&L!B30` | Lost heat revenue (£/yr) | arithmetic | `=B24-B27` | `spl.lost_heat_revenue_gbp_per_yr = spl.theoretical_heat_revenue_gbp_per_yr-spl.actual_heat_revenue_gbp_per_yr;` |  |
| 298 | `9. System P&L!B33` | Compute revenue (£/yr) | arithmetic | `=B17` | `spl.compute_revenue_gbp_per_yr = spl.total_compute_revenue_gbp_per_yr;` |  |
| 299 | `9. System P&L!B34` | Heat revenue (£/yr) | arithmetic | `=B27` | `spl.heat_revenue_gbp_per_yr = spl.actual_heat_revenue_gbp_per_yr;` |  |
| 300 | `9. System P&L!B35` | TOTAL REVENUE (£/yr) | arithmetic | `=B33+B34` | `spl.total_revenue_gbp_per_yr = spl.compute_revenue_gbp_per_yr+spl.heat_revenue_gbp_per_yr;` |  |
| 301 | `9. System P&L!B36` | Heat as % of total revenue | conditional | `=IF(B35>0,B34/B35,0)` | `spl.heat_as_pct_of_total_revenue = ifelse(spl.total_revenue_gbp_per_yr>0,spl.heat_revenue_gbp_per_yr/spl.total_revenue_gbp_per_yr,0);` |  |
| 302 | `9. System P&L!B39` | Base system opex (£/yr) | arithmetic | `='7. System Opex'!B23` | `spl.base_system_opex_gbp_per_yr = sopex.base_system_opex_excl_rejection;` |  |
| 303 | `9. System P&L!B40` | Heat rejection opex (£/yr) | arithmetic | `='7. System Opex'!B28` | `spl.heat_rejection_opex_gbp_per_yr = sopex.heat_rejection_opex_gbp_per_yr;` |  |
| 304 | `9. System P&L!B41` | Hydraulic augmentation opex (£/yr) | arithmetic | `='7. System Opex'!B35` | `spl.hydraulic_augmentation_opex_gbp_per_yr = sopex.augmentation_pump_electricity_gbp_per_yr;` |  |
| 305 | `9. System P&L!B42` | TOTAL OPEX (£/yr) | arithmetic | `='7. System Opex'!B37` | `spl.total_opex_gbp_per_yr = sopex.total_system_opex;` |  |
| 306 | `9. System P&L!B45` | Gross profit (£/yr) | arithmetic | `=B35-B42` | `spl.gross_profit_gbp_per_yr = spl.total_revenue_gbp_per_yr-spl.total_opex_gbp_per_yr;` |  |
| 307 | `9. System P&L!B46` | Gross margin (%) | conditional | `=IF(B35>0,B45/B35,0)` | `spl.gross_margin_pct = ifelse(spl.total_revenue_gbp_per_yr>0,spl.gross_profit_gbp_per_yr/spl.total_revenue_gbp_per_yr,0);` |  |
| 308 | `9. System P&L!B48` | Total system capex (£) | arithmetic | `='6. System Capex'!B46` | `spl.total_system_capex_gbp = scapex.total_system_capex;` |  |
| 309 | `9. System P&L!B49` | Simple payback (years) | conditional | `=IF(B45>0,B48/B45,0)` | `spl.simple_payback_years = ifelse(spl.gross_profit_gbp_per_yr>0,spl.total_system_capex_gbp/spl.gross_profit_gbp_per_yr,0);` |  |
| 310 | `9. System P&L!B50` | Unlevered ROI (%) | conditional | `=IF(B48>0,B45/B48,0)` | `spl.unlevered_roi_pct = ifelse(spl.total_system_capex_gbp>0,spl.gross_profit_gbp_per_yr/spl.total_system_capex_gbp,0);` |  |
| 311 | `9. System P&L!B53` | Heat utilisation efficiency (%) | arithmetic | `=B29` | `spl.heat_utilisation_efficiency_pct = spl.heat_utilisation_pct;` |  |
| 312 | `9. System P&L!B54` | Revenue lost to heat rejection (£/yr) | arithmetic | `=B30` | `spl.revenue_lost_to_heat_rejection_gbp_per_yr = spl.lost_heat_revenue_gbp_per_yr;` |  |
| 313 | `9. System P&L!B55` | Cost of heat rejection (£/yr) | arithmetic | `=B40` | `spl.cost_of_heat_rejection_gbp_per_yr = spl.heat_rejection_opex_gbp_per_yr;` |  |
| 314 | `9. System P&L!B56` | Total heat inefficiency cost (£/yr) | arithmetic | `=B54+B55` | `spl.total_heat_inefficiency_cost_gbp_per_yr = spl.revenue_lost_to_heat_rejection_gbp_per_yr+spl.cost_of_heat_rejection_gbp_per_yr;` |  |
| 315 | `9. System P&L!B57` | Heat inefficiency as % of potential profit | conditional | `=IF((B45+B56)>0,B56/(B45+B56),0)` | `spl.heat_inefficiency_as_pct_of_potential_profit = ifelse((spl.gross_profit_gbp_per_yr+spl.total_heat_inefficiency_cost_gbp_per_yr)>0,spl.total_heat_inefficiency_cost_gbp_per_yr/(spl.gross_profit_gbp_per_yr+spl.total_heat_inefficiency_cost_gbp_per_yr),0);` |  |
| 316 | `9. System P&L!B6` | Selected buyer profile | arithmetic | `='5. Buyer Profile'!B11` | `spl.selected_buyer_profile = bp.select_process;` |  |
| 317 | `9. System P&L!B7` | Modules in system | arithmetic | `='5. Buyer Profile'!B36` | `spl.modules_in_system = bp.modules_required;` |  |
| 318 | `9. System P&L!B8` | Chipset | arithmetic | `='0. Rack Profile'!B6` | `spl.chipset = rp.chipset_type;` |  |
| 319 | `9. System P&L!B9` | Cooling method | arithmetic | `='0. Rack Profile'!B17` | `spl.cooling_method = rp.cooling_method;` |  |
| 320 | `11. Reference Data!B47` | 11. Reference Data B47 | arithmetic | `=B44-A47` | `ref.target_delivery_temp_c-A47;` |  |
| 321 | `11. Reference Data!B48` | 11. Reference Data B48 | arithmetic | `=B44-A48` | `ref.target_delivery_temp_c-A48;` |  |
| 322 | `11. Reference Data!B49` | 11. Reference Data B49 | arithmetic | `=B44-A49` | `ref.target_delivery_temp_c-A49;` |  |
| 323 | `11. Reference Data!B50` | 11. Reference Data B50 | arithmetic | `=B44-A50` | `ref.target_delivery_temp_c-A50;` |  |
| 324 | `11. Reference Data!C47` | 11. Reference Data C47 | rounding | `=ROUND(B110*(B44+273.15)/B47,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B47,1);` |  |
| 325 | `11. Reference Data!C48` | 11. Reference Data C48 | rounding | `=ROUND(B110*(B44+273.15)/B48,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B48,1);` |  |
| 326 | `11. Reference Data!C49` | 11. Reference Data C49 | rounding | `=ROUND(B110*(B44+273.15)/B49,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B49,1);` |  |
| 327 | `11. Reference Data!C50` | 11. Reference Data C50 | rounding | `=ROUND(B110*(B44+273.15)/B50,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B50,1);` |  |
| 328 | `11. Reference Data!D47` | 11. Reference Data D47 | rounding | `=ROUND(1/C47,3)` | `round(1/C47,3);` |  |
| 329 | `11. Reference Data!D48` | 11. Reference Data D48 | rounding | `=ROUND(1/C48,3)` | `round(1/C48,3);` |  |
| 330 | `11. Reference Data!D49` | 11. Reference Data D49 | rounding | `=ROUND(1/C49,3)` | `round(1/C49,3);` |  |
| 331 | `11. Reference Data!D50` | 11. Reference Data D50 | rounding | `=ROUND(1/C50,3)` | `round(1/C50,3);` |  |

