function test_system_pl()
%TEST_SYSTEM_PL Validate system P&L formulas against Excel.

report = tribe_test_validate_sheet("9. System P&L");
assert(report.pass, tribe_test_report_message(report));
end
