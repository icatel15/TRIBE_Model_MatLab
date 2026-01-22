function test_rack_profile()
%TEST_RACK_PROFILE Validate rack profile formulas against Excel.

report = tribe_test_validate_sheet("0. Rack Profile");
assert(report.pass, tribe_test_report_message(report));
end
