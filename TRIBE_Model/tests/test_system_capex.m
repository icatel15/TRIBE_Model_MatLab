function test_system_capex()
%TEST_SYSTEM_CAPEX Validate system capex formulas against Excel.

report = tribe_test_validate_sheet("6. System Capex");
assert(report.pass, tribe_test_report_message(report));
end
