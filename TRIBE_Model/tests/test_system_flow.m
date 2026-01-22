function test_system_flow()
%TEST_SYSTEM_FLOW Validate system flow formulas against Excel.

report = tribe_test_validate_sheet("8. System Flow");
assert(report.pass, tribe_test_report_message(report));
end
