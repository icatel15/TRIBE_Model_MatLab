classdef ModelRunner < handle
    %MODELRUNNER Executes model with exception handling.
    % Provides methods to run the model and export results.

    properties
        lastResults     % Most recent run results
        lastConfig      % Config used for last run
        lastError       % Last error message if run failed
        lastTimestamp   % Timestamp of last run
    end

    properties (Access = private)
        isRunning       % Flag for async operation
    end

    methods
        function obj = ModelRunner()
            %MODELRUNNER Constructor.
            obj.lastResults = [];
            obj.lastConfig = [];
            obj.lastError = '';
            obj.lastTimestamp = [];
            obj.isRunning = false;
        end

        function [results, success, errMsg] = run(obj, config)
            %RUN Execute the model with the given config.
            % [results, success, errMsg] = run(obj, config)
            % Returns results struct, success flag, and error message.

            obj.isRunning = true;
            obj.lastError = '';
            results = [];
            success = false;
            errMsg = '';

            try
                % Validate config first
                tribe.Config.validate(config);

                % Run the model
                results = tribe.Model.runWithConfig(config);

                % Store results
                obj.lastResults = results;
                obj.lastConfig = config;
                obj.lastTimestamp = datetime('now');
                success = true;

            catch ME
                obj.lastError = ME.message;
                errMsg = tribe.ui.ModelRunner.formatError(ME);
            end

            obj.isRunning = false;
        end

        function running = isModelRunning(obj)
            %ISMODELRUNNING Check if model is currently running.
            running = obj.isRunning;
        end

        function hasResults = hasValidResults(obj)
            %HASVALIDRESULTS Check if valid results are available.
            hasResults = ~isempty(obj.lastResults);
        end

        function exportResults(obj, filepath, format)
            %EXPORTRESULTS Export results to file.
            % exportResults(obj, filepath) - auto-detect format
            % exportResults(obj, filepath, 'json')
            % exportResults(obj, filepath, 'mat')
            % exportResults(obj, filepath, 'csv')

            if isempty(obj.lastResults)
                error('ModelRunner:NoResults', 'No results to export. Run the model first.');
            end

            if nargin < 3
                [~, ~, ext] = fileparts(filepath);
                format = lower(strrep(ext, '.', ''));
            end

            switch lower(format)
                case 'json'
                    obj.exportJSON(filepath);
                case 'mat'
                    obj.exportMAT(filepath);
                case 'csv'
                    obj.exportCSV(filepath);
                otherwise
                    error('ModelRunner:InvalidFormat', 'Unsupported format: %s', format);
            end
        end

        function T = getResultsTable(obj, section)
            %GETRESULTSTABLE Get results for a section as a table.
            % T = getResultsTable(obj, 'spl')

            if isempty(obj.lastResults)
                error('ModelRunner:NoResults', 'No results available.');
            end

            if ~isfield(obj.lastResults, section)
                error('ModelRunner:InvalidSection', 'Unknown section: %s', section);
            end

            data = obj.lastResults.(section);
            fields = fieldnames(data);
            rows = cell(numel(fields), 3);

            for i = 1:numel(fields)
                fname = fields{i};
                val = data.(fname);
                rows{i, 1} = fname;
                if isnumeric(val) && isscalar(val)
                    rows{i, 2} = val;
                    rows{i, 3} = 'numeric';
                elseif isstring(val) || ischar(val)
                    rows{i, 2} = string(val);
                    rows{i, 3} = 'string';
                else
                    rows{i, 2} = '-';
                    rows{i, 3} = class(val);
                end
            end

            T = cell2table(rows, 'VariableNames', {'Field', 'Value', 'Type'});
        end

        function kpis = getKPIs(obj)
            %GETKPIS Get key performance indicators from results.

            if isempty(obj.lastResults)
                error('ModelRunner:NoResults', 'No results available.');
            end

            spl = obj.lastResults.spl;
            bp = obj.lastResults.bp;

            kpis = struct();
            kpis.simple_payback_years = spl.simple_payback_years;
            kpis.unlevered_roi_pct = spl.unlevered_roi_pct;
            kpis.gross_margin_pct = spl.gross_margin_pct;
            kpis.total_system_capex_gbp = spl.total_system_capex_gbp;
            kpis.gross_profit_gbp_per_yr = spl.gross_profit_gbp_per_yr;
            kpis.modules_in_system = bp.modules_required;
            kpis.total_revenue_gbp_per_yr = spl.total_revenue_gbp_per_yr;
            kpis.heat_as_pct_of_total_revenue = spl.heat_as_pct_of_total_revenue;
            kpis.binding_constraint = obj.lastResults.sflow.binding_constraint;
            kpis.thermal_utilisation = obj.lastResults.sflow.thermal_utilisation;
            kpis.flow_utilisation = obj.lastResults.sflow.flow_utilisation;
        end

        function info = getRunInfo(obj)
            %GETRUNINFO Get information about the last run.
            info = struct();
            info.timestamp = obj.lastTimestamp;
            info.hasResults = ~isempty(obj.lastResults);
            info.error = obj.lastError;

            if ~isempty(obj.lastConfig)
                info.chipset = obj.lastConfig.rack_profile.chipset;
                info.cooling_method = obj.lastConfig.rack_profile.cooling_method;
                info.process = obj.lastConfig.buyer_profile.process_id;
            end
        end
    end

    methods (Access = private)
        function exportJSON(obj, filepath)
            %EXPORTJSON Export results as JSON.
            % Create a simplified export struct
            exportData = struct();
            exportData.timestamp = char(obj.lastTimestamp);
            exportData.config = obj.lastConfig;
            exportData.SystemFlow = obj.lastResults.sflow;
            exportData.SystemPL = obj.lastResults.spl;
            exportData.BuyerProfile = obj.lastResults.bp;

            jsonStr = jsonencode(exportData, 'PrettyPrint', true);
            fid = fopen(filepath, 'w');
            if fid < 0
                error('ModelRunner:FileError', 'Cannot write to file: %s', filepath);
            end
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
        end

        function exportMAT(obj, filepath)
            %EXPORTMAT Export results as MAT file.
            results = obj.lastResults;
            config = obj.lastConfig;
            timestamp = obj.lastTimestamp;
            save(filepath, 'results', 'config', 'timestamp');
        end

        function exportCSV(obj, filepath)
            %EXPORTCSV Export results as flattened CSV.
            sections = {'spl', 'sflow', 'bp', 'scapex', 'sopex'};
            rows = {};

            for s = 1:numel(sections)
                sect = sections{s};
                if ~isfield(obj.lastResults, sect)
                    continue;
                end
                data = obj.lastResults.(sect);
                fields = fieldnames(data);
                for f = 1:numel(fields)
                    fname = fields{f};
                    val = data.(fname);
                    if isnumeric(val) && isscalar(val)
                        rows{end+1, 1} = sect;
                        rows{end, 2} = fname;
                        rows{end, 3} = val;
                    end
                end
            end

            if isempty(rows)
                error('ModelRunner:ExportError', 'No numeric fields to export.');
            end

            T = cell2table(rows, 'VariableNames', {'Section', 'Field', 'Value'});
            writetable(T, filepath);
        end
    end

    methods (Static, Access = private)
        function msg = formatError(ME)
            %FORMATERROR Format error for user display.
            msg = sprintf('Error: %s', ME.message);
            if ~isempty(ME.cause)
                for i = 1:numel(ME.cause)
                    msg = sprintf('%s\nCaused by: %s', msg, ME.cause{i}.message);
                end
            end
        end
    end
end
