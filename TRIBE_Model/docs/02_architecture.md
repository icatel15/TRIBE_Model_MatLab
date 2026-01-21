# MATLAB Architecture

## Proposed Repository Layout

```text
TRIBE_Model/
├── +tribe/                    % Package namespace
│   ├── +data/                 % Reference data modules
│   ├── +calc/                 % Calculation modules (one per sheet)
│   ├── +util/                 % Utility helpers (Excel-ish functions, validation, units)
│   └── Config.m               % Configuration class
├── tests/                     % Unit tests
├── examples/                  % Usage examples
├── validation/                % Excel comparison scripts
└── main.m                     % Entry point
```

## Naming Conventions

- Use MATLAB **string scalars** for categorical values (e.g., chipset, cooling method).
- Struct fields use `snake_case`, derived from the Excel row label.
- Include only cells that participate in calculations (formula cells, yellow inputs, referenced constants).
- Percentages: Excel stores most % as **fractions** (e.g., 0.75), even when the label shows `%`.

### Sheet → Struct Variable Names

| Excel sheet | MATLAB var | Struct name |
|---|---|---|
| 0. Rack Profile | `rp` | `RackProfile` |
| 1. Module Criteria | `mc` | `ModuleCriteria` |
| 2. Module Capex | `mcapex` | `ModuleCapex` |
| 3. Module Opex | `mopex` | `ModuleOpex` |
| 4. Module Flow | `mflow` | `ModuleFlow` |
| 5. Buyer Profile | `bp` | `BuyerProfile` |
| 6. System Capex | `scapex` | `SystemCapex` |
| 7. System Opex | `sopex` | `SystemOpex` |
| 8. System Flow | `sflow` | `SystemFlow` |
| 9. System P&L | `spl` | `SystemPL` |

## Excel → MATLAB Function Mappings (Used in Transcriptions)

- `IF(cond,a,b)` → `ifelse(cond,a,b)` (utility helper or explicit `if/else`)
- `IFERROR(x,fallback)` → `iferror(x,fallback)` (utility helper, or explicit guard)
- `ISNUMBER(x)` → `isnumber(x)` (utility helper; often becomes `isnumeric`/`~isnan` depending on representation)
- `ROUND(x,n)` → `round(x,n)`
- `ROUNDUP(x,0)` → `ceil(x)` (or keep `roundup(x,0)` helper)
- `ROUNDDOWN(x,0)` → `floor(x)` (or keep `rounddown(x,0)` helper)
- `MAX/MIN/SUM/SQRT` → `max/min/sum/sqrt`
- Text concat `a & b` → `a + string(b)` (string scalars) or `sprintf(...)`

## Data Structures (Field Inventory)

Field lists below are derived from the workbook row labels and filtered to cells that participate in calculations.

### 0. Rack Profile → `rp`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset_type` | `0. Rack Profile!B6` | string |  | Define GPU hardware to determine power and cooling requirements |
| `tdp_per_chip_w` | `0. Rack Profile!B9` | double | W | Establish base power draw for thermal calculations |
| `chips_per_server` | `0. Rack Profile!B10` | double |  | Configure server density for rack power calculations |
| `server_power_kw` | `0. Rack Profile!B11` | double | kW | Calculate total server power including overhead for sizing |
| `max_junction_temp_c` | `0. Rack Profile!B12` | double | °C | Define thermal limits to ensure safe GPU operation |
| `recommended_coolant_inlet_c` | `0. Rack Profile!B13` | double | °C | Set cooling system design temperature |
| `cooling_method` | `0. Rack Profile!B17` | string |  | Select cooling technology to determine heat capture and costs |
| `heat_capture_rate_pct` | `0. Rack Profile!B20` | double | % | Quantify recoverable heat for revenue calculations |
| `capture_temperature_c` | `0. Rack Profile!B21` | double | °C | Determine heat quality for buyer matching |
| `coolant_type` | `0. Rack Profile!B22` | string |  | Specify fluid for equipment selection |
| `pue_contribution` | `0. Rack Profile!B23` | double |  | Model infrastructure efficiency for opex calculations |
| `capex_premium_vs_air_cooled_pct` | `0. Rack Profile!B24` | double | % | Account for cooling technology cost differences |
| `rack_thermal_limit_kw_per_rack` | `0. Rack Profile!B25` | double | kW/rack | Set rack density constraint for module sizing |
| `servers_per_rack` | `0. Rack Profile!B29` | double |  | Calculate achievable density within thermal limits |
| `gpus_per_rack` | `0. Rack Profile!B30` | double |  | Compute total GPU capacity per rack |
| `actual_rack_power_kw` | `0. Rack Profile!B31` | double | kW | Determine actual power for infrastructure sizing |
| `rack_thermal_utilisation_pct` | `0. Rack Profile!B32` | double | % | Assess how well rack capacity is used |
| `module_it_capacity_target_kw` | `0. Rack Profile!B36` | double | kW | Define standardised module size for business model |
| `racks_per_module` | `0. Rack Profile!B37` | double |  | Calculate rack count to meet module capacity target |
| `servers_per_module` | `0. Rack Profile!B38` | double |  | Aggregate compute capacity at module level |
| `gpus_per_module` | `0. Rack Profile!B39` | double |  | Aggregate compute capacity at module level |
| `actual_module_it_capacity_kw` | `0. Rack Profile!B40` | double | kW | Define standardised module size for business model |
| `captured_heat_kwth` | `0. Rack Profile!B43` | double | kWth | Calculate heat available for sale to buyers |
| `capture_temperature_c__b44` | `0. Rack Profile!B44` | double | °C | Determine heat quality for buyer matching |
| `residual_heat_to_air_kwth` | `0. Rack Profile!B45` | double | kWth | Identify heat requiring rejection (cost) |
| `heat_capture_quality` | `0. Rack Profile!B49` | string |  | Classify heat grade for buyer matching |
| `heat_pump_requirement` | `0. Rack Profile!B50` | string |  | Determine if temperature boost needed for applications |
| `recommended_hp_output_c` | `0. Rack Profile!B51` | double | °C | Model parameter |
| `estimated_cop_at_recommended_output` | `0. Rack Profile!B52` | double |  | Calculate heat pump efficiency for economics |
| `target_output_temperature_c` | `0. Rack Profile!B57` | double | °C | Temperature parameter for thermal design |
| `electricity_price_gbp_per_kwh` | `0. Rack Profile!B58` | double | £/kWh | Financial input or calculation |
| `temperature_lift_k` | `0. Rack Profile!B60` | double | K | Define upgrade required from source to delivery temp |
| `cop_at_this_lift` | `0. Rack Profile!B61` | double |  | Calculate heat pump efficiency for economics |
| `hp_electricity_per_kwth_captured` | `0. Rack Profile!B62` | double | kWth | Model heat pump operating cost |
| `total_heat_output_per_kw_it` | `0. Rack Profile!B63` | double | per kW IT | Calculate annual heat sales volume |
| `hp_electricity_cost_gbp_per_kwth_hr` | `0. Rack Profile!B64` | double | £/kWth·hr | Model heat pump operating cost |
| `annual_operating_hours` | `0. Rack Profile!B67` | double |  | Model parameter |
| `heat_delivered_mwh_per_yr` | `0. Rack Profile!B68` | double | MWh/yr | Calculate annual heat sales volume |
| `hp_electricity_mwh_per_yr` | `0. Rack Profile!B69` | double | MWh/yr | Model heat pump operating cost |
| `hp_electricity_cost_gbp_per_yr` | `0. Rack Profile!B70` | double | £/yr | Model heat pump operating cost |

