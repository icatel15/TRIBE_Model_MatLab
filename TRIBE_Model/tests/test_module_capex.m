function test_module_capex()
%TEST_MODULE_CAPEX Validate module capex formulas against Excel.

report = tribe_test_validate_sheet("2. Module Capex");
assert(report.pass, tribe_test_report_message(report));
end
