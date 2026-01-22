function tests = test_ConfigEditor
%TEST_CONFIGEDITOR Unit tests for tribe.ui.ConfigEditor
    tests = functiontests(localfunctions);
end

function test_constructor_creates_default_config(testCase)
    editor = tribe.ui.ConfigEditor();
    cfg = editor.getConfig();

    verifyTrue(testCase, isstruct(cfg));
    verifyTrue(testCase, isfield(cfg, 'rack_profile'));
    verifyEqual(testCase, cfg.rack_profile.chipset, "NVIDIA H100");
end

function test_constructor_with_overrides(testCase)
    override = struct();
    override.rack_profile = struct('chipset', 'NVIDIA H200');

    editor = tribe.ui.ConfigEditor(override);
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.rack_profile.chipset, "NVIDIA H200");
end

function test_setField_updates_value(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('rack_profile.chipset', 'NVIDIA H200');
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.rack_profile.chipset, "NVIDIA H200");
end

function test_setField_marks_dirty(testCase)
    editor = tribe.ui.ConfigEditor();
    verifyFalse(testCase, editor.isDirty);

    editor.setField('rack_profile.chipset', 'NVIDIA H200');
    verifyTrue(testCase, editor.isDirty);
end

function test_getField_returns_value(testCase)
    editor = tribe.ui.ConfigEditor();
    value = editor.getField('rack_profile.module_it_capacity_target_kw');

    verifyEqual(testCase, value, 250);
end

function test_validate_returns_true_for_valid_config(testCase)
    editor = tribe.ui.ConfigEditor();
    [valid, errors] = editor.validate();

    verifyTrue(testCase, valid);
    verifyEmpty(testCase, errors);
end

function test_validate_returns_false_for_invalid_fraction(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('module_criteria.target_utilisation_rate_pct', 1.5);
    [valid, ~] = editor.validate();

    verifyFalse(testCase, valid);
end

function test_reset_restores_defaults(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('rack_profile.module_it_capacity_target_kw', 500);
    editor.reset();
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.rack_profile.module_it_capacity_target_kw, 250);
    verifyFalse(testCase, editor.isDirty);
end

function test_undo_restores_previous_state(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('rack_profile.module_it_capacity_target_kw', 300);
    editor.setField('rack_profile.module_it_capacity_target_kw', 400);

    success = editor.undo();
    cfg = editor.getConfig();

    verifyTrue(testCase, success);
    verifyEqual(testCase, cfg.rack_profile.module_it_capacity_target_kw, 300);
end

function test_undo_returns_false_when_no_history(testCase)
    editor = tribe.ui.ConfigEditor();
    success = editor.undo();

    verifyFalse(testCase, success);
end

function test_hasUndoHistory_returns_correct_state(testCase)
    editor = tribe.ui.ConfigEditor();
    verifyFalse(testCase, editor.hasUndoHistory());

    editor.setField('rack_profile.module_it_capacity_target_kw', 300);
    verifyTrue(testCase, editor.hasUndoHistory());
end

function test_loadFromStruct_updates_config(testCase)
    editor = tribe.ui.ConfigEditor();
    newCfg = tribe.Config.default();
    newCfg.rack_profile.chipset = "AMD MI300X";

    editor.loadFromStruct(newCfg);
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.rack_profile.chipset, "AMD MI300X");
end

function test_applyPreset_chipset(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.applyPreset('chipset', 'NVIDIA B200');
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.rack_profile.chipset, "NVIDIA B200");
end

function test_applyPreset_process(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.applyPreset('process', 'District heating - Large');
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.buyer_profile.process_id, "District heating - Large");
end

function test_setHeatPump_enables(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setHeatPump(true, 85);
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.module_criteria.heat_pump_enabled, 1);
    verifyEqual(testCase, cfg.module_criteria.heat_pump_output_temperature_c, 85);
end

function test_setHeatPump_disables(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setHeatPump(false);
    cfg = editor.getConfig();

    verifyEqual(testCase, cfg.module_criteria.heat_pump_enabled, 0);
end

function test_getSummary_returns_struct(testCase)
    editor = tribe.ui.ConfigEditor();
    summary = editor.getSummary();

    verifyTrue(testCase, isstruct(summary));
    verifyTrue(testCase, isfield(summary, 'chipset'));
    verifyTrue(testCase, isfield(summary, 'process'));
    verifyTrue(testCase, isfield(summary, 'heat_pump_enabled'));
end

function test_saveToFile_and_loadFromFile_json(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('rack_profile.module_it_capacity_target_kw', 333);

    tempFile = [tempname '.json'];
    cleanup = onCleanup(@() delete(tempFile));

    editor.saveToFile(tempFile);

    editor2 = tribe.ui.ConfigEditor();
    editor2.loadFromFile(tempFile);
    cfg = editor2.getConfig();

    verifyEqual(testCase, cfg.rack_profile.module_it_capacity_target_kw, 333);
end

function test_saveToFile_and_loadFromFile_mat(testCase)
    editor = tribe.ui.ConfigEditor();
    editor.setField('rack_profile.module_it_capacity_target_kw', 444);

    tempFile = [tempname '.mat'];
    cleanup = onCleanup(@() delete(tempFile));

    editor.saveToFile(tempFile);

    editor2 = tribe.ui.ConfigEditor();
    editor2.loadFromFile(tempFile);
    cfg = editor2.getConfig();

    verifyEqual(testCase, cfg.rack_profile.module_it_capacity_target_kw, 444);
end