### 1. Module Criteria → `mc`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `module_it_capacity_kw` | `1. Module Criteria!B5` | double | kW | Pull standardised module size for consistent sizing |
| `compute_rate_gbp_per_kw_per_month` | `1. Module Criteria!B6` | double | £/kW/month | Financial input or calculation |
| `target_utilisation_rate_pct` | `1. Module Criteria!B7` | double | % | Model realistic capacity usage for revenue |
| `heat_capture_rate_pct` | `1. Module Criteria!B10` | double | % | Reference thermal specifications from rack design |
| `captured_heat_kwth` | `1. Module Criteria!B11` | double | kWth | Power or thermal capacity metric |
| `capture_temperature_c` | `1. Module Criteria!B12` | double | °C | Temperature parameter for thermal design |
| `heat_pump_enabled` | `1. Module Criteria!B15` | logical (0/1) |  | Toggle heat pump for scenario analysis |
| `heat_pump_output_temperature_c` | `1. Module Criteria!B16` | double | °C | Temperature parameter for thermal design |
| `heat_pump_cop` | `1. Module Criteria!B17` | double |  | Calculate heat pump efficiency at operating conditions |
| `heat_pump_capacity_kwth` | `1. Module Criteria!B18` | double | kWth | Define or calculate system capability |
| `thermal_output_kwth` | `1. Module Criteria!B21` | double | kWth | Calculate total heat delivery including HP boost |
| `delivery_temperature_c` | `1. Module Criteria!B22` | double | °C | Set required output temperature for buyer |
| `hours_per_year` | `1. Module Criteria!B23` | double |  | Model parameter |
| `annual_heat_output_mwh` | `1. Module Criteria!B24` | double | MWh | Convert to annual volume for revenue calculation |
| `base_heat_price_no_hp_gbp_per_mwh` | `1. Module Criteria!B27` | double | £/MWh | Set heat sales price assumption |
| `premium_heat_price_with_hp_gbp_per_mwh` | `1. Module Criteria!B28` | double | £/MWh | Set heat sales price assumption |
| `effective_heat_price_gbp_per_mwh` | `1. Module Criteria!B29` | double | £/MWh | Set heat sales price assumption |
| `reference_industrial_gas_price_gbp_per_mwh` | `1. Module Criteria!B30` | double | £/MWh | Financial input or calculation |

