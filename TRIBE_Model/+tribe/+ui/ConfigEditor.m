classdef ConfigEditor < handle
    %CONFIGEDITOR Manages config state with validation and undo support.
    % Provides methods to get/set config fields, validate, and persist.

    properties
        config      % Current config struct
        isDirty     % Flag indicating unsaved changes
    end

    properties (Access = private)
        history     % Undo stack (cell array of configs)
        maxHistory  % Maximum history entries
    end

    methods
        function obj = ConfigEditor(initial_config)
            %CONFIGEDITOR Constructor.
            % ConfigEditor() - start with defaults
            % ConfigEditor(cfg) - start with provided config
            obj.maxHistory = 50;
            obj.history = {};

            if nargin < 1 || isempty(initial_config)
                obj.config = tribe.Config.default();
            else
                obj.config = tribe.Config.apply(initial_config);
            end
            obj.isDirty = false;
        end

        function setField(obj, field_path, value)
            %SETFIELD Set a config field by path.
            % setField(obj, 'rack_profile.chipset', 'NVIDIA H200')
            obj.pushHistory();
            obj.config = tribe.analysis.setNestedField(obj.config, field_path, value);
            obj.config = tribe.Config.apply(obj.config);  % Normalize
            obj.isDirty = true;
        end

        function value = getField(obj, field_path)
            %GETFIELD Get a config field by path.
            % value = getField(obj, 'rack_profile.chipset')
            value = tribe.analysis.getNestedField(obj.config, field_path);
        end

        function [valid, errors] = validate(obj)
            %VALIDATE Validate the current config.
            % Returns: [valid (bool), errors (cell array of messages)]
            errors = {};
            valid = true;

            try
                tribe.Config.validate(obj.config);
            catch ME
                valid = false;
                errors{end+1} = ME.message;
            end
        end

        function cfg = getConfig(obj)
            %GETCONFIG Get the current config struct.
            cfg = obj.config;
        end

        function reset(obj)
            %RESET Reset config to defaults.
            obj.pushHistory();
            obj.config = tribe.Config.default();
            obj.isDirty = false;
        end

        function success = undo(obj)
            %UNDO Restore previous config state.
            % Returns true if undo was successful.
            if isempty(obj.history)
                success = false;
                return;
            end
            obj.config = obj.history{end};
            obj.history(end) = [];
            obj.isDirty = true;
            success = true;
        end

        function canUndo = hasUndoHistory(obj)
            %HASUNDOHISTORY Check if undo is available.
            canUndo = ~isempty(obj.history);
        end

        function loadFromStruct(obj, cfg)
            %LOADFROMSTRUCT Load config from a struct.
            obj.pushHistory();
            obj.config = tribe.Config.apply(cfg);
            obj.isDirty = false;
        end

        function loadFromFile(obj, filepath)
            %LOADFROMFILE Load config from file (JSON or MAT).
            [~, ~, ext] = fileparts(filepath);

            switch lower(ext)
                case '.json'
                    fid = fopen(filepath, 'r');
                    if fid < 0
                        error('ConfigEditor:FileError', 'Cannot open file: %s', filepath);
                    end
                    raw = fread(fid, '*char')';
                    fclose(fid);
                    cfg = jsondecode(raw);
                    obj.loadFromStruct(cfg);

                case '.mat'
                    data = load(filepath);
                    if isfield(data, 'config')
                        obj.loadFromStruct(data.config);
                    else
                        % Try to use the first struct field
                        fields = fieldnames(data);
                        if ~isempty(fields) && isstruct(data.(fields{1}))
                            obj.loadFromStruct(data.(fields{1}));
                        else
                            error('ConfigEditor:FileError', 'MAT file must contain a config struct.');
                        end
                    end

                otherwise
                    error('ConfigEditor:FileError', 'Unsupported file format: %s', ext);
            end
        end

        function saveToFile(obj, filepath, format)
            %SAVETOFILE Save config to file.
            % saveToFile(obj, filepath) - auto-detect format from extension
            % saveToFile(obj, filepath, 'json') - force JSON
            % saveToFile(obj, filepath, 'mat') - force MAT

            if nargin < 3
                [~, ~, ext] = fileparts(filepath);
                format = lower(strrep(ext, '.', ''));
            end

            switch lower(format)
                case 'json'
                    jsonStr = jsonencode(obj.config, 'PrettyPrint', true);
                    fid = fopen(filepath, 'w');
                    if fid < 0
                        error('ConfigEditor:FileError', 'Cannot write to file: %s', filepath);
                    end
                    fprintf(fid, '%s', jsonStr);
                    fclose(fid);

                case 'mat'
                    config = obj.config; %#ok<PROPLC>
                    save(filepath, 'config');

                otherwise
                    error('ConfigEditor:FileError', 'Unsupported format: %s', format);
            end

            obj.isDirty = false;
        end

        function applyPreset(obj, preset_type, preset_value)
            %APPLYPRESET Apply a configuration preset.
            % applyPreset(obj, 'chipset', 'NVIDIA H200')
            % applyPreset(obj, 'cooling_method', 'Single-Phase Immersion')
            % applyPreset(obj, 'process', 'District heating - Medium')
            obj.pushHistory();

            switch lower(preset_type)
                case 'chipset'
                    obj.config.rack_profile.chipset = string(preset_value);
                case 'cooling_method'
                    obj.config.rack_profile.cooling_method = string(preset_value);
                case 'process'
                    obj.config.buyer_profile.process_id = string(preset_value);
                otherwise
                    error('ConfigEditor:InvalidPreset', 'Unknown preset type: %s', preset_type);
            end

            obj.config = tribe.Config.apply(obj.config);
            obj.isDirty = true;
        end

        function setHeatPump(obj, enabled, output_temp_c)
            %SETHEATPUMP Configure heat pump settings.
            obj.pushHistory();
            obj.config.module_criteria.heat_pump_enabled = double(enabled);
            if nargin > 2 && ~isempty(output_temp_c)
                obj.config.module_criteria.heat_pump_output_temperature_c = output_temp_c;
            end
            obj.config = tribe.Config.apply(obj.config);
            obj.isDirty = true;
        end

        function summary = getSummary(obj)
            %GETSUMMARY Get a human-readable summary of current config.
            cfg = obj.config;
            summary = struct();
            summary.chipset = cfg.rack_profile.chipset;
            summary.cooling_method = cfg.rack_profile.cooling_method;
            summary.process = cfg.buyer_profile.process_id;
            summary.it_capacity_kw = cfg.rack_profile.module_it_capacity_target_kw;
            summary.heat_pump_enabled = cfg.module_criteria.heat_pump_enabled == 1;
            summary.compute_rate = cfg.module_criteria.compute_rate_gbp_per_kw_per_month;
        end
    end

    methods (Access = private)
        function pushHistory(obj)
            %PUSHHISTORY Save current config to history stack.
            obj.history{end+1} = obj.config;
            if numel(obj.history) > obj.maxHistory
                obj.history(1) = [];  % Remove oldest
            end
        end
    end
end
