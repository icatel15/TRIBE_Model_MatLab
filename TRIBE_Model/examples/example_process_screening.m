% Example: screen different buyer processes.

processes = [
    "Pasteurisation - Medium"
    "District heating - Medium"
    "Swimming pool - Large"
    "Textile drying - Medium"
    ];

configs = cell(numel(processes), 1);
for i = 1:numel(processes)
    cfg = tribe.Config.forProcess(processes(i));
    cfg.name = "Process: " + processes(i);
    configs{i} = cfg;
end

comparison = tribe.analysis.compareScenarios(configs);

disp(comparison.table);