### 2. Module Capex → `mcapex`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset` | `2. Module Capex!B5` | string |  | Model parameter |
| `cooling_method` | `2. Module Capex!B6` | string |  | Model parameter |
| `racks_per_module` | `2. Module Capex!B7` | double |  | Model parameter |
| `servers_per_module` | `2. Module Capex!B8` | double |  | Model parameter |
| `module_it_capacity_kw` | `2. Module Capex!B9` | double | kW | Define or calculate system capability |
| `captured_heat_kwth` | `2. Module Capex!B10` | double | kWth | Power or thermal capacity metric |
| `container_shell` | `2. Module Capex!B13` | double |  | Cost modular enclosure structure |
| `container_fit_out` | `2. Module Capex!B14` | double |  | Cost modular enclosure structure |
| `rack_enclosures` | `2. Module Capex!B15` | double |  | Cost per-rack housing |
| `rack_enclosures__fixed_per_module` | `2. Module Capex!C15` | string |  | Cost per-rack housing |
| `subtotal_enclosure` | `2. Module Capex!B16` | double |  | Subtotal enclosure costs for module |
| `dtc_cooling` | `2. Module Capex!B18` | string |  | Section for DTC-specific equipment |
| `cold_plate_kits` | `2. Module Capex!B19` | double |  | Cost DTC cooling hardware per server |
| `cdu_base` | `2. Module Capex!B20` | double | base | Cost coolant distribution unit |
| `cdu_capacity_scaling` | `2. Module Capex!B21` | double | capacity scaling | Cost coolant distribution unit |
| `manifolds_quick_connects` | `2. Module Capex!B22` | double |  | Cost fluid distribution to racks |
| `primary_loop_piping` | `2. Module Capex!B23` | double |  | Cost primary cooling loop |
| `subtotal_dtc_cooling` | `2. Module Capex!B24` | double |  | Subtotal DTC cooling costs |
| `immersion_tanks` | `2. Module Capex!B27` | double |  | Cost immersion cooling vessels |
| `dielectric_fluid_initial_fill` | `2. Module Capex!B28` | double | initial fill | Cost cooling fluid initial fill |
| `fluid_management_system` | `2. Module Capex!B29` | double |  | Cost cooling fluid initial fill |
| `subtotal_immersion_cooling` | `2. Module Capex!B30` | double |  | Subtotal immersion cooling costs |
| `rack_pdus` | `2. Module Capex!B33` | double |  | Cost power distribution per rack |
| `module_power_distribution` | `2. Module Capex!B34` | double |  | Cost module-level electrical |
| `electrical_panels_switchgear` | `2. Module Capex!B35` | double |  | Cost electrical switching equipment |
| `subtotal_power` | `2. Module Capex!B36` | double |  | Subtotal power distribution costs |
| `primary_heat_exchanger_base` | `2. Module Capex!B39` | double | base | Cost thermal interface equipment |
| `heat_exchanger_capacity_scaling` | `2. Module Capex!B40` | double | capacity scaling | Cost thermal interface equipment |
| `thermal_integration_skid` | `2. Module Capex!B41` | double |  | Cost heat delivery infrastructure |
| `instrumentation_sensors` | `2. Module Capex!B42` | double |  | Cost monitoring equipment |
| `subtotal_thermal` | `2. Module Capex!B43` | double |  | Subtotal thermal integration costs |
| `bms_base_system` | `2. Module Capex!B46` | double |  | Cost building management system |
| `per_rack_monitoring` | `2. Module Capex!B47` | double |  | Cost per-rack monitoring |
| `network_infrastructure` | `2. Module Capex!B48` | double |  | Cost network infrastructure |
| `subtotal_monitoring` | `2. Module Capex!B49` | double |  | Subtotal monitoring costs |
| `heat_pump_capex_rate_gbp_per_kwth` | `2. Module Capex!B52` | double | £/kWth | Financial input or calculation |
| `heat_pump_unit` | `2. Module Capex!B53` | double |  | Cost heat pump equipment |
| `heat_pump_installation` | `2. Module Capex!B54` | double |  | Cost heat pump installation |
| `heat_pump_controls` | `2. Module Capex!B55` | double |  | Cost heat pump control systems |
| `subtotal_heat_pump` | `2. Module Capex!B56` | double |  | Subtotal heat pump costs |
| `premium_rate_pct` | `2. Module Capex!B59` | double | % | Apply cooling technology cost premium |
| `applied_to_base_infrastructure` | `2. Module Capex!B60` | double |  | Model parameter |
| `base_infrastructure` | `2. Module Capex!B63` | double |  | Model parameter |
| `cooling_premium` | `2. Module Capex!B64` | double |  | Apply cooling technology cost premium |
| `heat_pump` | `2. Module Capex!B65` | double |  | Model parameter |
| `total_module_capex` | `2. Module Capex!B66` | double |  | Sum all capital costs for investment analysis |
| `capex_per_it_kw_gbp_per_kw` | `2. Module Capex!B68` | double | £/kW | Calculate unit cost metric for comparison |
| `capex_per_gpu_gbp_per_gpu` | `2. Module Capex!B69` | double | £/GPU | Calculate unit cost metric for comparison |

### 3. Module Opex → `mopex`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `electricity_rate_gbp_per_kwh` | `3. Module Opex!B5` | double | £/kWh | Set electricity cost assumption |
| `infrastructure_power_from_pue` | `3. Module Opex!B6` | double | from PUE | Calculate cooling/support power draw |
| `infrastructure_power_cost_gbp_per_yr` | `3. Module Opex!B7` | double | £/yr | Calculate cooling/support power draw |
| `heat_pump_electricity_gbp_per_yr` | `3. Module Opex!B9` | double | £/yr | Model heat pump operating expense |
| `subtotal_electricity` | `3. Module Opex!B10` | double |  | Subtotal electricity costs |
| `base_maintenance_pct_of_base_capex` | `3. Module Opex!B15` | double | % of base capex | Model ongoing maintenance expense |
| `base_maintenance_gbp_per_yr` | `3. Module Opex!B16` | double | £/yr | Model ongoing maintenance expense |
| `heat_pump_maintenance_pct_of_hp_capex` | `3. Module Opex!B17` | double | % of HP capex | Model ongoing maintenance expense |
| `heat_pump_maintenance_gbp_per_yr` | `3. Module Opex!B18` | double | £/yr | Model ongoing maintenance expense |
| `insurance_pct_of_total_capex` | `3. Module Opex!B19` | double | % of total capex | Model insurance expense |
| `insurance_gbp_per_yr` | `3. Module Opex!B20` | double | £/yr | Model insurance expense |
| `subtotal_maintenance_insurance` | `3. Module Opex!B21` | double |  | Subtotal maintenance and insurance |
| `site_lease_per_licence_gbp_per_yr` | `3. Module Opex!B24` | double | £/yr | Model overhead operating expenses |
| `remote_monitoring_noc_gbp_per_yr` | `3. Module Opex!B25` | double | £/yr | Model overhead operating expenses |
| `connectivity_admin_gbp_per_yr` | `3. Module Opex!B26` | double | £/yr | Model overhead operating expenses |
| `subtotal_other` | `3. Module Opex!B27` | double |  | Subtotal other operating costs |
| `total_module_opex_gbp_per_yr` | `3. Module Opex!B29` | double | £/yr | Sum operating costs for profitability analysis |

