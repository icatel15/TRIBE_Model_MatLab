% Example: compare scenarios across cooling methods.

methods = [
    "Direct-to-Chip (DTC)"
    "Single-Phase Immersion"
    "Two-Phase Immersion"
    "Rear Door Heat Exchanger"
    "Air Cooled (Reference)"
    ];

configs = cell(numel(methods), 1);
for i = 1:numel(methods)
    cfg = tribe.Config.forCoolingMethod(methods(i));
    cfg.name = "Cooling: " + methods(i);
    configs{i} = cfg;
end

comparison = tribe.analysis.compareScenarios(configs);

disp(comparison.table);
