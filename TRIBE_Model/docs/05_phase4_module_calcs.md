# Phase 4 — Module Calculations (Criteria, Capex, Opex, Flow)

## Scope

- Implement `1. Module Criteria`, `2. Module Capex`, `3. Module Opex`, `4. Module Flow` as MATLAB calc modules.

## Dependencies

- Phase 2 (ReferenceData, ProcessLibrary) and Phase 3 (RackProfile).

## Required Functions

- `tribe.calc.calcModuleCriteria(rp, ...)`
- `tribe.calc.calcModuleCapex(rp, mc, ref)`
- `tribe.calc.calcModuleOpex(rp, mc, mcapex, electricity_rate)`
- `tribe.calc.calcModuleFlow(mc, cooling_method, ref)`

## Formula Transcription List

| Sheet!Cell | Label | Excel formula | MATLAB transcription | Notes |
|---|---|---|---|---|
| `1. Module Criteria!B5` | Module IT capacity (kW) | `='0. Rack Profile'!B40` | `mc.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| `1. Module Criteria!B10` | Heat capture rate (%) | `='0. Rack Profile'!B20` | `mc.heat_capture_rate_pct = rp.heat_capture_rate_pct;` |  |
| `1. Module Criteria!B11` | Captured heat (kWth) | `=B5*B10` | `mc.captured_heat_kwth = mc.module_it_capacity_kw*mc.heat_capture_rate_pct;` |  |
| `1. Module Criteria!B12` | Capture temperature (°C) | `='0. Rack Profile'!B21` | `mc.capture_temperature_c = rp.capture_temperature_c;` |  |
| `1. Module Criteria!B17` | Heat pump COP | `=IF(B15=0,"-",MAX('11. Reference Data'!B111,MIN('11. Reference Data'!B112,ROUND('11. Reference Data'!B110*(B16+273.15)/(B16-B12),2))))` | `mc.heat_pump_cop = ifelse(mc.heat_pump_enabled==0,"-",max(ref.minimum_practical_cop,min(ref.maximum_practical_cop,round(ref.carnot_efficiency_factor*(mc.heat_pump_output_temperature_c+273.15)/(mc.heat_pump_output_temperature_c-mc.capture_temperature_c),2))));` |  |
| `1. Module Criteria!B18` | Heat pump capacity (kWth) | `=B11` | `mc.heat_pump_capacity_kwth = mc.captured_heat_kwth;` |  |
| `1. Module Criteria!B21` | Thermal output (kWth) | `=IF(B15=1,IF(B17<=1,B11,B11*B17/(B17-1)),B11)` | `mc.thermal_output_kwth = ifelse(mc.heat_pump_enabled==1,ifelse(mc.heat_pump_cop<=1,mc.captured_heat_kwth,mc.captured_heat_kwth*mc.heat_pump_cop/(mc.heat_pump_cop-1)),mc.captured_heat_kwth);` |  |
| `1. Module Criteria!B22` | Delivery temperature (°C) | `=IF(B15=1,B16,B12)` | `mc.delivery_temperature_c = ifelse(mc.heat_pump_enabled==1,mc.heat_pump_output_temperature_c,mc.capture_temperature_c);` |  |
| `1. Module Criteria!B24` | Annual heat output (MWh) | `=B21*B23*B7/1000` | `mc.annual_heat_output_mwh = mc.thermal_output_kwth*mc.hours_per_year*mc.target_utilisation_rate_pct/1000;` |  |
| `1. Module Criteria!B29` | Effective heat price (£/MWh) | `=IF(B15=1,B28,B27)` | `mc.effective_heat_price_gbp_per_mwh = ifelse(mc.heat_pump_enabled==1,mc.premium_heat_price_with_hp_gbp_per_mwh,mc.base_heat_price_no_hp_gbp_per_mwh);` |  |
| `2. Module Capex!B5` | Chipset | `='0. Rack Profile'!B6` | `mcapex.chipset = rp.chipset_type;` |  |
| `2. Module Capex!B6` | Cooling method | `='0. Rack Profile'!B17` | `mcapex.cooling_method = rp.cooling_method;` |  |
| `2. Module Capex!B7` | Racks per module | `='0. Rack Profile'!B37` | `mcapex.racks_per_module = rp.racks_per_module;` |  |
| `2. Module Capex!B8` | Servers per module | `='0. Rack Profile'!B38` | `mcapex.servers_per_module = rp.servers_per_module;` |  |
| `2. Module Capex!B9` | Module IT capacity (kW) | `='0. Rack Profile'!B40` | `mcapex.module_it_capacity_kw = rp.actual_module_it_capacity_kw;` |  |
| `2. Module Capex!B10` | Captured heat (kWth) | `='0. Rack Profile'!B43` | `mcapex.captured_heat_kwth = rp.captured_heat_kwth;` |  |
| `2. Module Capex!B13` | Container shell | `='11. Reference Data'!B71` | `mcapex.container_shell = ref.container_shell_40ft;` |  |
| `2. Module Capex!B14` | Container fit-out | `='11. Reference Data'!B72` | `mcapex.container_fit_out = ref.container_fit_out_electrical_hvac_prep;` |  |
| `2. Module Capex!B15` | Rack enclosures | `=B7*'11. Reference Data'!B73` | `mcapex.rack_enclosures = mcapex.racks_per_module*ref.rack_enclosure_42u_enclosed;` |  |
| `2. Module Capex!C15` | Rack enclosures | `=B7&" racks × £"&'11. Reference Data'!B73` | `mcapex.rack_enclosures__fixed_per_module = string(mcapex.racks_per_module) + " racks × £" + string(ref.rack_enclosure_42u_enclosed);` | text concat |
| `2. Module Capex!B16` | SUBTOTAL: ENCLOSURE | `=SUM(B13:B15)` | `mcapex.subtotal_enclosure = sum([mcapex.container_shell, mcapex.container_fit_out, mcapex.rack_enclosures]);` |  |
| `2. Module Capex!B19` | Cold plate kits | `=IF(B6="Direct-to-Chip (DTC)",B8*'11. Reference Data'!B76,0)` | `mcapex.cold_plate_kits = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.servers_per_module*ref.cold_plate_kit_per_server,0);` |  |
| `2. Module Capex!B20` | CDU (base) | `=IF(B6="Direct-to-Chip (DTC)",'11. Reference Data'!B77,0)` | `mcapex.cdu_base = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",ref.cdu_coolant_distribution_unit,0);` |  |
| `2. Module Capex!B21` | CDU (capacity scaling) | `=IF(B6="Direct-to-Chip (DTC)",B9*'11. Reference Data'!B78,0)` | `mcapex.cdu_capacity_scaling = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.module_it_capacity_kw*ref.cdu_capacity_scaling,0);` |  |
| `2. Module Capex!B22` | Manifolds & quick-connects | `=IF(B6="Direct-to-Chip (DTC)",B8*'11. Reference Data'!B79,0)` | `mcapex.manifolds_quick_connects = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",mcapex.servers_per_module*ref.manifolds_quick_connects,0);` |  |
| `2. Module Capex!B23` | Primary loop piping | `=IF(B6="Direct-to-Chip (DTC)",'11. Reference Data'!B80,0)` | `mcapex.primary_loop_piping = ifelse(mcapex.cooling_method=="Direct-to-Chip (DTC)",ref.primary_loop_piping,0);` |  |
| `2. Module Capex!B24` | SUBTOTAL: DTC COOLING | `=SUM(B19:B23)` | `mcapex.subtotal_dtc_cooling = sum([mcapex.cold_plate_kits, mcapex.cdu_base, mcapex.cdu_capacity_scaling, mcapex.manifolds_quick_connects, mcapex.primary_loop_piping]);` |  |
| `2. Module Capex!B27` | Immersion tanks | `=IF(B6="Single-Phase Immersion",B7*'11. Reference Data'!B83,IF(B6="Two-Phase Immersion",B7*'11. Reference Data'!B84,0))` | `mcapex.immersion_tanks = ifelse(mcapex.cooling_method=="Single-Phase Immersion",mcapex.racks_per_module*ref.single_phase_immersion_tank,ifelse(mcapex.cooling_method=="Two-Phase Immersion",mcapex.racks_per_module*ref.two_phase_immersion_tank,0));` |  |
| `2. Module Capex!B28` | Dielectric fluid (initial fill) | `=IF(B6="Single-Phase Immersion",B7*'11. Reference Data'!B87*'11. Reference Data'!B85,IF(B6="Two-Phase Immersion",B7*'11. Reference Data'!B88*'11. Reference Data'!B86,0))` | `mcapex.dielectric_fluid_initial_fill = ifelse(mcapex.cooling_method=="Single-Phase Immersion",mcapex.racks_per_module*ref.fluid_volume_per_rack_single_phase*ref.dielectric_fluid_single_phase,ifelse(mcapex.cooling_method=="Two-Phase Immersion",mcapex.racks_per_module*ref.fluid_volume_per_rack_two_phase*ref.dielectric_fluid_two_phase,0));` |  |
| `2. Module Capex!B29` | Fluid management system | `=IF(OR(B6="Single-Phase Immersion",B6="Two-Phase Immersion"),'11. Reference Data'!B89,0)` | `mcapex.fluid_management_system = ifelse(or(mcapex.cooling_method=="Single-Phase Immersion",mcapex.cooling_method=="Two-Phase Immersion"),ref.fluid_management_system,0);` |  |
| `2. Module Capex!B30` | SUBTOTAL: IMMERSION COOLING | `=SUM(B27:B29)` | `mcapex.subtotal_immersion_cooling = sum([mcapex.immersion_tanks, mcapex.dielectric_fluid_initial_fill, mcapex.fluid_management_system]);` |  |
| `2. Module Capex!B33` | Rack PDUs | `=B7*'11. Reference Data'!B92` | `mcapex.rack_pdus = mcapex.racks_per_module*ref.high_density_pdu_per_rack;` |  |
| `2. Module Capex!B34` | Module power distribution | `=B9*'11. Reference Data'!B93` | `mcapex.module_power_distribution = mcapex.module_it_capacity_kw*ref.module_power_distribution;` |  |
| `2. Module Capex!B35` | Electrical panels & switchgear | `='11. Reference Data'!B94` | `mcapex.electrical_panels_switchgear = ref.electrical_panels_switchgear;` |  |
| `2. Module Capex!B36` | SUBTOTAL: POWER | `=SUM(B33:B35)` | `mcapex.subtotal_power = sum([mcapex.rack_pdus, mcapex.module_power_distribution, mcapex.electrical_panels_switchgear]);` |  |
| `2. Module Capex!B39` | Primary heat exchanger (base) | `='11. Reference Data'!B97` | `mcapex.primary_heat_exchanger_base = ref.primary_heat_exchanger;` |  |
| `2. Module Capex!B40` | Heat exchanger (capacity scaling) | `=B10*'11. Reference Data'!B98` | `mcapex.heat_exchanger_capacity_scaling = mcapex.captured_heat_kwth*ref.heat_exchanger_scaling;` |  |
| `2. Module Capex!B41` | Thermal integration skid | `='11. Reference Data'!B99` | `mcapex.thermal_integration_skid = ref.thermal_integration_skid_pumps_valves;` |  |
| `2. Module Capex!B42` | Instrumentation & sensors | `='11. Reference Data'!B100` | `mcapex.instrumentation_sensors = ref.instrumentation_sensors;` |  |
| `2. Module Capex!B43` | SUBTOTAL: THERMAL | `=SUM(B39:B42)` | `mcapex.subtotal_thermal = sum([mcapex.primary_heat_exchanger_base, mcapex.heat_exchanger_capacity_scaling, mcapex.thermal_integration_skid, mcapex.instrumentation_sensors]);` |  |
| `2. Module Capex!B46` | BMS base system | `='11. Reference Data'!B103` | `mcapex.bms_base_system = ref.bms_base_system;` |  |
| `2. Module Capex!B47` | Per-rack monitoring | `=B7*'11. Reference Data'!B104` | `mcapex.per_rack_monitoring = mcapex.racks_per_module*ref.per_rack_monitoring;` |  |
| `2. Module Capex!B48` | Network infrastructure | `='11. Reference Data'!B105` | `mcapex.network_infrastructure = ref.network_infrastructure;` |  |
| `2. Module Capex!B49` | SUBTOTAL: MONITORING | `=SUM(B46:B48)` | `mcapex.subtotal_monitoring = sum([mcapex.bms_base_system, mcapex.per_rack_monitoring, mcapex.network_infrastructure]);` |  |
| `2. Module Capex!B53` | Heat pump unit | `=IF('1. Module Criteria'!B15=1,'1. Module Criteria'!B18*B52,0)` | `mcapex.heat_pump_unit = ifelse(mc.heat_pump_enabled==1,mc.heat_pump_capacity_kwth*mcapex.heat_pump_capex_rate_gbp_per_kwth,0);` |  |
| `2. Module Capex!B54` | Heat pump installation | `=IF('1. Module Criteria'!B15=1,B53*0.15,0)` | `mcapex.heat_pump_installation = ifelse(mc.heat_pump_enabled==1,mcapex.heat_pump_unit*0.15,0);` |  |
| `2. Module Capex!B55` | Heat pump controls | `=IF('1. Module Criteria'!B15=1,15000,0)` | `mcapex.heat_pump_controls = ifelse(mc.heat_pump_enabled==1,15000,0);` |  |
| `2. Module Capex!B56` | SUBTOTAL: HEAT PUMP | `=SUM(B53:B55)` | `mcapex.subtotal_heat_pump = sum([mcapex.heat_pump_unit, mcapex.heat_pump_installation, mcapex.heat_pump_controls]);` |  |
| `2. Module Capex!B59` | Premium rate (%) | `='0. Rack Profile'!B24/100` | `mcapex.premium_rate_pct = rp.capex_premium_vs_air_cooled_pct/100;` |  |
| `2. Module Capex!B60` | Applied to base infrastructure | `=(B16+B24+B30)*B59` | `mcapex.applied_to_base_infrastructure = (mcapex.subtotal_enclosure+mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling)*mcapex.premium_rate_pct;` |  |
| `2. Module Capex!B63` | Base infrastructure | `=B16+B24+B30+B36+B43+B49` | `mcapex.base_infrastructure = mcapex.subtotal_enclosure+mcapex.subtotal_dtc_cooling+mcapex.subtotal_immersion_cooling+mcapex.subtotal_power+mcapex.subtotal_thermal+mcapex.subtotal_monitoring;` |  |
| `2. Module Capex!B64` | Cooling premium | `=B60` | `mcapex.cooling_premium = mcapex.applied_to_base_infrastructure;` |  |
| `2. Module Capex!B65` | Heat pump | `=B56` | `mcapex.heat_pump = mcapex.subtotal_heat_pump;` |  |
| `2. Module Capex!B66` | TOTAL MODULE CAPEX | `=B63+B64+B65` | `mcapex.total_module_capex = mcapex.base_infrastructure+mcapex.cooling_premium+mcapex.heat_pump;` |  |
| `2. Module Capex!B68` | Capex per IT kW (£/kW) | `=B66/B9` | `mcapex.capex_per_it_kw_gbp_per_kw = mcapex.total_module_capex/mcapex.module_it_capacity_kw;` |  |
| `2. Module Capex!B69` | Capex per GPU (£/GPU) | `=B66/('0. Rack Profile'!B39)` | `mcapex.capex_per_gpu_gbp_per_gpu = mcapex.total_module_capex/(rp.gpus_per_module);` |  |
| `3. Module Opex!B6` | Infrastructure power (from PUE) | `='0. Rack Profile'!B23-1` | `mopex.infrastructure_power_from_pue = rp.pue_contribution-1;` |  |
| `3. Module Opex!B7` | Infrastructure power cost (£/yr) | `='1. Module Criteria'!B5*B6*'1. Module Criteria'!B23*B5*'1. Module Criteria'!B7` | `mopex.infrastructure_power_cost_gbp_per_yr = mc.module_it_capacity_kw*mopex.infrastructure_power_from_pue*mc.hours_per_year*mopex.electricity_rate_gbp_per_kwh*mc.target_utilisation_rate_pct;` |  |
| `3. Module Opex!B9` | Heat pump electricity (£/yr) | `=IF('1. Module Criteria'!B15=1,('1. Module Criteria'!B21/'1. Module Criteria'!B17)*'1. Module Criteria'!B23*'1. Module Criteria'!B7*B5,0)` | `mopex.heat_pump_electricity_gbp_per_yr = ifelse(mc.heat_pump_enabled==1,(mc.thermal_output_kwth/mc.heat_pump_cop)*mc.hours_per_year*mc.target_utilisation_rate_pct*mopex.electricity_rate_gbp_per_kwh,0);` |  |
| `3. Module Opex!B10` | SUBTOTAL: ELECTRICITY | `=B7+B9` | `mopex.subtotal_electricity = mopex.infrastructure_power_cost_gbp_per_yr+mopex.heat_pump_electricity_gbp_per_yr;` |  |
| `3. Module Opex!B16` | Base maintenance (£/yr) | `='2. Module Capex'!B63*B15` | `mopex.base_maintenance_gbp_per_yr = mcapex.base_infrastructure*mopex.base_maintenance_pct_of_base_capex;` |  |
| `3. Module Opex!B18` | Heat pump maintenance (£/yr) | `=IF('1. Module Criteria'!B15=1,'2. Module Capex'!B53*B17,0)` | `mopex.heat_pump_maintenance_gbp_per_yr = ifelse(mc.heat_pump_enabled==1,mcapex.heat_pump_unit*mopex.heat_pump_maintenance_pct_of_hp_capex,0);` |  |
| `3. Module Opex!B20` | Insurance (£/yr) | `='2. Module Capex'!B66*B19` | `mopex.insurance_gbp_per_yr = mcapex.total_module_capex*mopex.insurance_pct_of_total_capex;` |  |
| `3. Module Opex!B21` | SUBTOTAL: MAINTENANCE & INSURANCE | `=B16+B18+B20` | `mopex.subtotal_maintenance_insurance = mopex.base_maintenance_gbp_per_yr+mopex.heat_pump_maintenance_gbp_per_yr+mopex.insurance_gbp_per_yr;` |  |
| `3. Module Opex!B27` | SUBTOTAL: OTHER | `=SUM(B24:B26)` | `mopex.subtotal_other = sum([mopex.site_lease_per_licence_gbp_per_yr, mopex.remote_monitoring_noc_gbp_per_yr, mopex.connectivity_admin_gbp_per_yr]);` |  |
| `3. Module Opex!B29` | TOTAL MODULE OPEX (£/yr) | `=B10+B21+B27` | `mopex.total_module_opex_gbp_per_yr = mopex.subtotal_electricity+mopex.subtotal_maintenance_insurance+mopex.subtotal_other;` |  |
| `4. Module Flow!B9` | Thermal power (kWth) | `='1. Module Criteria'!B11` | `mflow.thermal_power_kwth = mc.captured_heat_kwth;` |  |
| `4. Module Flow!B10` | Inlet temperature (°C) | `='1. Module Criteria'!B12` | `mflow.inlet_temperature_c = mc.capture_temperature_c;` |  |
| `4. Module Flow!B11` | Source loop ΔT (°C) | `=IF('0. Rack Profile'!B17="Direct-to-Chip (DTC)",'11. Reference Data'!E23,IF('0. Rack Profile'!B17="Single-Phase Immersion",'11. Reference Data'!E24,IF('0. Rack Profile'!B17="Two-Phase Immersion",'11. Reference Data'!E25,IF('0. Rack Profile'!B17="Rear Door Heat Exchanger",'11. Reference Data'!E26,'11. Reference Data'!E27))))` | `mflow.source_loop_deltat_c = ifelse(rp.cooling_method=="Direct-to-Chip (DTC)",ref.direct_to_chip_dtc__source_deltat_c,ifelse(rp.cooling_method=="Single-Phase Immersion",ref.single_phase_immersion__source_deltat_c,ifelse(rp.cooling_method=="Two-Phase Immersion",ref.two_phase_immersion__source_deltat_c,ifelse(rp.cooling_method=="Rear Door Heat Exchanger",ref.rear_door_heat_exchanger__source_deltat_c,ref.air_cooled_reference__source_deltat_c))));` |  |
| `4. Module Flow!B12` | Outlet temperature (°C) | `=B10-B11` | `mflow.outlet_temperature_c = mflow.inlet_temperature_c-mflow.source_loop_deltat_c;` |  |
| `4. Module Flow!B14` | Mass flow rate (kg/s) | `=B9/(B5*B11)` | `mflow.mass_flow_rate_kg_per_s = mflow.thermal_power_kwth/(mflow.specific_heat_of_water_kj_per_kg_k*mflow.source_loop_deltat_c);` |  |
| `4. Module Flow!B15` | Volume flow rate (L/s) | `=B14/B6` | `mflow.volume_flow_rate_l_per_s = mflow.mass_flow_rate_kg_per_s/mflow.water_density_kg_per_l;` |  |
| `4. Module Flow!B16` | Volume flow rate (m³/hr) | `=B15*3.6` | `mflow.volume_flow_rate_m3_per_hr = mflow.volume_flow_rate_l_per_s*3.6;` |  |
| `4. Module Flow!B19` | Thermal power delivered (kWth) | `='1. Module Criteria'!B21` | `mflow.thermal_power_delivered_kwth = mc.thermal_output_kwth;` |  |
| `4. Module Flow!B20` | Outlet temperature (°C) | `='1. Module Criteria'!B22` | `mflow.outlet_temperature_c__b20 = mc.delivery_temperature_c;` |  |
| `4. Module Flow!B22` | Return temperature (°C) | `=B20-B21` | `mflow.return_temperature_c = mflow.outlet_temperature_c__b20-mflow.sink_loop_deltat_c;` |  |
| `4. Module Flow!B24` | Mass flow rate (kg/s) | `=B19/(B5*B21)` | `mflow.mass_flow_rate_kg_per_s__b24 = mflow.thermal_power_delivered_kwth/(mflow.specific_heat_of_water_kj_per_kg_k*mflow.sink_loop_deltat_c);` |  |
| `4. Module Flow!B25` | Volume flow rate (L/s) | `=B24/B6` | `mflow.volume_flow_rate_l_per_s__b25 = mflow.mass_flow_rate_kg_per_s__b24/mflow.water_density_kg_per_l;` |  |
| `4. Module Flow!B26` | Volume flow rate (m³/hr) | `=B25*3.6` | `mflow.volume_flow_rate_m3_per_hr__b26 = mflow.volume_flow_rate_l_per_s__b25*3.6;` |  |
| `4. Module Flow!B30` | Source loop pipe ID (mm) | `=SQRT((B15/1000)/(B29*3.14159/4))*1000` | `mflow.source_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s/1000)/(mflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| `4. Module Flow!B31` | Sink loop pipe ID (mm) | `=SQRT((B25/1000)/(B29*3.14159/4))*1000` | `mflow.sink_loop_pipe_id_mm = sqrt((mflow.volume_flow_rate_l_per_s__b25/1000)/(mflow.design_velocity_m_per_s*3.14159/4))*1000;` |  |
| `4. Module Flow!B33` | Source loop - nearest DN | `=IF(B30<28,"DN25",IF(B30<36,"DN32",IF(B30<42,"DN40",IF(B30<54,"DN50",IF(B30<68,"DN65",IF(B30<82,"DN80",IF(B30<107,"DN100","DN125+")))))))` | `mflow.source_loop_nearest_dn = ifelse(mflow.source_loop_pipe_id_mm<28,"DN25",ifelse(mflow.source_loop_pipe_id_mm<36,"DN32",ifelse(mflow.source_loop_pipe_id_mm<42,"DN40",ifelse(mflow.source_loop_pipe_id_mm<54,"DN50",ifelse(mflow.source_loop_pipe_id_mm<68,"DN65",ifelse(mflow.source_loop_pipe_id_mm<82,"DN80",ifelse(mflow.source_loop_pipe_id_mm<107,"DN100","DN125+")))))));` |  |
| `4. Module Flow!B34` | Sink loop - nearest DN | `=IF(B31<28,"DN25",IF(B31<36,"DN32",IF(B31<42,"DN40",IF(B31<54,"DN50",IF(B31<68,"DN65",IF(B31<82,"DN80",IF(B31<107,"DN100","DN125+")))))))` | `mflow.sink_loop_nearest_dn = ifelse(mflow.sink_loop_pipe_id_mm<28,"DN25",ifelse(mflow.sink_loop_pipe_id_mm<36,"DN32",ifelse(mflow.sink_loop_pipe_id_mm<42,"DN40",ifelse(mflow.sink_loop_pipe_id_mm<54,"DN50",ifelse(mflow.sink_loop_pipe_id_mm<68,"DN65",ifelse(mflow.sink_loop_pipe_id_mm<82,"DN80",ifelse(mflow.sink_loop_pipe_id_mm<107,"DN100","DN125+")))))));` |  |
| `4. Module Flow!B37` | Thermal capacity (kWth) | `=B19` | `mflow.thermal_capacity_kwth = mflow.thermal_power_delivered_kwth;` |  |
| `4. Module Flow!B38` | Delivery temperature (°C) | `=B20` | `mflow.delivery_temperature_c = mflow.outlet_temperature_c__b20;` |  |
| `4. Module Flow!B39` | Flow capacity (m³/hr) | `=B26` | `mflow.flow_capacity_m3_per_hr = mflow.volume_flow_rate_m3_per_hr__b26;` |  |

## Validation Criteria

- Chain: `RackProfile → ModuleCriteria → ModuleCapex/Opex/Flow` matches Excel for default inputs.
- Heat pump toggle (`1. Module Criteria!B15`) correctly turns HP capex/opex on/off.

