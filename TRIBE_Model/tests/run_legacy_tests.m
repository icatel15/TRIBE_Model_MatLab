function results = run_legacy_tests()
%RUN_LEGACY_TESTS Run assert-based test_*.m functions in this folder.

test_dir = fileparts(mfilename('fullpath'));
addpath(test_dir);

files = dir(fullfile(test_dir, 'test_*.m'));
names = sort({files.name});

results = struct('name', {}, 'passed', {}, 'error', {});

for i = 1:numel(names)
    [~, test_name] = fileparts(names{i});
    try
        feval(test_name);
        results(end+1) = struct('name', test_name, 'passed', true, 'error', ''); %#ok<AGROW>
        fprintf('PASS %s\n', test_name);
    catch ME
        results(end+1) = struct('name', test_name, 'passed', false, 'error', ME.message); %#ok<AGROW>
        fprintf('FAIL %s: %s\n', test_name, ME.message);
    end
end

if isempty(results)
    fprintf('No legacy tests found in %s\n', test_dir);
    return;
end

passed = [results.passed];
n_passed = sum(passed);
n_failed = numel(passed) - n_passed;
fprintf('Totals: %d passed, %d failed.\n', n_passed, n_failed);

if n_failed > 0
    error('Legacy tests failed: %d of %d.', n_failed, numel(passed));
end
end
