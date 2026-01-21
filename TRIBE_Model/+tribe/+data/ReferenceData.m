function ref = ReferenceData()
%REFERENCEDATA Return static reference tables for the TRIBE model.
% Units are noted in comments for numeric fields.

ref = struct();
ge = string(char(8805)); % >= symbol for capacity ranges

% Heat rejection infrastructure.
ref.heat_rejection_infrastructure = struct( ...
    'method', ["Dry cooler"; "Adiabatic cooler"; "Cooling tower"], ...
    'capacity_range', ["<100 kWth"; "100-499 kWth"; ge + "500 kWth"], ...
    'capex_gbp_per_kwth', [150; 220; 180], ... % GBP/kWth
    'opex_gbp_per_kwth_per_yr', [70; 110; 95], ... % GBP/kWth/yr
    'notes', ["Air-cooled, no water consumption. Limited by ambient temp on hot days."; ...
              "Spray-assisted cooling. Higher capex, water consumption adds to opex."; ...
              "Evaporative cooling. Most efficient at scale, requires water treatment."] ...
);
ref.dry_cooler_max_kwth = 100; % kWth
ref.adiabatic_cooler_max_kwth = 500; % kWth
ref.dry_cooler__capex_gbp_per_kwth = 150; % GBP/kWth
ref.adiabatic_cooler__capex_gbp_per_kwth = 220; % GBP/kWth
ref.cooling_tower__capex_gbp_per_kwth = 180; % GBP/kWth
ref.dry_cooler__opex_gbp_per_kwth_per_yr = 70; % GBP/kWth/yr
ref.adiabatic_cooler__opex_gbp_per_kwth_per_yr = 110; % GBP/kWth/yr
ref.cooling_tower__opex_gbp_per_kwth_per_yr = 95; % GBP/kWth/yr

% Cooling method characteristics.
ref.cooling_methods = struct( ...
    'name', ["Direct-to-Chip (DTC)"; "Single-Phase Immersion"; "Two-Phase Immersion"; ...
             "Rear Door Heat Exchanger"; "Air Cooled (Reference)"], ...
    'heat_capture_rate_pct', [0.75; 0.95; 0.98; 0.50; 0.05], ... % fraction (0-1)
    'capture_temperature_c', [57.5; 50; 55; 45; 35], ... % C
    'capex_premium_pct', [15; 25; 40; 10; 0], ... % percent points
    'source_deltat_c', [10; 6; 3; 12; 15] ... % C
);
ref.direct_to_chip_dtc__source_deltat_c = 10; % C
ref.single_phase_immersion__source_deltat_c = 6; % C
ref.two_phase_immersion__source_deltat_c = 3; % C
ref.rear_door_heat_exchanger__source_deltat_c = 12; % C
ref.air_cooled_reference__source_deltat_c = 15; % C

% Chipset specifications.
ref.chipsets = struct( ...
    'name', ["NVIDIA H100"; "NVIDIA H200"; "NVIDIA B200"; "AMD MI300X"; "Intel Gaudi 3"], ...
    'tdp_per_chip_w', [700; 700; 1000; 750; 600], ... % W
    'chips_per_server', [8; 8; 8; 8; 8], ... % count
    't_junction_c', [83; 83; 85; 90; 95], ... % C
    'notes', ["Current gen. DTC reference design available."; ...
              "H100 + HBM3e memory upgrade. Same thermal."; ...
              "Blackwell. Higher TDP, higher capture temps expected."; ...
              "Instinct series. Competitive with H100."; ...
              "AI accelerator. Lower TDP."] ...
);

% Heat pump efficiency parameters.
ref.carnot_efficiency_factor = 0.45; % fraction
ref.minimum_practical_cop = 2; % COP
ref.maximum_practical_cop = 8; % COP
ref.target_delivery_temp_c = 75; % C

ref.hp_reference_source_temp_c = [57.5; 50; 55; 45]; % C
ref.hp_reference_temperature_lift_c = ref.target_delivery_temp_c - ref.hp_reference_source_temp_c; % C
ref.hp_reference_cop = round(ref.carnot_efficiency_factor * (ref.target_delivery_temp_c + 273.15) ...
    ./ ref.hp_reference_temperature_lift_c, 1);
ref.hp_reference_kwe_per_kwth = round(1 ./ ref.hp_reference_cop, 3); % kWe per kWth

% Module hardware capex rates (GBP unless noted).
ref.container_shell_40ft = 35000; % GBP
ref.container_fit_out_electrical_hvac_prep = 25000; % GBP
ref.rack_enclosure_42u_enclosed = 2000; % GBP per rack
ref.cold_plate_kit_per_server = 250; % GBP per server
ref.cdu_coolant_distribution_unit = 35000; % GBP
ref.cdu_capacity_scaling = 80; % GBP per kW IT
ref.manifolds_quick_connects = 150; % GBP per server
ref.primary_loop_piping = 5000; % GBP
ref.single_phase_immersion_tank = 28000; % GBP per rack
ref.two_phase_immersion_tank = 45000; % GBP per rack
ref.dielectric_fluid_single_phase = 12; % GBP per L
ref.dielectric_fluid_two_phase = 120; % GBP per L
ref.fluid_volume_per_rack_single_phase = 600; % L per rack
ref.fluid_volume_per_rack_two_phase = 400; % L per rack
ref.fluid_management_system = 15000; % GBP
ref.high_density_pdu_per_rack = 3000; % GBP per rack
ref.module_power_distribution = 180; % GBP per kW IT
ref.electrical_panels_switchgear = 20000; % GBP
ref.primary_heat_exchanger = 12000; % GBP
ref.heat_exchanger_scaling = 25; % GBP per kWth
ref.thermal_integration_skid_pumps_valves = 18000; % GBP
ref.instrumentation_sensors = 8000; % GBP
ref.bms_base_system = 18000; % GBP
ref.per_rack_monitoring = 500; % GBP per rack
ref.network_infrastructure = 8000; % GBP

% Hydraulic augmentation rates.
ref.augmentation_pump_capex_gbp_per_m3_per_hr = 150; % GBP per m3/hr
ref.augmentation_pump_power_kw_per_m3_per_hr = 0.1; % kW per m3/hr
ref.mixing_valve_controls_gbp = 2500; % GBP
ref.pipe_upsizing_allowance_gbp_per_m3_per_hr = 50; % GBP per m3/hr
ref.standard_augmentation_pump_capacity_m3_per_hr = 25; % m3/hr
end
