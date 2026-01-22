classdef Model
    %MODEL Entry point to run the full TRIBE model chain.

    properties (SetAccess = private)
        config
    end

    methods
        function obj = Model(config)
            if nargin < 1
                config = [];
            end
            obj.config = tribe.Config.apply(config);
            tribe.Config.validate(obj.config);
        end

        function results = run(obj)
            results = tribe.Model.runWithConfig(obj.config);
        end
    end

    methods (Static)
        function results = runWithConfig(config)
            if nargin < 1
                config = [];
            end

            cfg = tribe.Config.apply(config);
            tribe.Config.validate(cfg);

            ref = tribe.data.ReferenceData();

            rp = tribe.calc.calcRackProfile( ...
                cfg.rack_profile.chipset, ...
                cfg.rack_profile.cooling_method, ...
                cfg.rack_profile.module_it_capacity_target_kw, ...
                cfg.rack_profile.electricity_price_gbp_per_kwh, ...
                cfg.rack_profile.annual_operating_hours ...
                );

            mc = tribe.calc.calcModuleCriteria( ...
                rp, ...
                cfg.module_criteria.heat_pump_enabled, ...
                cfg.module_criteria.heat_pump_output_temperature_c, ...
                cfg.module_criteria.target_utilisation_rate_pct, ...
                cfg.module_criteria.hours_per_year, ...
                cfg.module_criteria.base_heat_price_no_hp_gbp_per_mwh, ...
                cfg.module_criteria.premium_heat_price_with_hp_gbp_per_mwh ...
                );
            mc = tribe.Model.applyModuleCriteriaOverrides(mc, cfg.module_criteria);

            mcapex = tribe.calc.calcModuleCapex(rp, mc, ref);
            mopex = tribe.calc.calcModuleOpex(rp, mc, mcapex, cfg.module_opex.electricity_rate_gbp_per_kwh);
            mopex = tribe.Model.applyModuleOpexOverrides(mopex, rp, mc, mcapex, cfg.module_opex);

            mflow = tribe.calc.calcModuleFlow(mc, rp.cooling_method, ref);
            bp = tribe.calc.calcBuyerProfile(rp, mc, mflow, cfg.buyer_profile.process_id, ref);
            bp = tribe.Model.applyBuyerOverrides(bp, cfg.buyer_profile);

            scapex = tribe.calc.calcSystemCapex(mcapex, bp, ref);
            scapex = tribe.Model.applySystemCapexOverrides(scapex, mcapex, bp, cfg.system.shared_infrastructure_pct);

            sopex = tribe.calc.calcSystemOpex(mopex, bp, ref);
            sopex = tribe.Model.applySystemOpexOverrides(sopex, cfg.system.shared_overhead_pct);

            sflow = tribe.calc.calcSystemFlow(mc, bp);
            if isfield(cfg.system, 'design_velocity_m_per_s') && ~isempty(cfg.system.design_velocity_m_per_s)
                sflow = tribe.Model.applySystemFlowOverrides(sflow, cfg.system.design_velocity_m_per_s);
            end

            spl = tribe.calc.calcSystemPL(mc, bp, scapex, sopex);

            results = struct();
            results.config = cfg;
            results.ref = ref;
            results.rp = rp;
            results.mc = mc;
            results.mcapex = mcapex;
            results.mopex = mopex;
            results.mflow = mflow;
            results.bp = bp;
            results.scapex = scapex;
            results.sopex = sopex;
            results.sflow = sflow;
            results.spl = spl;
            results.RackProfile = rp;
            results.ModuleCriteria = mc;
            results.ModuleCapex = mcapex;
            results.ModuleOpex = mopex;
            results.ModuleFlow = mflow;
            results.BuyerProfile = bp;
            results.SystemCapex = scapex;
            results.SystemOpex = sopex;
            results.SystemFlow = sflow;
            results.SystemPL = spl;
        end
    end

    methods (Static, Access = private)
        function mc = applyModuleCriteriaOverrides(mc, cfg)
            if isfield(cfg, 'compute_rate_gbp_per_kw_per_month')
                mc.compute_rate_gbp_per_kw_per_month = cfg.compute_rate_gbp_per_kw_per_month;
            end
            if isfield(cfg, 'reference_industrial_gas_price_gbp_per_mwh')
                mc.reference_industrial_gas_price_gbp_per_mwh = cfg.reference_industrial_gas_price_gbp_per_mwh;
            end
        end

        function mopex = applyModuleOpexOverrides(mopex, rp, mc, mcapex, cfg)
            if isfield(cfg, 'electricity_rate_gbp_per_kwh')
                mopex.electricity_rate_gbp_per_kwh = cfg.electricity_rate_gbp_per_kwh;
            end

            mopex.infrastructure_power_from_pue = rp.pue_contribution - 1;
            mopex.infrastructure_power_cost_gbp_per_yr = mc.module_it_capacity_kw ...
                * mopex.infrastructure_power_from_pue * mc.hours_per_year ...
                * mopex.electricity_rate_gbp_per_kwh * mc.target_utilisation_rate_pct;

            if mc.heat_pump_enabled == 1
                mopex.heat_pump_electricity_gbp_per_yr = (mc.thermal_output_kwth / mc.heat_pump_cop) ...
                    * mc.hours_per_year * mc.target_utilisation_rate_pct * mopex.electricity_rate_gbp_per_kwh;
            else
                mopex.heat_pump_electricity_gbp_per_yr = 0;
            end

            mopex.subtotal_electricity = mopex.infrastructure_power_cost_gbp_per_yr ...
                + mopex.heat_pump_electricity_gbp_per_yr;

            if isfield(cfg, 'base_maintenance_pct_of_base_capex')
                mopex.base_maintenance_pct_of_base_capex = cfg.base_maintenance_pct_of_base_capex;
            end
            mopex.base_maintenance_gbp_per_yr = mcapex.base_infrastructure ...
                * mopex.base_maintenance_pct_of_base_capex;

            if isfield(cfg, 'heat_pump_maintenance_pct_of_hp_capex')
                mopex.heat_pump_maintenance_pct_of_hp_capex = cfg.heat_pump_maintenance_pct_of_hp_capex;
            end
            if mc.heat_pump_enabled == 1
                mopex.heat_pump_maintenance_gbp_per_yr = mcapex.heat_pump_unit ...
                    * mopex.heat_pump_maintenance_pct_of_hp_capex;
            else
                mopex.heat_pump_maintenance_gbp_per_yr = 0;
            end

            if isfield(cfg, 'insurance_pct_of_total_capex')
                mopex.insurance_pct_of_total_capex = cfg.insurance_pct_of_total_capex;
            end
            mopex.insurance_gbp_per_yr = mcapex.total_module_capex * mopex.insurance_pct_of_total_capex;

            mopex.subtotal_maintenance_insurance = mopex.base_maintenance_gbp_per_yr ...
                + mopex.heat_pump_maintenance_gbp_per_yr + mopex.insurance_gbp_per_yr;

            if isfield(cfg, 'site_lease_per_licence_gbp_per_yr')
                mopex.site_lease_per_licence_gbp_per_yr = cfg.site_lease_per_licence_gbp_per_yr;
            end
            if isfield(cfg, 'remote_monitoring_noc_gbp_per_yr')
                mopex.remote_monitoring_noc_gbp_per_yr = cfg.remote_monitoring_noc_gbp_per_yr;
            end
            if isfield(cfg, 'connectivity_admin_gbp_per_yr')
                mopex.connectivity_admin_gbp_per_yr = cfg.connectivity_admin_gbp_per_yr;
            end

            mopex.subtotal_other = sum([mopex.site_lease_per_licence_gbp_per_yr, ...
                mopex.remote_monitoring_noc_gbp_per_yr, mopex.connectivity_admin_gbp_per_yr]);

            mopex.total_module_opex_gbp_per_yr = mopex.subtotal_electricity ...
                + mopex.subtotal_maintenance_insurance + mopex.subtotal_other;
        end

        function bp = applyBuyerOverrides(bp, cfg)
            if isfield(cfg, 'module_footprint_each_m')
                bp.module_footprint_each_m = cfg.module_footprint_each_m;
            end
            bp.total_module_footprint_m = bp.modules_required * bp.module_footprint_each_m;
            bp.total_site_area_m = bp.total_module_footprint_m + bp.plant_room_allowance_m;

            if isfield(cfg, 'bms_per_controls_package')
                bp.bms_per_controls_package = cfg.bms_per_controls_package;
            end
        end

        function scapex = applySystemCapexOverrides(scapex, mcapex, bp, shared_pct)
            if isempty(shared_pct)
                return;
            end
            scapex.shared_infrastructure_pct = shared_pct;
            scapex.shared_infrastructure_gbp = scapex.total_module_capex * scapex.shared_infrastructure_pct;

            scapex.base_system_capex_excl_rejection = scapex.total_module_capex ...
                + scapex.shared_infrastructure_gbp + scapex.integration_commissioning;
            scapex.total_system_capex = scapex.base_system_capex_excl_rejection ...
                + scapex.heat_rejection_capex__b44 + scapex.hydraulic_augmentation_capex;

            scapex.capex_per_it_kw_gbp_per_kw = scapex.total_system_capex ...
                / (scapex.modules_required * mcapex.module_it_capacity_kw);
            scapex.capex_per_kwth_delivered_gbp_per_kwth = scapex.total_system_capex / bp.heat_demand_kwth;
        end

        function sopex = applySystemOpexOverrides(sopex, shared_pct)
            if isempty(shared_pct)
                return;
            end
            sopex.shared_overhead_pct = shared_pct;
            sopex.shared_overhead_gbp_per_yr = sopex.total_module_opex * sopex.shared_overhead_pct;
            sopex.base_system_opex_excl_rejection = sopex.total_module_opex + sopex.shared_overhead_gbp_per_yr;

            if sopex.base_system_opex_excl_rejection > 0
                sopex.heat_rejection_uplift_pct = sopex.heat_rejection_opex_gbp_per_yr ...
                    / sopex.base_system_opex_excl_rejection;
            else
                sopex.heat_rejection_uplift_pct = 0;
            end

            sopex.total_system_opex = sopex.base_system_opex_excl_rejection ...
                + sopex.heat_rejection_opex_gbp_per_yr + sopex.augmentation_pump_electricity_gbp_per_yr;
        end

        function sflow = applySystemFlowOverrides(sflow, design_velocity)
            sflow.design_velocity_m_per_s = design_velocity;
            sflow.main_header_pipe_id_mm = sqrt((sflow.required_flow_rate_m3_per_hr / 3600) ...
                / (sflow.design_velocity_m_per_s * 3.14159 / 4)) * 1000;
            sflow.nearest_dn_size = tribe.Model.nearestDN(sflow.main_header_pipe_id_mm);
        end

        function dn = nearestDN(pipe_id_mm)
            if pipe_id_mm < 28
                dn = "DN25";
            elseif pipe_id_mm < 36
                dn = "DN32";
            elseif pipe_id_mm < 42
                dn = "DN40";
            elseif pipe_id_mm < 54
                dn = "DN50";
            elseif pipe_id_mm < 68
                dn = "DN65";
            elseif pipe_id_mm < 82
                dn = "DN80";
            elseif pipe_id_mm < 107
                dn = "DN100";
            elseif pipe_id_mm < 131
                dn = "DN125";
            elseif pipe_id_mm < 159
                dn = "DN150";
            else
                dn = "DN200+";
            end
        end
    end
end