### 4. Module Flow → `mflow`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `specific_heat_of_water_kj_per_kg_k` | `4. Module Flow!B5` | double | kJ/kg·K | Model parameter |
| `water_density_kg_per_l` | `4. Module Flow!B6` | double | kg/L | Model parameter |
| `thermal_power_kwth` | `4. Module Flow!B9` | double | kWth | Pull heat load for flow calculations |
| `inlet_temperature_c` | `4. Module Flow!B10` | double | °C | Define temperature differential for flow sizing |
| `source_loop_deltat_c` | `4. Module Flow!B11` | double | °C | Set temperature drop across heat source |
| `outlet_temperature_c` | `4. Module Flow!B12` | double | °C | Define temperature differential for flow sizing |
| `mass_flow_rate_kg_per_s` | `4. Module Flow!B14` | double | kg/s | Calculate required fluid flow rate |
| `volume_flow_rate_l_per_s` | `4. Module Flow!B15` | double | L/s | Convert to volumetric flow for pipe sizing |
| `volume_flow_rate_m3_per_hr` | `4. Module Flow!B16` | double | m³/hr | Convert to volumetric flow for pipe sizing |
| `thermal_power_delivered_kwth` | `4. Module Flow!B19` | double | kWth | Pull heat load for flow calculations |
| `outlet_temperature_c__b20` | `4. Module Flow!B20` | double | °C | Define temperature differential for flow sizing |
| `sink_loop_deltat_c` | `4. Module Flow!B21` | double | °C | Model parameter |
| `return_temperature_c` | `4. Module Flow!B22` | double | °C | Calculate return water temperature |
| `mass_flow_rate_kg_per_s__b24` | `4. Module Flow!B24` | double | kg/s | Calculate required fluid flow rate |
| `volume_flow_rate_l_per_s__b25` | `4. Module Flow!B25` | double | L/s | Convert to volumetric flow for pipe sizing |
| `volume_flow_rate_m3_per_hr__b26` | `4. Module Flow!B26` | double | m³/hr | Convert to volumetric flow for pipe sizing |
| `design_velocity_m_per_s` | `4. Module Flow!B29` | double | m/s | Model parameter |
| `source_loop_pipe_id_mm` | `4. Module Flow!B30` | double | mm | Size piping for required flow |
| `sink_loop_pipe_id_mm` | `4. Module Flow!B31` | double | mm | Size piping for required flow |
| `source_loop_nearest_dn` | `4. Module Flow!B33` | string |  | Select standard pipe size |
| `sink_loop_nearest_dn` | `4. Module Flow!B34` | string |  | Select standard pipe size |
| `thermal_capacity_kwth` | `4. Module Flow!B37` | double | kWth | Summarise module heat delivery capability |
| `delivery_temperature_c` | `4. Module Flow!B38` | double | °C | Summarise module output temperature |
| `flow_capacity_m3_per_hr` | `4. Module Flow!B39` | double | m³/hr | Summarise module flow capability |

