% Example: run sensitivity analysis and plot tornado chart.

sensitivity = tribe.analysis.sensitivityAnalysis([]);

disp(sensitivity.tornado.simple_payback_years);

figure('Name', 'Sensitivity - Payback');
tribe.viz.plotSensitivity(sensitivity, "simple_payback_years");
