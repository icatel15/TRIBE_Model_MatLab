function report = validate_against_excel(varargin)
%VALIDATE_AGAINST_EXCEL Compare model outputs against Excel formula cells.

parser = inputParser;
parser.addParameter('config', []);
parser.addParameter('excel_path', '');
parser.addParameter('formula_reference', '');
parser.addParameter('sheets', string.empty(0, 1));
parser.addParameter('quiet', false);
parser.addParameter('abs_tolerance', 1e-6);
parser.addParameter('rel_tolerance', 1e-4);
parser.addParameter('use_excel', ispc);
parser.addParameter('skip_uncached', true);
parser.addParameter('cache_path', '');
parser.addParameter('min_coverage', 0.5);
parser.parse(varargin{:});
opts = parser.Results;

validation_dir = fileparts(mfilename('fullpath'));
model_root = fileparts(validation_dir);
repo_root = fileparts(model_root);
addpath(model_root);

excel_path = opts.excel_path;
if isempty(excel_path)
    excel_path = fullfile(repo_root, 'Tribe_model_20.1.26.xlsx');
end

formula_reference = opts.formula_reference;
if isempty(formula_reference)
    formula_reference = fullfile(model_root, 'docs', 'A1_formula_reference.md');
end

cfg = opts.config;
if isempty(cfg)
    cfg = tribe.Config.default();
end

results = tribe.Model.runWithConfig(cfg);

formulas = parseFormulaReference(formula_reference);
if ~isempty(opts.sheets)
    sheets = string(opts.sheets);
    formulas = formulas(ismember([formulas.sheet], sheets));
end

cache_path = opts.cache_path;
if isempty(cache_path)
    default_cache = fullfile(validation_dir, 'excel_cached_values.json');
    if exist(default_cache, 'file')
        cache_path = default_cache;
    end
end

cache_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
if ~isempty(cache_path) && exist(cache_path, 'file')
    cache_map = loadCache(cache_path);
    if ~opts.quiet && ~isempty(cache_map)
        fprintf('Using cached Excel values from %s\n', cache_path);
    end
end

counts = struct('total', 0, 'matched', 0, 'mismatched', 0, 'skipped', 0, 'missing', 0);
mismatches = struct('sheet', {}, 'cell', {}, 'field', {}, 'expected', {}, 'actual', {}, 'diff', {});
skipped = struct('sheet', {}, 'cell', {}, 'field', {}, 'reason', {});
missing = struct('sheet', {}, 'cell', {}, 'field', {}, 'reason', {});

for i = 1:numel(formulas)
    entry = formulas(i);
    counts.total = counts.total + 1;

    [expected, has_expected, full_field, reason] = lookupExpected(results, entry);
    if ~has_expected
        counts.missing = counts.missing + 1;
        missing(end + 1) = struct('sheet', entry.sheet, 'cell', entry.cell, ...
            'field', full_field, 'reason', reason); %#ok<AGROW>
        continue;
    end

    used_cache = false;
    if ~isempty(cache_map)
        key = char(entry.sheet + "!" + entry.cell);
        if isKey(cache_map, key)
            actual = cache_map(key);
            used_cache = true;
        end
    end
    if ~used_cache
        actual = readExcelCell(excel_path, entry.sheet, entry.cell, opts.use_excel);
    end
    if isFormulaValue(actual) || ismissingValue(actual)
        counts.skipped = counts.skipped + 1;
        skipped(end + 1) = struct('sheet', entry.sheet, 'cell', entry.cell, ...
            'field', full_field, 'reason', "excel_value_missing"); %#ok<AGROW>
        continue;
    end
    if opts.skip_uncached && ~used_cache && ~opts.use_excel && isLikelyUncached(actual, expected)
        counts.skipped = counts.skipped + 1;
        skipped(end + 1) = struct('sheet', entry.sheet, 'cell', entry.cell, ...
            'field', full_field, 'reason', "excel_formula_uncached"); %#ok<AGROW>
        continue;
    end

    [ok, diff] = compareValues(expected, actual, opts.abs_tolerance, opts.rel_tolerance);
    if ok
        counts.matched = counts.matched + 1;
    else
        counts.mismatched = counts.mismatched + 1;
        mismatches(end + 1) = struct('sheet', entry.sheet, 'cell', entry.cell, ...
            'field', full_field, 'expected', expected, ...
            'actual', actual, 'diff', diff); %#ok<AGROW>
    end
end

report = struct();
report.total = counts.total;
report.matched = counts.matched;
report.mismatched = counts.mismatched;
report.skipped = counts.skipped;
report.missing = counts.missing;
report.compared = counts.matched + counts.mismatched;
if counts.total > 0
    report.coverage = report.compared / counts.total;
