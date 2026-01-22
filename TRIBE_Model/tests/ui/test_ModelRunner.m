function tests = test_ModelRunner
%TEST_MODELRUNNER Unit tests for tribe.ui.ModelRunner
    tests = functiontests(localfunctions);
end

function test_constructor_creates_empty_state(testCase)
    runner = tribe.ui.ModelRunner();

    verifyEmpty(testCase, runner.lastResults);
    verifyEmpty(testCase, runner.lastConfig);
    verifyEmpty(testCase, runner.lastError);
end

function test_run_with_default_config_succeeds(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();

    [results, success, errMsg] = runner.run(cfg);

    verifyTrue(testCase, success);
    verifyEmpty(testCase, errMsg);
    verifyTrue(testCase, isfield(results, 'spl'));
    verifyTrue(testCase, isfield(results, 'sflow'));
end

function test_run_stores_results(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();

    runner.run(cfg);

    verifyNotEmpty(testCase, runner.lastResults);
    verifyNotEmpty(testCase, runner.lastConfig);
    verifyNotEmpty(testCase, runner.lastTimestamp);
end

function test_run_with_invalid_config_fails_gracefully(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = struct();  % Invalid empty config

    [~, success, errMsg] = runner.run(cfg);

    verifyFalse(testCase, success);
    verifyNotEmpty(testCase, errMsg);
end

function test_hasValidResults_after_run(testCase)
    runner = tribe.ui.ModelRunner();
    verifyFalse(testCase, runner.hasValidResults());

    cfg = tribe.Config.default();
    runner.run(cfg);

    verifyTrue(testCase, runner.hasValidResults());
end

function test_getKPIs_returns_expected_fields(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    kpis = runner.getKPIs();

    verifyTrue(testCase, isfield(kpis, 'simple_payback_years'));
    verifyTrue(testCase, isfield(kpis, 'unlevered_roi_pct'));
    verifyTrue(testCase, isfield(kpis, 'gross_margin_pct'));
    verifyTrue(testCase, isfield(kpis, 'total_system_capex_gbp'));
    verifyTrue(testCase, isfield(kpis, 'gross_profit_gbp_per_yr'));
    verifyTrue(testCase, isfield(kpis, 'modules_in_system'));
end

function test_getKPIs_values_are_reasonable(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    kpis = runner.getKPIs();

    verifyGreaterThan(testCase, kpis.simple_payback_years, 0);
    verifyGreaterThan(testCase, kpis.total_system_capex_gbp, 0);
    verifyGreaterThanOrEqual(testCase, kpis.modules_in_system, 1);
end

function test_getResultsTable_returns_table(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    T = runner.getResultsTable('spl');

    verifyClass(testCase, T, 'table');
    verifyGreaterThan(testCase, height(T), 0);
end

function test_getRunInfo_returns_expected_fields(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    info = runner.getRunInfo();

    verifyTrue(testCase, isfield(info, 'timestamp'));
    verifyTrue(testCase, isfield(info, 'hasResults'));
    verifyTrue(testCase, isfield(info, 'chipset'));
    verifyTrue(testCase, info.hasResults);
end

function test_exportResults_csv(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    tempFile = [tempname '.csv'];
    cleanup = onCleanup(@() delete(tempFile));

    runner.exportResults(tempFile, 'csv');

    verifyTrue(testCase, isfile(tempFile));
    T = readtable(tempFile);
    verifyGreaterThan(testCase, height(T), 0);
end

function test_exportResults_mat(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    tempFile = [tempname '.mat'];
    cleanup = onCleanup(@() delete(tempFile));

    runner.exportResults(tempFile, 'mat');

    verifyTrue(testCase, isfile(tempFile));
    data = load(tempFile);
    verifyTrue(testCase, isfield(data, 'results'));
end

function test_exportResults_json(testCase)
    runner = tribe.ui.ModelRunner();
    cfg = tribe.Config.default();
    runner.run(cfg);

    tempFile = [tempname '.json'];
    cleanup = onCleanup(@() delete(tempFile));

    runner.exportResults(tempFile, 'json');

    verifyTrue(testCase, isfile(tempFile));
    fid = fopen(tempFile, 'r');
    raw = fread(fid, '*char')';
    fclose(fid);
    data = jsondecode(raw);
    verifyTrue(testCase, isfield(data, 'SystemPL'));
end

function test_exportResults_errors_without_results(testCase)
    runner = tribe.ui.ModelRunner();

    verifyError(testCase, @() runner.exportResults('test.csv'), 'ModelRunner:NoResults');
end
