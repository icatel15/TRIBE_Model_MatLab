function test_full_model()
%TEST_FULL_MODEL Validate the full model against Excel.

report = tribe_test_validate_sheet();
assert(report.pass, tribe_test_report_message(report));
end