else
    report.coverage = 0;
end
report.coverage_threshold = opts.min_coverage;
report.coverage_ok = report.coverage >= opts.min_coverage;
report.pass = counts.mismatched == 0 && counts.missing == 0 && report.coverage_ok;
report.mismatch_details = mismatches;
report.skip_details = skipped;
report.missing_details = missing;

if ~opts.quiet
    fprintf('Validation summary: total=%d matched=%d mismatched=%d skipped=%d missing=%d coverage=%.1f%%\n', ...
        report.total, report.matched, report.mismatched, report.skipped, report.missing, report.coverage * 100);

    if ~isempty(mismatches)
        fprintf('Mismatches (first 10):\n');
        for i = 1:min(10, numel(mismatches))
            item = mismatches(i);
            fprintf('  %s!%s %s expected=%s actual=%s\n', item.sheet, item.cell, item.field, ...
                valueToString(item.expected), valueToString(item.actual));
        end
    end

    if ~report.coverage_ok
        fprintf('Warning: low Excel coverage; many formula cells may not be cached.\n');
        fprintf('Coverage below threshold (%.1f%% < %.1f%%).\n', ...
            report.coverage * 100, report.coverage_threshold * 100);
    end
end
end

function formulas = parseFormulaReference(filepath)
lines = splitlines(string(fileread(filepath)));
formulas = struct('sheet', {}, 'cell', {}, 'type', {}, 'prefix', {}, 'field', {});

for i = 1:numel(lines)
    line = strtrim(lines(i));
    if strlength(line) == 0 || ~startsWith(line, "|")
        continue;
    end
    if contains(line, "|---") || contains(line, "| # ")
        continue;
    end

    parts = split(line, "|");
    if numel(parts) < 8
        continue;
    end

    sheet_cell = strip(parts(3));
    sheet_cell = strip(sheet_cell, "`");
    if ~contains(sheet_cell, "!")
        continue;
    end

    type = strip(parts(5));
    transcription = strip(parts(7));
    transcription = strip(transcription, "`");

    tokens = regexp(transcription, '^([A-Za-z_]+)\.([A-Za-z0-9_]+)', 'tokens', 'once');
    if isempty(tokens)
        prefix = "";
        field = "";
    else
        prefix = string(tokens{1});
        field = string(tokens{2});
    end

    parts_sheet = split(sheet_cell, "!");
    sheet = string(parts_sheet(1));
    cell = string(parts_sheet(2));

    formulas(end + 1) = struct('sheet', sheet, 'cell', cell, 'type', string(type), ...
        'prefix', prefix, 'field', field); %#ok<AGROW>
end
end

function [value, ok, full_field, reason] = lookupExpected(results, entry)
ok = false;
reason = "no_mapping";
value = [];
full_field = "";

prefix = entry.prefix;
field = entry.field;

[value, ok, full_field] = lookupReferenceDataCell(results, entry.sheet, entry.cell);
if ok
    reason = "";
    return;
end

if strlength(prefix) == 0 || strlength(field) == 0
    full_field = entry.sheet + "!" + entry.cell;
    return;
end

prefix_map = struct( ...
    'rp', 'rp', ...
    'mc', 'mc', ...
    'mcapex', 'mcapex', ...
    'mopex', 'mopex', ...
    'mflow', 'mflow', ...
    'bp', 'bp', ...
    'scapex', 'scapex', ...
    'sopex', 'sopex', ...
    'sflow', 'sflow', ...
    'spl', 'spl', ...
    'ref', 'ref' ...
    );

prefix_char = char(prefix);
if ~isfield(prefix_map, prefix_char)
    reason = "unknown_prefix";
    full_field = string(prefix) + "." + string(field);
    return;
end

result_key = prefix_map.(prefix_char);
if ~isfield(results, result_key)
    reason = "missing_results_field";
    full_field = string(prefix) + "." + string(field);
    return;
end

container = results.(result_key);
field_name = field;
field_char = char(field);
if ~isfield(container, field_char)
    alt = strrep(field_char, 'delta_t', 'deltat');
    if isfield(container, alt)
        field_name = string(alt);
    else
        reason = "missing_field";
        full_field = string(prefix) + "." + string(field);
        return;
    end
end

value = container.(char(field_name));
full_field = string(prefix) + "." + string(field_name);
ok = true;
reason = "";
end

function [value, ok, full_field] = lookupReferenceDataCell(results, sheet, cell_ref)
ok = false;
value = [];
full_field = "";

if sheet ~= "11. Reference Data"
    return;
end

cell_ref = upper(string(cell_ref));
if strlength(cell_ref) < 2
    return;
