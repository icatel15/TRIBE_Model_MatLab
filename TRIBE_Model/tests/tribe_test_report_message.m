function msg = tribe_test_report_message(report)
%TRIBE_TEST_REPORT_MESSAGE Format a summary message for failed validations.

msg = sprintf('Validation failed: matched=%d mismatched=%d skipped=%d missing=%d coverage=%.1f%%', ...
    report.matched, report.mismatched, report.skipped, report.missing, report.coverage * 100);

if ~isempty(report.mismatch_details)
    first = report.mismatch_details(1);
    msg = sprintf('%s. First mismatch: %s!%s %s', msg, first.sheet, first.cell, first.field);
end
end
