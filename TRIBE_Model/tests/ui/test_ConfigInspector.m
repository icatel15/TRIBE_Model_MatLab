function tests = test_ConfigInspector
%TEST_CONFIGINSPECTOR Unit tests for tribe.ui.ConfigInspector
    tests = functiontests(localfunctions);
end

function test_getSchema_returns_struct_array(testCase)
    schema = tribe.ui.ConfigInspector.getSchema();
    verifyClass(testCase, schema, 'struct');
    verifyGreaterThan(testCase, numel(schema), 0);
end

function test_getSchema_contains_all_sections(testCase)
    schema = tribe.ui.ConfigInspector.getSchema();
    sections = unique({schema.section});
    expected = {'rack_profile', 'module_criteria', 'module_opex', 'buyer_profile', 'system'};
    for i = 1:numel(expected)
        verifyTrue(testCase, ismember(expected{i}, sections), ...
            sprintf('Missing section: %s', expected{i}));
    end
end

function test_getSchema_fields_have_required_properties(testCase)
    schema = tribe.ui.ConfigInspector.getSchema();
    requiredFields = {'path', 'type', 'default', 'label', 'section'};
    for i = 1:numel(requiredFields)
        verifyTrue(testCase, isfield(schema, requiredFields{i}), ...
            sprintf('Missing field: %s', requiredFields{i}));
    end
end

function test_getChoices_chipset_returns_valid_options(testCase)
    choices = tribe.ui.ConfigInspector.getChoices('rack_profile.chipset');
    verifyTrue(testCase, ismember("NVIDIA H100", choices));
    verifyTrue(testCase, ismember("AMD MI300X", choices));
    verifyGreaterThanOrEqual(testCase, numel(choices), 5);
end

function test_getChoices_cooling_method_returns_valid_options(testCase)
    choices = tribe.ui.ConfigInspector.getChoices('rack_profile.cooling_method');
    verifyTrue(testCase, ismember("Direct-to-Chip (DTC)", choices));
    verifyGreaterThanOrEqual(testCase, numel(choices), 5);
end

function test_getChoices_process_returns_valid_options(testCase)
    choices = tribe.ui.ConfigInspector.getChoices('buyer_profile.process_id');
    verifyTrue(testCase, ismember("Pasteurisation - Medium", choices));
    verifyGreaterThanOrEqual(testCase, numel(choices), 40);
end

function test_getFieldType_numeric_fields(testCase)
    ftype = tribe.ui.ConfigInspector.getFieldType('rack_profile.module_it_capacity_target_kw');
    verifyEqual(testCase, ftype, 'numeric');
end

function test_getFieldType_enum_fields(testCase)
    ftype = tribe.ui.ConfigInspector.getFieldType('rack_profile.chipset');
    verifyEqual(testCase, ftype, 'enum');
end

function test_getFieldType_fraction_fields(testCase)
    ftype = tribe.ui.ConfigInspector.getFieldType('module_criteria.target_utilisation_rate_pct');
    verifyEqual(testCase, ftype, 'fraction');
end

function test_getFieldType_binary_fields(testCase)
    ftype = tribe.ui.ConfigInspector.getFieldType('module_criteria.heat_pump_enabled');
    verifyEqual(testCase, ftype, 'binary');
end

function test_getFieldMeta_returns_struct(testCase)
    meta = tribe.ui.ConfigInspector.getFieldMeta('rack_profile.chipset');
    verifyClass(testCase, meta, 'struct');
    verifyEqual(testCase, meta.path, 'rack_profile.chipset');
end

function test_getSections_returns_five_sections(testCase)
    sections = tribe.ui.ConfigInspector.getSections();
    verifyEqual(testCase, numel(sections), 5);
end

function test_getFieldsForSection_returns_fields(testCase)
    fields = tribe.ui.ConfigInspector.getFieldsForSection('rack_profile');
    verifyGreaterThan(testCase, numel(fields), 0);
end

function test_getSweepableParameters_returns_numeric_paths(testCase)
    params = tribe.ui.ConfigInspector.getSweepableParameters();
    verifyClass(testCase, params, 'string');
    verifyGreaterThan(testCase, numel(params), 10);

    % Verify all returned paths are numeric types
    for i = 1:numel(params)
        ftype = tribe.ui.ConfigInspector.getFieldType(params(i));
        verifyTrue(testCase, ismember(ftype, {'numeric', 'fraction'}), ...
            sprintf('Non-numeric parameter: %s (%s)', params(i), ftype));
    end
end
