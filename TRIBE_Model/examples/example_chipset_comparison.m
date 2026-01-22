% Example: compare scenarios across chipset options.

chipsets = [
    "NVIDIA H100"
    "NVIDIA H200"
    "NVIDIA B200"
    "AMD MI300X"
    "Intel Gaudi 3"
    ];

configs = cell(numel(chipsets), 1);
for i = 1:numel(chipsets)
    cfg = tribe.Config.forChipset(chipsets(i));
    cfg.name = "Chipset: " + chipsets(i);
    configs{i} = cfg;
end

comparison = tribe.analysis.compareScenarios(configs);

disp(comparison.table);
