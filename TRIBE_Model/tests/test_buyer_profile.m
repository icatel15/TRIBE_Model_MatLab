function test_buyer_profile()
%TEST_BUYER_PROFILE Validate buyer profile formulas against Excel.

report = tribe_test_validate_sheet("5. Buyer Profile");
assert(report.pass, tribe_test_report_message(report));
end
