function cfg = setNestedField(cfg, field_path, value)
%SETNESTEDFIELD Set a nested struct field using dot notation.

if nargin < 2 || isempty(field_path)
    error('analysis:setNestedField', 'Field path is required.');
end

parts = cellstr(strsplit(string(field_path), '.'));
cfg = setNestedFieldRecursive(cfg, parts, value);
end

function out = setNestedFieldRecursive(out, parts, value)
part = parts{1};
if numel(parts) == 1
    out.(part) = value;
    return;
end

if ~isfield(out, part) || ~isstruct(out.(part))
    error('analysis:setNestedField', 'Missing struct field: %s', part);
end

out.(part) = setNestedFieldRecursive(out.(part), parts(2:end), value);
end
