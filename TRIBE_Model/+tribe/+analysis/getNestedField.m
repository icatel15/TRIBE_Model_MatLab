function value = getNestedField(cfg, field_path)
%GETNESTEDFIELD Return a nested field from a struct using dot notation.

if nargin < 2 || isempty(field_path)
    error('analysis:getNestedField', 'Field path is required.');
end

parts = cellstr(strsplit(string(field_path), '.'));
value = cfg;
for i = 1:numel(parts)
    part = parts{i};
    if ~isfield(value, part)
        error('analysis:getNestedField', 'Missing field path: %s', field_path);
    end
    value = value.(part);
end
end
