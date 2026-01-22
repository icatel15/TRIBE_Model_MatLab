function test_module_flow()
%TEST_MODULE_FLOW Validate module flow formulas against Excel.

report = tribe_test_validate_sheet("4. Module Flow");
assert(report.pass, tribe_test_report_message(report));
end
