function report = tribe_test_validate_sheet(sheet_names)
%TRIBE_TEST_VALIDATE_SHEET Run Excel validation for specific sheet(s).

test_dir = fileparts(mfilename('fullpath'));
model_root = fileparts(test_dir);
validation_dir = fullfile(model_root, 'validation');

addpath(model_root);
addpath(validation_dir);

if nargin < 1 || isempty(sheet_names)
    report = validate_against_excel();
else
    report = validate_against_excel('sheets', sheet_names);
end
end
