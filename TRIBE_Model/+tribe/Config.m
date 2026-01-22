classdef Config
    %CONFIG Provide default configuration and helpers for the TRIBE model.

    methods (Static)
        function cfg = default()
            cfg = struct();

            cfg.rack_profile = struct( ...
                'chipset', "NVIDIA H100", ...
                'cooling_method', "Direct-to-Chip (DTC)", ...
                'module_it_capacity_target_kw', 250, ...
                'electricity_price_gbp_per_kwh', 0.18, ...
                'annual_operating_hours', 8000 ...
                );

            cfg.module_criteria = struct( ...
                'compute_rate_gbp_per_kw_per_month', 150, ...
                'target_utilisation_rate_pct', 0.9, ...
                'heat_pump_enabled', 1, ...
                'heat_pump_output_temperature_c', 90, ...
                'hours_per_year', 8760, ...
                'base_heat_price_no_hp_gbp_per_mwh', 25, ...
                'premium_heat_price_with_hp_gbp_per_mwh', 40, ...
                'reference_industrial_gas_price_gbp_per_mwh', 53 ...
                );

            cfg.module_opex = struct( ...
                'electricity_rate_gbp_per_kwh', 0.18, ...
                'base_maintenance_pct_of_base_capex', 0.03, ...
                'heat_pump_maintenance_pct_of_hp_capex', 0.02, ...
                'insurance_pct_of_total_capex', 0.01, ...
                'site_lease_per_licence_gbp_per_yr', 15000, ...
                'remote_monitoring_noc_gbp_per_yr', 12000, ...
                'connectivity_admin_gbp_per_yr', 8000 ...
                );

            cfg.buyer_profile = struct( ...
                'process_id', "Pasteurisation - Medium", ...
                'module_footprint_each_m', 15, ...
                'bms_per_controls_package', 1 ...
                );

            cfg.system = struct( ...
                'shared_infrastructure_pct', 0.05, ...
                'shared_overhead_pct', 0.05, ...
                'design_velocity_m_per_s', 2 ...
                );

            cfg = tribe.Config.normalize(cfg);
        end

        function cfg = apply(overrides)
            cfg = tribe.Config.default();
            if nargin < 1 || isempty(overrides)
                return;
            end
            if ~isstruct(overrides)
                error('Config:InvalidOverride', 'Overrides must be provided as a struct.');
            end
            cfg = tribe.Config.mergeStructs(cfg, overrides);
            cfg = tribe.Config.normalize(cfg);
        end

        function cfg = forProcess(process_id)
            cfg = tribe.Config.default();
            cfg.buyer_profile.process_id = string(process_id);
        end

        function cfg = forChipset(chipset)
            cfg = tribe.Config.default();
            cfg.rack_profile.chipset = string(chipset);
        end

        function cfg = forCoolingMethod(cooling_method)
            cfg = tribe.Config.default();
            cfg.rack_profile.cooling_method = string(cooling_method);
        end

        function cfg = withHeatPump(enabled, output_temp_c)
            cfg = tribe.Config.default();
            cfg.module_criteria.heat_pump_enabled = double(enabled);
            if nargin > 1 && ~isempty(output_temp_c)
                cfg.module_criteria.heat_pump_output_temperature_c = output_temp_c;
            end
        end

        function validate(cfg)
            tribe.Config.requireStruct(cfg, 'rack_profile');
            tribe.Config.requireStruct(cfg, 'module_criteria');
            tribe.Config.requireStruct(cfg, 'module_opex');
            tribe.Config.requireStruct(cfg, 'buyer_profile');
            tribe.Config.requireStruct(cfg, 'system');

            rp = cfg.rack_profile;
            mc = cfg.module_criteria;
            mo = cfg.module_opex;
            bp = cfg.buyer_profile;
            sys = cfg.system;

            tribe.Config.requireString(rp, 'chipset');
            tribe.Config.requireString(rp, 'cooling_method');
            tribe.Config.requirePositive(rp, 'module_it_capacity_target_kw');
            tribe.Config.requireNonNegative(rp, 'electricity_price_gbp_per_kwh');
            tribe.Config.requirePositive(rp, 'annual_operating_hours');

            tribe.Config.requireNonNegative(mc, 'compute_rate_gbp_per_kw_per_month');
            tribe.Config.requireFraction(mc, 'target_utilisation_rate_pct');
            tribe.Config.requireBinary(mc, 'heat_pump_enabled');
            tribe.Config.requirePositive(mc, 'heat_pump_output_temperature_c');
            tribe.Config.requirePositive(mc, 'hours_per_year');
            tribe.Config.requireNonNegative(mc, 'base_heat_price_no_hp_gbp_per_mwh');
            tribe.Config.requireNonNegative(mc, 'premium_heat_price_with_hp_gbp_per_mwh');
            tribe.Config.requireNonNegative(mc, 'reference_industrial_gas_price_gbp_per_mwh');

            tribe.Config.requireNonNegative(mo, 'electricity_rate_gbp_per_kwh');
            tribe.Config.requireFraction(mo, 'base_maintenance_pct_of_base_capex');
            tribe.Config.requireFraction(mo, 'heat_pump_maintenance_pct_of_hp_capex');
            tribe.Config.requireFraction(mo, 'insurance_pct_of_total_capex');
            tribe.Config.requireNonNegative(mo, 'site_lease_per_licence_gbp_per_yr');
            tribe.Config.requireNonNegative(mo, 'remote_monitoring_noc_gbp_per_yr');
            tribe.Config.requireNonNegative(mo, 'connectivity_admin_gbp_per_yr');

            tribe.Config.requireString(bp, 'process_id');
            tribe.Config.requirePositive(bp, 'module_footprint_each_m');
            tribe.Config.requireNonNegative(bp, 'bms_per_controls_package');

            tribe.Config.requireFraction(sys, 'shared_infrastructure_pct');
            tribe.Config.requireFraction(sys, 'shared_overhead_pct');
            if isfield(sys, 'design_velocity_m_per_s') && ~isempty(sys.design_velocity_m_per_s)
                tribe.Config.requirePositive(sys, 'design_velocity_m_per_s');
            end
        end
    end

    methods (Static, Access = private)
        function cfg = normalize(cfg)
            cfg.rack_profile.chipset = string(cfg.rack_profile.chipset);
            cfg.rack_profile.cooling_method = string(cfg.rack_profile.cooling_method);
            cfg.buyer_profile.process_id = string(cfg.buyer_profile.process_id);
            cfg.module_criteria.heat_pump_enabled = double(cfg.module_criteria.heat_pump_enabled);
        end

        function out = mergeStructs(base, override)
            out = base;
            fields = fieldnames(override);
            for i = 1:numel(fields)
                field = fields{i};
                if isstruct(override.(field)) && isfield(base, field) && isstruct(base.(field))
                    out.(field) = tribe.Config.mergeStructs(base.(field), override.(field));
                else
                    out.(field) = override.(field);
                end
            end
        end

        function requireStruct(cfg, field)
            if ~isfield(cfg, field) || ~isstruct(cfg.(field))
                error('Config:MissingField', 'Missing struct config section: %s', field);
            end
        end

        function requireString(cfg, field)
            if ~isfield(cfg, field)
                error('Config:MissingField', 'Missing config field: %s', field);
            end
            value = cfg.(field);
            if ~(isstring(value) || ischar(value)) || strlength(string(value)) == 0
                error('Config:InvalidField', 'Config field %s must be a non-empty string.', field);
            end
        end

        function requirePositive(cfg, field)
            tribe.Config.requireNumeric(cfg, field, 0, true);
        end

        function requireNonNegative(cfg, field)
            tribe.Config.requireNumeric(cfg, field, 0, false);
        end

        function requireFraction(cfg, field)
            tribe.Config.requireNumeric(cfg, field, 0, false);
            value = cfg.(field);
            if value > 1
                error('Config:InvalidField', 'Config field %s must be between 0 and 1.', field);
            end
        end

        function requireBinary(cfg, field)
            if ~isfield(cfg, field)
                error('Config:MissingField', 'Missing config field: %s', field);
            end
            value = cfg.(field);
            if ~(isnumeric(value) && isscalar(value) && (value == 0 || value == 1))
                error('Config:InvalidField', 'Config field %s must be 0 or 1.', field);
            end
        end

        function requireNumeric(cfg, field, minValue, strict)
            if ~isfield(cfg, field)
                error('Config:MissingField', 'Missing config field: %s', field);
            end
            value = cfg.(field);
            if ~(isnumeric(value) && isscalar(value) && isfinite(value))
                error('Config:InvalidField', 'Config field %s must be a finite scalar.', field);
            end
            if strict
                ok = value > minValue;
            else
                ok = value >= minValue;
            end
            if ~ok
                error('Config:InvalidField', 'Config field %s must be >= %g.', field, minValue);
            end
        end
    end
end
