function tests = test_SensitivityRunner
%TEST_SENSITIVITYRUNNER Unit tests for tribe.ui.SensitivityRunner
    tests = functiontests(localfunctions);
end

function test_constructor_creates_default_config(testCase)
    runner = tribe.ui.SensitivityRunner();

    verifyNotEmpty(testCase, runner.baseConfig);
    verifyTrue(testCase, isstruct(runner.baseConfig));
end

function test_constructor_with_custom_config(testCase)
    cfg = tribe.Config.default();
    cfg.rack_profile.chipset = "NVIDIA H200";

    runner = tribe.ui.SensitivityRunner(cfg);

    verifyEqual(testCase, runner.baseConfig.rack_profile.chipset, "NVIDIA H200");
end

function test_setBaseConfig_updates_config(testCase)
    runner = tribe.ui.SensitivityRunner();
    newCfg = tribe.Config.default();
    newCfg.rack_profile.module_it_capacity_target_kw = 300;

    runner.setBaseConfig(newCfg);

    verifyEqual(testCase, runner.baseConfig.rack_profile.module_it_capacity_target_kw, 300);
end

function test_runSensitivity_returns_valid_result(testCase)
    runner = tribe.ui.SensitivityRunner();

    result = runner.runSensitivity();

    verifyTrue(testCase, isfield(result, 'base_config'));
    verifyTrue(testCase, isfield(result, 'base_results'));
    verifyTrue(testCase, isfield(result, 'base_metrics'));
    verifyTrue(testCase, isfield(result, 'scenarios'));
    verifyTrue(testCase, isfield(result, 'tornado'));
end

function test_runSensitivity_tornado_contains_metrics(testCase)
    runner = tribe.ui.SensitivityRunner();

    result = runner.runSensitivity();

    verifyTrue(testCase, isfield(result.tornado, 'simple_payback_years'));
    verifyTrue(testCase, isfield(result.tornado, 'unlevered_roi_pct'));
    verifyTrue(testCase, isfield(result.tornado, 'gross_margin_pct'));
end

function test_runSensitivity_with_custom_params(testCase)
    runner = tribe.ui.SensitivityRunner();
    params = ["module_criteria.compute_rate_gbp_per_kw_per_month"];
    deltas = [-0.1, 0.1];

    result = runner.runSensitivity(params, deltas);

    verifyEqual(testCase, height(result.scenarios), 2);  % 1 param * 2 deltas
end

function test_runSweep_returns_table(testCase)
    runner = tribe.ui.SensitivityRunner();
    values = linspace(100, 200, 5);

    result = runner.runSweep('module_criteria.compute_rate_gbp_per_kw_per_month', values);

    verifyClass(testCase, result, 'table');
    verifyEqual(testCase, height(result), 5);
end

function test_runSweep_contains_expected_columns(testCase)
    runner = tribe.ui.SensitivityRunner();
    values = [100, 150, 200];

    result = runner.runSweep('module_criteria.compute_rate_gbp_per_kw_per_month', values);

    verifyTrue(testCase, ismember('param_value', result.Properties.VariableNames));
    verifyTrue(testCase, ismember('simple_payback_years', result.Properties.VariableNames));
    verifyTrue(testCase, ismember('unlevered_roi_pct', result.Properties.VariableNames));
end

function test_run2DSweep_returns_valid_result(testCase)
    runner = tribe.ui.SensitivityRunner();
    vals1 = [100, 150, 200];
    vals2 = [0.15, 0.18, 0.21];

    result = runner.run2DSweep(...
        'module_criteria.compute_rate_gbp_per_kw_per_month', vals1, ...
        'module_opex.electricity_rate_gbp_per_kwh', vals2, ...
        'simple_payback_years');

    verifyTrue(testCase, isfield(result, 'Z'));
    verifyEqual(testCase, size(result.Z), [3, 3]);
    verifyEqual(testCase, result.param1_name, 'module_criteria.compute_rate_gbp_per_kw_per_month');
    verifyEqual(testCase, result.metric, 'simple_payback_years');
end

function test_getSweepableParameters_returns_numeric_paths(testCase)
    runner = tribe.ui.SensitivityRunner();

    params = runner.getSweepableParameters();

    verifyClass(testCase, params, 'string');
    verifyGreaterThan(testCase, numel(params), 10);
end

function test_getAvailableMetrics_returns_struct(testCase)
    runner = tribe.ui.SensitivityRunner();

    metrics = runner.getAvailableMetrics();

    verifyTrue(testCase, isstruct(metrics));
    verifyTrue(testCase, isfield(metrics, 'simple_payback_years'));
    verifyTrue(testCase, isfield(metrics, 'unlevered_roi_pct'));
end

function test_getDefaultSensitivityParams_returns_valid_params(testCase)
    runner = tribe.ui.SensitivityRunner();

    params = runner.getDefaultSensitivityParams();

    verifyClass(testCase, params, 'string');
    verifyEqual(testCase, numel(params), 8);
end

function test_getTornadoData_returns_table(testCase)
    runner = tribe.ui.SensitivityRunner();
    runner.runSensitivity();

    data = runner.getTornadoData('simple_payback_years');

    verifyClass(testCase, data, 'table');
    verifyTrue(testCase, ismember('parameter', data.Properties.VariableNames));
    verifyTrue(testCase, ismember('low_delta', data.Properties.VariableNames));
end

function test_getSweepPlotData_returns_xy(testCase)
    runner = tribe.ui.SensitivityRunner();
    values = linspace(100, 200, 5);
    runner.runSweep('module_criteria.compute_rate_gbp_per_kw_per_month', values);

    [x, y] = runner.getSweepPlotData('simple_payback_years');

    verifyEqual(testCase, numel(x), 5);
    verifyEqual(testCase, numel(y), 5);
end

function test_exportSweep_csv(testCase)
    runner = tribe.ui.SensitivityRunner();
    values = [100, 150, 200];
    runner.runSweep('module_criteria.compute_rate_gbp_per_kw_per_month', values);

    tempFile = [tempname '.csv'];
    cleanup = onCleanup(@() delete(tempFile));

    runner.exportSweep(tempFile);

    verifyTrue(testCase, isfile(tempFile));
end

function test_export2DSweep_csv(testCase)
    runner = tribe.ui.SensitivityRunner();
    vals1 = [100, 150];
    vals2 = [0.15, 0.18];
    runner.run2DSweep(...
        'module_criteria.compute_rate_gbp_per_kw_per_month', vals1, ...
        'module_opex.electricity_rate_gbp_per_kwh', vals2, ...
        'simple_payback_years');

    tempFile = [tempname '.csv'];
    cleanup = onCleanup(@() delete(tempFile));

    runner.export2DSweep(tempFile);

    verifyTrue(testCase, isfile(tempFile));
end