### 5. Buyer Profile → `bp`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset` | `5. Buyer Profile!B5` | string |  | Pull system configuration for context |
| `cooling_method` | `5. Buyer Profile!B6` | string |  | Pull system configuration for context |
| `gpus_per_module` | `5. Buyer Profile!B7` | double |  | Pull system configuration for context |
| `module_it_capacity_kw` | `5. Buyer Profile!B8` | double | kW | Pull module size for calculations |
| `select_process` | `5. Buyer Profile!B11` | string |  | User input to select industrial heat buyer |
| `process_name` | `5. Buyer Profile!B14` | string |  | Look up selected process details |
| `size_category` | `5. Buyer Profile!B15` | string |  | Identify process scale |
| `required_temperature_c` | `5. Buyer Profile!B16` | double | °C | Pull buyer's temperature requirement |
| `heat_demand_kwth` | `5. Buyer Profile!B17` | double | kWth | Pull buyer's thermal load requirement |
| `operating_hours_per_year` | `5. Buyer Profile!B18` | double |  | Pull buyer's usage pattern |
| `notes` | `5. Buyer Profile!B19` | string |  | Pull process context information |
| `source` | `5. Buyer Profile!B20` | string |  | Reference data provenance |
| `source_url` | `5. Buyer Profile!B21` | string |  | Reference data provenance |
| `annual_heat_demand_mwh` | `5. Buyer Profile!B24` | double | MWh | Pull buyer's thermal load requirement |
| `process_deltat_c` | `5. Buyer Profile!B25` | double | °C | Pull process temperature differential |
| `required_flow_rate_m3_per_hr` | `5. Buyer Profile!B26` | double | m³/hr | Calculate buyer's flow requirement |
| `module_thermal_capacity_kwth` | `5. Buyer Profile!B29` | double | kWth | Pull single module heat output |
| `module_delivery_temp_c` | `5. Buyer Profile!B30` | double | °C | Pull module output temperature |
| `module_flow_capacity_m3_per_hr` | `5. Buyer Profile!B31` | double | m³/hr | Pull single module flow capacity |
| `temperature_compatible` | `5. Buyer Profile!B33` | string |  | Check if system meets buyer temp needs |
| `modules_needed_thermal` | `5. Buyer Profile!B34` | double | thermal | Calculate modules for thermal demand |
| `modules_if_flow_constrained_reference` | `5. Buyer Profile!B35` | double | reference | Calculate modules if flow-constrained |
| `modules_required` | `5. Buyer Profile!B36` | double |  | Determine final module count for system sizing |
| `flow_deficit_m3_per_hr` | `5. Buyer Profile!B37` | double | m³/hr | Identify shortfall requiring augmentation |
| `flow_ratio_buyer_per_system` | `5. Buyer Profile!B38` | double | buyer/system | Compare buyer need to system capacity |
| `system_thermal_capacity_kwth` | `5. Buyer Profile!B41` | double | kWth | Calculate total system heat output |
| `system_flow_capacity_m3_per_hr` | `5. Buyer Profile!B42` | double | m³/hr | Calculate total system flow |
| `thermal_utilisation_pct` | `5. Buyer Profile!B43` | double | % | Measure how much heat capacity is used |
| `flow_utilisation_pct` | `5. Buyer Profile!B44` | double | % | Measure how much flow capacity is used |
| `hydraulic_augmentation_needed` | `5. Buyer Profile!B45` | string |  | Flag if pumps needed for flow boost |
| `system_heat_generation_kwth` | `5. Buyer Profile!B48` | double | kWth | Total heat produced by system |
| `buyer_heat_absorption_kwth` | `5. Buyer Profile!B49` | double | kWth | Actual heat buyer can use |
| `excess_heat_kwth` | `5. Buyer Profile!B50` | double | kWth | Heat requiring rejection |
| `excess_heat_pct` | `5. Buyer Profile!B51` | double | % | Heat requiring rejection |
| `heat_rejection_required` | `5. Buyer Profile!B52` | string |  | Size and cost rejection equipment |
| `rejection_method` | `5. Buyer Profile!B53` | string |  | Select appropriate rejection technology |
| `rejection_capacity_required_kwth` | `5. Buyer Profile!B54` | double | kWth | Size rejection equipment |
| `rejection_capex_rate_gbp_per_kwth` | `5. Buyer Profile!B55` | double | £/kWth | Cost heat rejection |
| `rejection_opex_rate_gbp_per_kwth_per_yr` | `5. Buyer Profile!B56` | double | £/kWth/yr | Cost heat rejection |
| `rejection_capex_gbp` | `5. Buyer Profile!B57` | double | £ | Cost heat rejection |
| `annual_rejection_opex_gbp_per_yr` | `5. Buyer Profile!B58` | double | £/yr | Cost heat rejection |
| `total_modules_required` | `5. Buyer Profile!B66` | double |  | Determine final module count |
| `total_it_capacity_kw` | `5. Buyer Profile!B67` | double | kW | Summarise compute capacity |
| `total_rack_units_42u_racks_10kw` | `5. Buyer Profile!B68` | double | 42U racks @ 10kW | Sum components for analysis |
| `heat_pump_required` | `5. Buyer Profile!B71` | string |  | Check if HP needed for buyer |
| `temperature_lift_required_k` | `5. Buyer Profile!B72` | double | K | Calculate required HP boost |
| `heat_pump_units` | `5. Buyer Profile!B73` | double |  | Count HP equipment needed |
| `total_hp_capacity_kwth` | `5. Buyer Profile!B74` | double | kWth | Size total HP thermal capacity |
| `hp_electrical_demand_kw` | `5. Buyer Profile!B75` | double | kW | Calculate HP power consumption |
| `source_loop_pumps` | `5. Buyer Profile!B78` | double |  | Reference data provenance |
| `sink_loop_pumps` | `5. Buyer Profile!B79` | double |  | Size circulation equipment |
| `total_system_flow_m3_per_hr` | `5. Buyer Profile!B80` | double | m³/hr | Sum components for analysis |
| `header_pipe_size_estimate_dn` | `5. Buyer Profile!B81` | string | DN | Size main distribution piping |
| `buffer_tank_recommended` | `5. Buyer Profile!B82` | string |  | Flag if thermal buffer needed |
| `flow_augmentation_pump_m3_per_hr` | `5. Buyer Profile!B83` | double | m³/hr | Size circulation equipment |
| `mixing_valve_required` | `5. Buyer Profile!B84` | string |  | Flag if temperature control needed |
| `augmentation_pump_power_kw` | `5. Buyer Profile!B85` | double | kW | Size circulation equipment |
| `augmentation_pumps_required` | `5. Buyer Profile!B86` | double |  | Size circulation equipment |
| `augmentation_pump_capacity_m3_per_hr` | `5. Buyer Profile!B87` | double | m³/hr | Size circulation equipment |
| `augmented_system_flow_m3_per_hr` | `5. Buyer Profile!B88` | double | m³/hr | Fluid flow parameter for hydraulic design |
| `flow_requirement_met` | `5. Buyer Profile!B89` | string |  | Fluid flow parameter for hydraulic design |
| `it_load_kw` | `5. Buyer Profile!B93` | double | kW | Calculate IT electrical demand |
| `cooling_infrastructure_kw` | `5. Buyer Profile!B94` | double | kW | Calculate cooling electrical demand |
| `heat_pump_load_kw` | `5. Buyer Profile!B95` | double | kW | Size circulation equipment |
| `total_electrical_demand_kw` | `5. Buyer Profile!B96` | double | kW | Sum all electrical loads |
| `grid_connection_kva_0_9_pf` | `5. Buyer Profile!B97` | double | kVA @ 0.9 PF | Size grid supply requirement |
| `module_footprint_each_m` | `5. Buyer Profile!B100` | double | m² | Calculate space requirements |
| `total_module_footprint_m` | `5. Buyer Profile!B101` | double | m² | Calculate space requirements |
| `plant_room_allowance_m` | `5. Buyer Profile!B102` | double | m² | Allocate support equipment space |
| `total_site_area_m` | `5. Buyer Profile!B103` | double | m² | Calculate space requirements |
| `modular_dc_units_250kw_it` | `5. Buyer Profile!B107` | double | 250kW IT | Generate equipment list for procurement |
| `heat_pump_units__b108` | `5. Buyer Profile!B108` | double |  | Count HP equipment needed |
| `42u_server_racks` | `5. Buyer Profile!B109` | double |  | Generate equipment list for procurement |
| `source_circulation_pumps` | `5. Buyer Profile!B110` | double |  | Reference data provenance |
| `sink_circulation_pumps` | `5. Buyer Profile!B111` | double |  | Size circulation equipment |
| `plate_heat_exchangers` | `5. Buyer Profile!B112` | double |  | Model parameter |
| `buffer_tank` | `5. Buyer Profile!B113` | double |  | Flag if thermal buffer needed |
| `bms_per_controls_package` | `5. Buyer Profile!B114` | double |  | Model parameter |
| `flow_augmentation_pumps` | `5. Buyer Profile!B115` | double |  | Size circulation equipment |
| `mixing_valves` | `5. Buyer Profile!B116` | double |  | Flag if temperature control needed |

