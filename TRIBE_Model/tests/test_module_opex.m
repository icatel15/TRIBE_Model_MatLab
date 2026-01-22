function test_module_opex()
%TEST_MODULE_OPEX Validate module opex formulas against Excel.

report = tribe_test_validate_sheet("3. Module Opex");
assert(report.pass, tribe_test_report_message(report));
end
