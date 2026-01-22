function test_module_criteria()
%TEST_MODULE_CRITERIA Validate module criteria formulas against Excel.

report = tribe_test_validate_sheet("1. Module Criteria");
assert(report.pass, tribe_test_report_message(report));
end