### 6. System Capex → `scapex`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset` | `6. System Capex!B5` | string |  | Model parameter |
| `cooling_method` | `6. System Capex!B6` | string |  | Model parameter |
| `gpus_per_module` | `6. System Capex!B7` | double |  | Model parameter |
| `selected_buyer_profile` | `6. System Capex!B10` | string |  | Model parameter |
| `modules_required` | `6. System Capex!B11` | double |  | Pull module count from buyer sizing |
| `enclosure_structure` | `6. System Capex!B14` | double |  | Pull per-module enclosure cost |
| `cooling_system` | `6. System Capex!B15` | double |  | Pull per-module cooling cost |
| `power_distribution` | `6. System Capex!B16` | double |  | Pull per-module power cost |
| `thermal_integration` | `6. System Capex!B17` | double |  | Pull per-module thermal cost |
| `monitoring_controls` | `6. System Capex!B18` | double |  | Pull per-module monitoring cost |
| `cooling_method_premium` | `6. System Capex!B19` | double |  | Pull cooling technology premium |
| `heat_pump_if_enabled` | `6. System Capex!B20` | double | if enabled | Pull per-module HP cost |
| `total_per_module` | `6. System Capex!B21` | double |  | Sum per-module costs for scaling |
| `total_module_capex` | `6. System Capex!B24` | double |  | Calculate all modules cost |
| `shared_infrastructure_pct` | `6. System Capex!B25` | double | % | Add common infrastructure cost |
| `shared_infrastructure_gbp` | `6. System Capex!B26` | double | £ | Add common infrastructure cost |
| `integration_commissioning` | `6. System Capex!B27` | double |  | Add system integration cost |
| `rejection_capacity_required_kwth` | `6. System Capex!B30` | double | kWth | Add heat rejection equipment cost |
| `rejection_capex_rate_gbp_per_kwth` | `6. System Capex!B31` | double | £/kWth | Add heat rejection equipment cost |
| `heat_rejection_capex` | `6. System Capex!B32` | double |  | Add heat rejection equipment cost |
| `flow_deficit_m3_per_hr` | `6. System Capex!B35` | double | m³/hr | Fluid flow parameter for hydraulic design |
| `augmentation_pumps_required` | `6. System Capex!B36` | double |  | Add flow augmentation cost |
| `augmentation_pump_capex` | `6. System Capex!B37` | double |  | Add flow augmentation cost |
| `mixing_valve_controls` | `6. System Capex!B38` | double |  | Model parameter |
| `pipe_upsizing_allowance` | `6. System Capex!B39` | double |  | Model parameter |
| `subtotal_hydraulic_augmentation` | `6. System Capex!B40` | double |  | Subtotal flow augmentation costs |
| `base_system_capex_excl_rejection` | `6. System Capex!B43` | double | excl. rejection | Add heat rejection equipment cost |
| `heat_rejection_capex__b44` | `6. System Capex!B44` | double |  | Add heat rejection equipment cost |
| `hydraulic_augmentation_capex` | `6. System Capex!B45` | double |  | Add flow augmentation cost |
| `total_system_capex` | `6. System Capex!B46` | double |  | Sum complete investment requirement |
| `capex_per_it_kw_gbp_per_kw` | `6. System Capex!B48` | double | £/kW | Calculate unit cost metric |
| `capex_per_kwth_delivered_gbp_per_kwth` | `6. System Capex!B49` | double | £/kWth | Calculate unit cost metric |

