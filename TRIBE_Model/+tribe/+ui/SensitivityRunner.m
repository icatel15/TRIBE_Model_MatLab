classdef SensitivityRunner < handle
    %SENSITIVITYRUNNER Execute sensitivity analysis and parameter sweeps.
    % Wraps existing analysis functions for UI integration.

    properties
        baseConfig          % Base configuration for sweeps
        lastSensitivity     % Result from sensitivityAnalysis
        lastSweep           % Result from parameterSweep
        last2DSweep         % Result from 2D parameter sweep
    end

    properties (Access = private)
        isCancelled         % Flag to cancel long-running sweeps
    end

    methods
        function obj = SensitivityRunner(config)
            %SENSITIVITYRUNNER Constructor.
            % SensitivityRunner() - use default config
            % SensitivityRunner(config) - use provided config

            if nargin < 1 || isempty(config)
                obj.baseConfig = tribe.Config.default();
            else
                obj.baseConfig = tribe.Config.apply(config);
            end

            obj.lastSensitivity = [];
            obj.lastSweep = [];
            obj.last2DSweep = [];
            obj.isCancelled = false;
        end

        function setBaseConfig(obj, config)
            %SETBASECONFIG Update the base configuration.
            obj.baseConfig = tribe.Config.apply(config);
        end

        function result = runSensitivity(obj, param_names, deltas)
            %RUNSENSITIVITY Run tornado sensitivity analysis.
            % result = runSensitivity(obj) - use defaults
            % result = runSensitivity(obj, param_names) - custom parameters
            % result = runSensitivity(obj, param_names, deltas) - custom deltas

            if nargin < 2 || isempty(param_names)
                param_names = obj.getDefaultSensitivityParams();
            end

            if nargin < 3 || isempty(deltas)
                deltas = [-0.2, -0.1, 0.1, 0.2];
            end

            result = tribe.analysis.sensitivityAnalysis(obj.baseConfig, param_names, deltas);
            obj.lastSensitivity = result;
        end

        function result = runSweep(obj, param_name, values)
            %RUNSWEEP Run 1D parameter sweep.
            % result = runSweep(obj, param_name, values)
            % Returns table with parameter values and output metrics.

            if nargin < 3 || isempty(values)
                % Auto-generate values based on default range
                base_value = tribe.analysis.getNestedField(obj.baseConfig, param_name);
                values = linspace(base_value * 0.5, base_value * 1.5, 11);
                values = tribe.ui.SensitivityRunner.applySweepConstraints(param_name, base_value, values);
            end

            result = tribe.analysis.parameterSweep(obj.baseConfig, param_name, values);
            obj.lastSweep = result;
        end

        function result = run2DSweep(obj, param1_name, param1_values, param2_name, param2_values, metric)
            %RUN2DSWEEP Run 2D parameter sweep for heatmap.
            % result = run2DSweep(obj, param1_name, vals1, param2_name, vals2, metric)
            % metric: 'simple_payback_years', 'unlevered_roi_pct', or 'gross_margin_pct'

            if nargin < 6 || isempty(metric)
                metric = 'simple_payback_years';
            end

            obj.isCancelled = false;
            n1 = numel(param1_values);
            n2 = numel(param2_values);
            total = n1 * n2;

            % Initialize result matrix
            Z = zeros(n2, n1);

            count = 0;
            for i = 1:n1
                if obj.isCancelled
                    break;
                end

                for j = 1:n2
                    if obj.isCancelled
                        break;
                    end

                    count = count + 1;

                    % Set both parameters
                    cfg = obj.baseConfig;
                    cfg = tribe.analysis.setNestedField(cfg, param1_name, param1_values(i));
                    cfg = tribe.analysis.setNestedField(cfg, param2_name, param2_values(j));

                    try
                        run_result = tribe.Model.runWithConfig(cfg);
                        Z(j, i) = run_result.spl.(metric);
                    catch
                        Z(j, i) = NaN;
                    end
                end
            end

            result = struct();
            result.param1_name = param1_name;
            result.param1_values = param1_values;
            result.param2_name = param2_name;
            result.param2_values = param2_values;
            result.metric = metric;
            result.Z = Z;
            result.completed = ~obj.isCancelled;

            obj.last2DSweep = result;
        end

        function cancel(obj)
            %CANCEL Cancel a running sweep.
            obj.isCancelled = true;
        end

        function params = getSweepableParameters(obj) %#ok<MANU>
            %GETSWEEPABLEPARAMETERS Get all numeric config paths for sweeping.
            params = tribe.ui.ConfigInspector.getSweepableParameters();
        end

        function metrics = getAvailableMetrics(obj) %#ok<MANU>
            %GETAVAILABLEMETRICS Get available output metrics for analysis.
            metrics = struct();
            metrics.simple_payback_years = 'Simple Payback (years)';
            metrics.unlevered_roi_pct = 'Unlevered ROI (%)';
            metrics.gross_margin_pct = 'Gross Margin (%)';
            metrics.gross_profit_gbp_per_yr = 'Gross Profit (GBP/yr)';
            metrics.total_revenue_gbp_per_yr = 'Total Revenue (GBP/yr)';
            metrics.total_system_capex_gbp = 'Total Capex (GBP)';
        end

        function params = getDefaultSensitivityParams(obj) %#ok<MANU>
            %GETDEFAULTSENSITIVITYPARAMS Get default parameters for sensitivity analysis.
            params = [
                "module_criteria.compute_rate_gbp_per_kw_per_month"
                "module_criteria.target_utilisation_rate_pct"
                "module_criteria.base_heat_price_no_hp_gbp_per_mwh"
                "module_criteria.premium_heat_price_with_hp_gbp_per_mwh"
                "module_opex.electricity_rate_gbp_per_kwh"
                "rack_profile.module_it_capacity_target_kw"
                "system.shared_infrastructure_pct"
                "system.shared_overhead_pct"
            ];
        end

        function [x, y] = getSweepPlotData(obj, metric)
            %GETSWEEPPLOTDATA Get data for 1D sweep line plot.
            if isempty(obj.lastSweep)
                error('SensitivityRunner:NoData', 'No sweep data available.');
            end

            if nargin < 2
                metric = 'simple_payback_years';
            end

            x = obj.lastSweep.param_value;
            y = obj.lastSweep.(metric);
        end

        function tornadoData = getTornadoData(obj, metric)
            %GETTORNADODATA Get data for tornado chart.
            if isempty(obj.lastSensitivity)
                error('SensitivityRunner:NoData', 'No sensitivity data available.');
            end

            if nargin < 2
                metric = 'simple_payback_years';
            end

            tornadoData = obj.lastSensitivity.tornado.(metric);
        end

        function exportSweep(obj, filepath, format)
            %EXPORTSWEEP Export sweep results to file.
            if isempty(obj.lastSweep)
                error('SensitivityRunner:NoData', 'No sweep data to export.');
            end

            if nargin < 3
                [~, ~, ext] = fileparts(filepath);
                format = lower(strrep(ext, '.', ''));
            end

            switch lower(format)
                case 'csv'
                    writetable(obj.lastSweep, filepath);
                case 'mat'
                    sweepResults = obj.lastSweep;
                    save(filepath, 'sweepResults');
                otherwise
                    error('SensitivityRunner:InvalidFormat', 'Unsupported format: %s', format);
            end
        end

        function export2DSweep(obj, filepath, format)
            %EXPORT2DSWEEP Export 2D sweep results to file.
            if isempty(obj.last2DSweep)
                error('SensitivityRunner:NoData', 'No 2D sweep data to export.');
            end

            if nargin < 3
                [~, ~, ext] = fileparts(filepath);
                format = lower(strrep(ext, '.', ''));
            end

            switch lower(format)
                case 'csv'
                    % Create a table with x, y, z columns
                    result = obj.last2DSweep;
                    [X, Y] = meshgrid(result.param1_values, result.param2_values);
                    varNames = matlab.lang.makeValidName({result.param1_name, result.param2_name, result.metric});
                    varNames = matlab.lang.makeUniqueStrings(varNames);
                    T = table(X(:), Y(:), result.Z(:), ...
                        'VariableNames', varNames);
                    writetable(T, filepath);
                case 'mat'
                    sweep2DResults = obj.last2DSweep;
                    save(filepath, 'sweep2DResults');
                otherwise
                    error('SensitivityRunner:InvalidFormat', 'Unsupported format: %s', format);
            end
        end
    end

    methods (Static, Access = private)
        function values = applySweepConstraints(param_name, base_value, values)
            try
                meta = tribe.ui.ConfigInspector.getFieldMeta(param_name);
            catch
                return;
            end

            constraint = lower(string(meta.constraints));
            switch constraint
                case "fraction"
                    values = min(max(values, 0), 1);
                case "non_negative"
                    values(values < 0) = 0;
                case "positive"
                    if base_value <= 0
                        fallback = meta.default;
                        if isnumeric(fallback) && isscalar(fallback) && fallback > 0
                            values = linspace(fallback * 0.5, fallback * 1.5, numel(values));
                        end
                    end
                    values(values <= 0) = eps;
            end
        end
    end
end
