function cache_excel_values(varargin)
%CACHE_EXCEL_VALUES Export cached Excel results for formula cells.

parser = inputParser;
parser.addParameter('excel_path', '');
parser.addParameter('formula_reference', '');
parser.addParameter('output_path', '');
parser.addParameter('use_excel', ispc);
parser.parse(varargin{:});
opts = parser.Results;

validation_dir = fileparts(mfilename('fullpath'));
model_root = fileparts(validation_dir);
repo_root = fileparts(model_root);

excel_path = opts.excel_path;
if isempty(excel_path)
    excel_path = fullfile(repo_root, 'Tribe_model_20.1.26.xlsx');
end

formula_reference = opts.formula_reference;
if isempty(formula_reference)
    formula_reference = fullfile(model_root, 'docs', 'A1_formula_reference.md');
end

output_path = opts.output_path;
if isempty(output_path)
    output_path = fullfile(validation_dir, 'excel_cached_values.json');
end

if ~opts.use_excel
    fprintf(['Note: use_excel is false; cached formula values may be missing. ', ...
        'Consider generating the cache on Windows with Excel.\n']);
end

formulas = parseFormulaReference(formula_reference);
records = struct('key', {}, 'sheet', {}, 'cell', {}, 'value', {});

cached = 0;
skipped = 0;
for i = 1:numel(formulas)
    entry = formulas(i);
    actual = readExcelCell(excel_path, entry.sheet, entry.cell, opts.use_excel);
    if isFormulaValue(actual) || ismissingValue(actual)
        skipped = skipped + 1;
        continue;
    end
    cached = cached + 1;
    key = char(entry.sheet + "!" + entry.cell);
    records(end + 1) = struct( ...
        'key', key, ...
        'sheet', char(entry.sheet), ...
        'cell', char(entry.cell), ...
        'value', actual); %#ok<AGROW>
end

cache = struct();
cache.excel_path = excel_path;
cache.generated_at = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss'));
cache.total = numel(formulas);
cache.cached = cached;
cache.skipped = skipped;
cache.values = records;

try
    payload = jsonencode(cache, 'PrettyPrint', true);
catch
    payload = jsonencode(cache);
end

fid = fopen(output_path, 'w');
if fid < 0
    error('cache_excel_values:WriteFailed', 'Unable to write cache file: %s', output_path);
end
fwrite(fid, payload, 'char');
fclose(fid);

fprintf('Cached %d of %d formula cells to %s\n', cached, numel(formulas), output_path);
if skipped > 0
    fprintf('Skipped %d cells with missing or formula-only values.\n', skipped);
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
