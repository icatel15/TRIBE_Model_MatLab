function test_reference_data()
%TEST_REFERENCE_DATA Validate reference data formulas against Excel.

report = tribe_test_validate_sheet("11. Reference Data");
assert(report.pass, tribe_test_report_message(report));
end
