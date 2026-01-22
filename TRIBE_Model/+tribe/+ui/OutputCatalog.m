classdef OutputCatalog
    %OUTPUTCATALOG Provides human-readable metadata for model output fields.
    % Maps output fields to units, labels, descriptions, and format specs.

    methods (Static)
        function kpis = getKPIFields()
            %GETKPIFIELDS Get key performance indicators for dashboard tiles.
            kpis = [
                tribe.ui.OutputCatalog.makeKPI('spl', 'simple_payback_years', ...
                    'Simple Payback', 'years', '%.1f', 'Time to recover investment')
                tribe.ui.OutputCatalog.makeKPI('spl', 'unlevered_roi_pct', ...
                    'Unlevered ROI', '%', '%.1f', 'Annual return on investment')
                tribe.ui.OutputCatalog.makeKPI('spl', 'gross_margin_pct', ...
                    'Gross Margin', '%', '%.1f', 'Operating profit margin')
                tribe.ui.OutputCatalog.makeKPI('spl', 'total_system_capex_gbp', ...
                    'Total Capex', 'GBP', '%.0f', 'Total capital requirement')
                tribe.ui.OutputCatalog.makeKPI('spl', 'gross_profit_gbp_per_yr', ...
                    'Gross Profit', 'GBP/yr', '%.0f', 'Annual operating profit')
                tribe.ui.OutputCatalog.makeKPI('bp', 'modules_required', ...
                    'Modules', '', '%.0f', 'Number of modules in system')
            ];
        end

        function str = formatValue(section, field, value)
            %FORMATVALUE Format a value with appropriate units and formatting.
            meta = tribe.ui.OutputCatalog.getFieldMeta(section, field);

            if isempty(value)
                str = '-';
                return;
            end

            if isstring(value)
                if numel(value) == 1
                    value = char(value);
                else
                    value = char(strjoin(value, ", "));
                end
            end

            if ischar(value)
                if isempty(meta)
                    str = value;
                    return;
                end

                try
                    str = sprintf(meta.format_spec, value);
                catch
                    str = value;
                end

                if ~isempty(meta.units)
                    str = [str ' ' meta.units];
                end
                return;
            end

            if ~isnumeric(value) || ~isscalar(value)
                str = '-';
                return;
            end

            if isnan(value) || isinf(value)
                str = '-';
                return;
            end

            if isempty(meta)
                % Default formatting
                if abs(value) >= 1e6
                    str = sprintf('%.2fM', value / 1e6);
                elseif abs(value) >= 1e3
                    str = sprintf('%.1fk', value / 1e3);
                else
                    str = sprintf('%.2f', value);
                end
                return;
            end

            % Apply format spec
            numStr = sprintf(meta.format_spec, value);

            % Add units
            switch meta.units
                case 'GBP'
                    str = ['GBP ' tribe.ui.OutputCatalog.addCommas(numStr)];
                case 'GBP/yr'
                    str = ['GBP ' tribe.ui.OutputCatalog.addCommas(numStr) '/yr'];
                case '%'
                    % Convert from fraction to percentage if needed
                    if value <= 1 && value >= 0
                        str = sprintf('%.1f%%', value * 100);
                    else
                        str = [numStr '%'];
                    end
                case 'years'
                    str = [numStr ' years'];
                case 'kW'
                    str = [numStr ' kW'];
                case 'kWth'
                    str = [numStr ' kWth'];
                case 'm3/hr'
                    str = [numStr ' m' char(179) '/hr'];
                case 'C'
                    str = [numStr char(176) 'C'];
                case ''
                    str = numStr;
                otherwise
                    str = [numStr ' ' meta.units];
            end
        end

        function meta = getFieldMeta(section, field)
            %GETFIELDMETA Get metadata for an output field.
            % Returns struct with: label, units, description, format_spec, category

            catalog = tribe.ui.OutputCatalog.getCatalog();

            key = [section '.' field];
            if isfield(catalog, strrep(key, '.', '_'))
                meta = catalog.(strrep(key, '.', '_'));
            else
                meta = [];
            end
        end

        function fields = getFieldsForSection(section)
            %GETFIELDSFORSECTION Get all documented fields for a section.
            catalog = tribe.ui.OutputCatalog.getCatalog();
            fields = struct('field', {}, 'label', {}, 'units', {}, 'description', {});

            names = fieldnames(catalog);
            prefix = [section '_'];

            for i = 1:numel(names)
                if startsWith(names{i}, prefix)
                    meta = catalog.(names{i});
                    fields(end+1).field = meta.field; %#ok<AGROW>
                    fields(end).label = meta.label;
                    fields(end).units = meta.units;
                    fields(end).description = meta.description;
                end
            end
        end

        function sections = getOutputSections()
            %GETOUTPUTSECTIONS Get list of output sections.
            sections = struct( ...
                'spl', 'System P&L', ...
                'sflow', 'System Flow', ...
                'bp', 'Buyer Profile', ...
                'scapex', 'System Capex', ...
                'sopex', 'System Opex', ...
                'mc', 'Module Criteria', ...
                'mcapex', 'Module Capex', ...
                'mopex', 'Module Opex', ...
                'mflow', 'Module Flow', ...
                'rp', 'Rack Profile');
        end

        function cat = getCategory(section, field)
            %GETCATEGORY Get category for a field (thermal, financial, sizing).
            meta = tribe.ui.OutputCatalog.getFieldMeta(section, field);
            if isempty(meta)
                cat = 'other';
            else
                cat = meta.category;
            end
        end
    end

    methods (Static, Access = private)
        function catalog = getCatalog()
            %GETCATALOG Get the full field metadata catalog.
            persistent cached
            if ~isempty(cached)
                catalog = cached;
                return;
            end

            catalog = struct();

            % System P&L fields
            catalog.spl_simple_payback_years = tribe.ui.OutputCatalog.makeMeta(...
                'simple_payback_years', 'Simple Payback', 'years', '%.1f', ...
                'Time to recover capital investment', 'financial');
            catalog.spl_unlevered_roi_pct = tribe.ui.OutputCatalog.makeMeta(...
                'unlevered_roi_pct', 'Unlevered ROI', '%', '%.1f', ...
                'Annual return on investment (unlevered)', 'financial');
            catalog.spl_gross_margin_pct = tribe.ui.OutputCatalog.makeMeta(...
                'gross_margin_pct', 'Gross Margin', '%', '%.1f', ...
                'Operating profit as percentage of revenue', 'financial');
            catalog.spl_total_system_capex_gbp = tribe.ui.OutputCatalog.makeMeta(...
                'total_system_capex_gbp', 'Total System Capex', 'GBP', '%.0f', ...
                'Total capital expenditure', 'financial');
            catalog.spl_gross_profit_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'gross_profit_gbp_per_yr', 'Gross Profit', 'GBP/yr', '%.0f', ...
                'Annual operating profit', 'financial');
            catalog.spl_total_revenue_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'total_revenue_gbp_per_yr', 'Total Revenue', 'GBP/yr', '%.0f', ...
                'Annual revenue from compute and heat', 'financial');
            catalog.spl_compute_revenue_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'compute_revenue_gbp_per_yr', 'Compute Revenue', 'GBP/yr', '%.0f', ...
                'Annual revenue from compute services', 'financial');
            catalog.spl_heat_revenue_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'heat_revenue_gbp_per_yr', 'Heat Revenue', 'GBP/yr', '%.0f', ...
                'Annual revenue from heat sales', 'financial');
            catalog.spl_total_opex_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'total_opex_gbp_per_yr', 'Total Opex', 'GBP/yr', '%.0f', ...
                'Annual operating expenditure', 'financial');
            catalog.spl_heat_as_pct_of_total_revenue = tribe.ui.OutputCatalog.makeMeta(...
                'heat_as_pct_of_total_revenue', 'Heat Revenue %', '%', '%.1f', ...
                'Heat revenue as percentage of total', 'financial');
            catalog.spl_heat_utilisation_pct = tribe.ui.OutputCatalog.makeMeta(...
                'heat_utilisation_pct', 'Heat Utilisation', '%', '%.1f', ...
                'Percentage of generated heat absorbed by buyer', 'thermal');

            % System Flow fields
            catalog.sflow_thermal_utilisation = tribe.ui.OutputCatalog.makeMeta(...
                'thermal_utilisation', 'Thermal Utilisation', '%', '%.1f', ...
                'Percentage of thermal capacity used', 'thermal');
            catalog.sflow_flow_utilisation = tribe.ui.OutputCatalog.makeMeta(...
                'flow_utilisation', 'Flow Utilisation', '%', '%.1f', ...
                'Percentage of flow capacity used', 'thermal');
            catalog.sflow_binding_constraint = tribe.ui.OutputCatalog.makeMeta(...
                'binding_constraint', 'Binding Constraint', '', '%s', ...
                'Which constraint limits the system', 'sizing');
            catalog.sflow_required_thermal_load_kwth = tribe.ui.OutputCatalog.makeMeta(...
                'required_thermal_load_kwth', 'Required Thermal Load', 'kWth', '%.0f', ...
                'Buyer required thermal power', 'thermal');
            catalog.sflow_system_thermal_capacity_kwth = tribe.ui.OutputCatalog.makeMeta(...
                'system_thermal_capacity_kwth', 'System Thermal Capacity', 'kWth', '%.0f', ...
                'System thermal output capacity', 'thermal');
            catalog.sflow_required_flow_rate_m3_per_hr = tribe.ui.OutputCatalog.makeMeta(...
                'required_flow_rate_m3_per_hr', 'Required Flow Rate', 'm3/hr', '%.1f', ...
                'Buyer required volume flow', 'thermal');
            catalog.sflow_system_flow_capacity_m3_per_hr = tribe.ui.OutputCatalog.makeMeta(...
                'system_flow_capacity_m3_per_hr', 'System Flow Capacity', 'm3/hr', '%.1f', ...
                'System volume flow capacity', 'thermal');
            catalog.sflow_delivery_temperature_c = tribe.ui.OutputCatalog.makeMeta(...
                'delivery_temperature_c', 'Delivery Temperature', 'C', '%.0f', ...
                'Heat delivery temperature', 'thermal');

            % Buyer Profile fields
            catalog.bp_modules_required = tribe.ui.OutputCatalog.makeMeta(...
                'modules_required', 'Modules Required', '', '%.0f', ...
                'Number of modules needed', 'sizing');
            catalog.bp_heat_demand_kwth = tribe.ui.OutputCatalog.makeMeta(...
                'heat_demand_kwth', 'Heat Demand', 'kWth', '%.0f', ...
                'Buyer heat demand', 'thermal');
            catalog.bp_required_temperature_c = tribe.ui.OutputCatalog.makeMeta(...
                'required_temperature_c', 'Required Temperature', 'C', '%.0f', ...
                'Buyer required temperature', 'thermal');
            catalog.bp_thermal_utilisation_pct = tribe.ui.OutputCatalog.makeMeta(...
                'thermal_utilisation_pct', 'Thermal Utilisation', '%', '%.1f', ...
                'Thermal capacity utilisation', 'thermal');

            % System Capex fields
            catalog.scapex_total_module_capex = tribe.ui.OutputCatalog.makeMeta(...
                'total_module_capex', 'Total Module Capex', 'GBP', '%.0f', ...
                'Total capital for all modules', 'financial');
            catalog.scapex_shared_infrastructure_gbp = tribe.ui.OutputCatalog.makeMeta(...
                'shared_infrastructure_gbp', 'Shared Infrastructure', 'GBP', '%.0f', ...
                'Shared infrastructure capital', 'financial');
            catalog.scapex_integration_commissioning = tribe.ui.OutputCatalog.makeMeta(...
                'integration_commissioning', 'Integration & Commissioning', 'GBP', '%.0f', ...
                'Integration and commissioning costs', 'financial');

            % System Opex fields
            catalog.sopex_total_module_opex = tribe.ui.OutputCatalog.makeMeta(...
                'total_module_opex', 'Total Module Opex', 'GBP/yr', '%.0f', ...
                'Annual opex for all modules', 'financial');
            catalog.sopex_heat_rejection_opex_gbp_per_yr = tribe.ui.OutputCatalog.makeMeta(...
                'heat_rejection_opex_gbp_per_yr', 'Heat Rejection Opex', 'GBP/yr', '%.0f', ...
                'Annual heat rejection operating cost', 'financial');

            cached = catalog;
        end

        function kpi = makeKPI(section, field, label, units, format_spec, description)
            %MAKEKPI Create a KPI struct entry.
            kpi = struct( ...
                'section', section, ...
                'field', field, ...
                'label', label, ...
                'units', units, ...
                'format_spec', format_spec, ...
                'description', description);
        end

        function meta = makeMeta(field, label, units, format_spec, description, category)
            %MAKEMETA Create a metadata struct entry.
            meta = struct( ...
                'field', field, ...
                'label', label, ...
                'units', units, ...
                'format_spec', format_spec, ...
                'description', description, ...
                'category', category);
        end

        function str = addCommas(numStr)
            %ADDCOMMAS Add comma separators to a number string.
            % Find the decimal point
            dotIdx = strfind(numStr, '.');
            if isempty(dotIdx)
                intPart = numStr;
                decPart = '';
            else
                intPart = numStr(1:dotIdx-1);
                decPart = numStr(dotIdx:end);
            end

            % Handle negative sign
            if startsWith(intPart, '-')
                sign = '-';
                intPart = intPart(2:end);
            else
                sign = '';
            end

            % Add commas every 3 digits from right
            n = length(intPart);
            if n <= 3
                str = [sign intPart decPart];
                return;
            end

            result = '';
            count = 0;
            for i = n:-1:1
                count = count + 1;
                result = [intPart(i) result]; %#ok<AGROW>
                if count == 3 && i > 1
                    result = [',' result]; %#ok<AGROW>
                    count = 0;
                end
            end

            str = [sign result decPart];
        end
    end
end