end

col_letter = extractBetween(cell_ref, 1, 1);
row_number = str2double(extractAfter(cell_ref, 1));
if isempty(col_letter) || isnan(row_number)
    return;
end

idx = row_number - 46;
if idx < 1 || idx > 4
    return;
end

if ~isfield(results, 'ref')
    return;
end

ref = results.ref;
switch char(col_letter)
    case 'B'
        field = "hp_reference_temperature_lift_c";
    case 'C'
        field = "hp_reference_cop";
    case 'D'
        field = "hp_reference_kwe_per_kwth";
    otherwise
        return;
end

if ~isfield(ref, char(field))
    return;
end

value = ref.(char(field))(idx);
full_field = "ref." + field + "(" + string(idx) + ")";
ok = true;
end

function cache_map = loadCache(cache_path)
cache_map = containers.Map('KeyType', 'char', 'ValueType', 'any');

raw = jsondecode(fileread(cache_path));
if isstruct(raw) && isfield(raw, 'values')
    entries = raw.values;
else
    entries = raw;
end

if isempty(entries) || ~isstruct(entries)
    return;
end

for i = 1:numel(entries)
    if ~isfield(entries(i), 'key') || ~isfield(entries(i), 'value')
        continue;
    end
    key = entries(i).key;
    if ~(isstring(key) || ischar(key))
        continue;
    end
    key = char(string(key));
    if strlength(string(key)) == 0
        continue;
    end
    cache_map(key) = entries(i).value;
end
end

function value = readExcelCell(excel_path, sheet, cell_ref, use_excel)
if nargin < 4
    use_excel = ispc;
end
if use_excel
    try
        data = readcell(excel_path, 'Sheet', sheet, 'Range', cell_ref, 'UseExcel', true);
    catch
        data = readcell(excel_path, 'Sheet', sheet, 'Range', cell_ref);
    end
else
    data = readcell(excel_path, 'Sheet', sheet, 'Range', cell_ref);
end
if isempty(data)
    value = [];
else
    value = data{1};
end
end

function tf = isFormulaValue(value)
if ischar(value) || isstring(value)
    tf = startsWith(string(value), "=");
else
    tf = false;
end
end

function tf = ismissingValue(value)
if isempty(value)
    tf = true;
    return;
end
if isnumeric(value)
    tf = any(isnan(value), 'all');
    return;
end
if isstring(value)
    tf = all(ismissing(value));
    return;
end
if ischar(value)
    tf = strlength(string(value)) == 0;
    return;
end

try
    tf = all(ismissing(value));
catch
    tf = false;
end
end

function tf = isLikelyUncached(actual, expected)
[expected_norm, expected_kind] = normalizeValue(expected);
[actual_norm, actual_kind] = normalizeValue(actual);

tf = false;
if expected_kind == "numeric" && actual_kind == "numeric"
    if all(actual_norm == 0, 'all') && any(abs(expected_norm) > 1e-9, 'all')
        tf = true;
    end
    return;
end

if expected_kind == "string"
    has_expected_text = any(strlength(expected_norm) > 0, 'all');
    if actual_kind == "numeric"
        if has_expected_text && all(actual_norm == 0, 'all')
            tf = true;
        end
    elseif actual_kind == "string"
        if has_expected_text && all(strlength(actual_norm) == 0, 'all')
            tf = true;
        end
    end
end
end

function [ok, diff] = compareValues(expected, actual, abs_tol, rel_tol)
[expected, expected_kind] = normalizeValue(expected);
[actual, actual_kind] = normalizeValue(actual);

if expected_kind == "numeric" && actual_kind == "numeric"
    if ~isequal(size(expected), size(actual))
        ok = false;
        diff = NaN;
        return;
    end
    delta = abs(expected - actual);
    tol = max(abs_tol, rel_tol * max(abs(expected), abs(actual)));
    ok = all(delta <= tol, 'all');
    diff = max(delta, [], 'all');
    return;
end

if expected_kind == "string" && actual_kind == "string"
    ok = isequal(expected, actual);
    diff = 0;
    return;
end

ok = false;
diff = NaN;
end

function [value, kind] = normalizeValue(value)
if isnumeric(value)
    kind = "numeric";
    return;
end
if islogical(value)
    value = double(value);
    kind = "numeric";
    return;
end

if isstring(value) || ischar(value)
    text = string(value);
    text = replace(text, char(160), ' ');
    value = strtrim(text);
    kind = "string";
    return;
end

kind = "other";
end

function text = valueToString(value)
if isstring(value) || ischar(value)
    text = char(string(value));
elseif isnumeric(value)
    text = mat2str(value);
else
    text = '<unprintable>';
end
end