### 7. System Opex → `sopex`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset` | `7. System Opex!B5` | string |  | Model parameter |
| `cooling_method` | `7. System Opex!B6` | string |  | Model parameter |
| `gpus_per_module` | `7. System Opex!B7` | double |  | Model parameter |
| `selected_buyer_profile` | `7. System Opex!B10` | string |  | Model parameter |
| `modules_in_system` | `7. System Opex!B11` | double |  | Pull module count |
| `electricity_infra_hp` | `7. System Opex!B14` | double | infra + HP | Pull per-module electricity cost |
| `maintenance_insurance` | `7. System Opex!B15` | double |  | Pull per-module maintenance cost |
| `other_site_noc_admin` | `7. System Opex!B16` | double | site, NOC, admin | Pull per-module overhead cost |
| `total_per_module` | `7. System Opex!B17` | double |  | Sum per-module opex for scaling |
| `total_module_opex` | `7. System Opex!B20` | double |  | Calculate all modules opex |
| `shared_overhead_pct` | `7. System Opex!B21` | double | % | Add common operating costs |
| `shared_overhead_gbp_per_yr` | `7. System Opex!B22` | double | £/yr | Add common operating costs |
| `base_system_opex_excl_rejection` | `7. System Opex!B23` | double | excl. rejection | Sum base operating costs |
| `excess_heat_kwth` | `7. System Opex!B26` | double | kWth | Pull heat requiring rejection |
| `rejection_running_cost_gbp_per_kwth_per_yr` | `7. System Opex!B27` | double | £/kWth/yr | Add heat rejection operating cost |
| `heat_rejection_opex_gbp_per_yr` | `7. System Opex!B28` | double | £/yr | Add heat rejection operating cost |
| `heat_rejection_uplift_pct` | `7. System Opex!B29` | double | % | Add heat rejection operating cost |
| `augmentation_pump_capacity_m3_per_hr` | `7. System Opex!B31` | double | m³/hr | Add pump operating cost |
| `augmentation_pump_power_kw` | `7. System Opex!B32` | double | kW | Add pump operating cost |
| `annual_operating_hours` | `7. System Opex!B33` | double |  | Model parameter |
| `electricity_rate_gbp_per_kwh` | `7. System Opex!B34` | double | £/kWh | Financial input or calculation |
| `augmentation_pump_electricity_gbp_per_yr` | `7. System Opex!B35` | double | £/yr | Add pump operating cost |
| `total_system_opex` | `7. System Opex!B37` | double |  | Sum complete operating costs |

### 8. System Flow → `sflow`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `chipset` | `8. System Flow!B5` | string |  | Model parameter |
| `cooling_method` | `8. System Flow!B6` | string |  | Model parameter |
| `capture_temperature_c` | `8. System Flow!B7` | double | °C | Pull heat source temperature |
| `selected_buyer_profile` | `8. System Flow!B10` | string |  | Pull sizing from buyer analysis |
| `modules_in_system` | `8. System Flow!B11` | double |  | Pull sizing from buyer analysis |
| `required_temperature_c` | `8. System Flow!B14` | double | °C | Pull buyer temperature requirement |
| `required_thermal_load_kwth` | `8. System Flow!B15` | double | kWth | Pull buyer heat requirement |
| `required_flow_rate_m3_per_hr` | `8. System Flow!B16` | double | m³/hr | Pull buyer flow requirement |
| `annual_heat_demand_mwh` | `8. System Flow!B17` | double | MWh | Pull buyer annual energy need |
| `delivery_temperature_c` | `8. System Flow!B20` | double | °C | Pull system output temperature |
| `system_thermal_capacity_kwth` | `8. System Flow!B21` | double | kWth | Pull system heat capacity |
| `system_flow_capacity_m3_per_hr` | `8. System Flow!B22` | double | m³/hr | Pull system flow capacity |
| `annual_heat_supply_mwh` | `8. System Flow!B23` | double | MWh | Calculate annual heat available |
| `temperature_c` | `8. System Flow!B26` | double | °C | Temperature parameter for thermal design |
| `temperature_c__supplied` | `8. System Flow!C26` | double | °C | Temperature parameter for thermal design |
| `temperature_c__match` | `8. System Flow!D26` | string | °C | Temperature parameter for thermal design |
| `thermal_load_kwth` | `8. System Flow!B27` | double | kWth | Power or thermal capacity metric |
| `thermal_load_kwth__supplied` | `8. System Flow!C27` | double | kWth | Power or thermal capacity metric |
| `thermal_load_kwth__match` | `8. System Flow!D27` | string | kWth | Power or thermal capacity metric |
| `flow_rate_m3_per_hr` | `8. System Flow!B28` | double | m³/hr | Efficiency or utilisation metric |
| `flow_rate_m3_per_hr__supplied` | `8. System Flow!C28` | double | m³/hr | Efficiency or utilisation metric |
| `flow_rate_m3_per_hr__match` | `8. System Flow!D28` | string | m³/hr | Efficiency or utilisation metric |
| `annual_energy_mwh` | `8. System Flow!B29` | double | MWh | Model parameter |
| `annual_energy_mwh__supplied` | `8. System Flow!C29` | double | MWh | Model parameter |
| `annual_energy_mwh__match` | `8. System Flow!D29` | string | MWh | Model parameter |
| `thermal_utilisation` | `8. System Flow!B32` | double |  | Show capacity usage metrics |
| `flow_utilisation` | `8. System Flow!B33` | double |  | Show capacity usage metrics |
| `binding_constraint` | `8. System Flow!B34` | string |  | Identify limiting factor |
| `spare_capacity_kwth` | `8. System Flow!B36` | double | kWth | Show available headroom |
| `spare_capacity_m3_per_hr` | `8. System Flow!B37` | double | m³/hr | Show available headroom |
| `design_velocity_m_per_s` | `8. System Flow!B40` | double | m/s | Model parameter |
| `main_header_pipe_id_mm` | `8. System Flow!B41` | double | mm | Size main distribution piping |
| `nearest_dn_size` | `8. System Flow!B42` | string |  | Select standard pipe size |

