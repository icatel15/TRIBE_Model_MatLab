function test_system_opex()
%TEST_SYSTEM_OPEX Validate system opex formulas against Excel.

report = tribe_test_validate_sheet("7. System Opex");
assert(report.pass, tribe_test_report_message(report));
end