### 9. System P&L → `spl`

| Field | Excel cell | Type | Units | Intent |
|---|---|---|---|---|
| `selected_buyer_profile` | `9. System P&L!B6` | string |  | Pull selected buyer scenario |
| `modules_in_system` | `9. System P&L!B7` | double |  | Pull system size |
| `chipset` | `9. System P&L!B8` | string |  | Pull configuration for context |
| `cooling_method` | `9. System P&L!B9` | string |  | Pull configuration for context |
| `module_it_capacity_kw` | `9. System P&L!B12` | double | kW | Pull module size for revenue calc |
| `rack_rate_gbp_per_kw_per_month` | `9. System P&L!B13` | double | £/kW/month | Pull compute pricing assumption |
| `operating_hours_per_year` | `9. System P&L!B14` | double |  | Pull utilisation for revenue calc |
| `utilisation_assumption_pct` | `9. System P&L!B15` | double | % | Pull capacity utilisation rate |
| `compute_revenue_per_module_gbp_per_yr` | `9. System P&L!B16` | double | £/yr | Calculate single module compute income |
| `total_compute_revenue_gbp_per_yr` | `9. System P&L!B17` | double | £/yr | Calculate all modules compute income |
| `heat_price_gbp_per_mwh` | `9. System P&L!B20` | double | £/MWh | Pull heat sales pricing |
| `buyer_operating_hours_per_year` | `9. System P&L!B21` | double |  | Pull utilisation for revenue calc |
| `theoretical_heat_output_kwth` | `9. System P&L!B23` | double | kWth | Calculate max heat sales potential |
| `theoretical_heat_revenue_gbp_per_yr` | `9. System P&L!B24` | double | £/yr | Calculate max heat income potential |
| `actual_buyer_absorption_kwth` | `9. System P&L!B26` | double | kWth | Pull actual heat buyer takes |
| `actual_heat_revenue_gbp_per_yr` | `9. System P&L!B27` | double | £/yr | Calculate realised heat income |
| `heat_utilisation_pct` | `9. System P&L!B29` | double | % | Measure heat sales efficiency |
| `lost_heat_revenue_gbp_per_yr` | `9. System P&L!B30` | double | £/yr | Quantify revenue lost to rejection |
| `compute_revenue_gbp_per_yr` | `9. System P&L!B33` | double | £/yr | Financial input or calculation |
| `heat_revenue_gbp_per_yr` | `9. System P&L!B34` | double | £/yr | Financial input or calculation |
| `total_revenue_gbp_per_yr` | `9. System P&L!B35` | double | £/yr | Sum all revenue streams |
| `heat_as_pct_of_total_revenue` | `9. System P&L!B36` | double | fraction (0–1) | Sum all revenue streams |
| `base_system_opex_gbp_per_yr` | `9. System P&L!B39` | double | £/yr | Pull core operating costs |
| `heat_rejection_opex_gbp_per_yr` | `9. System P&L!B40` | double | £/yr | Pull rejection operating costs |
| `hydraulic_augmentation_opex_gbp_per_yr` | `9. System P&L!B41` | double | £/yr | Pull pump operating costs |
| `total_opex_gbp_per_yr` | `9. System P&L!B42` | double | £/yr | Sum all operating costs |
| `gross_profit_gbp_per_yr` | `9. System P&L!B45` | double | £/yr | Calculate operating profit |
| `gross_margin_pct` | `9. System P&L!B46` | double | % | Calculate profit percentage |
| `total_system_capex_gbp` | `9. System P&L!B48` | double | £ | Pull investment requirement |
| `simple_payback_years` | `9. System P&L!B49` | double | years | Calculate investment recovery time |
| `unlevered_roi_pct` | `9. System P&L!B50` | double | % | Calculate return on investment |
| `heat_utilisation_efficiency_pct` | `9. System P&L!B53` | double | % | Measure heat sales efficiency |
| `revenue_lost_to_heat_rejection_gbp_per_yr` | `9. System P&L!B54` | double | £/yr | Quantify rejection revenue impact |
| `cost_of_heat_rejection_gbp_per_yr` | `9. System P&L!B55` | double | £/yr | Quantify rejection cost impact |
| `total_heat_inefficiency_cost_gbp_per_yr` | `9. System P&L!B56` | double | £/yr | Sum heat-related losses |
| `heat_inefficiency_as_pct_of_potential_profit` | `9. System P&L!B57` | double | fraction (0–1) | Show heat loss as share of potential |

