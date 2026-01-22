% Example: basic model run with a few summary plots.

results = tribe.Model.runWithConfig([]);

disp(results.spl);

figure('Name', 'Capex Breakdown');
tribe.viz.plotCapexBreakdown(results);

figure('Name', 'Revenue Streams');
tribe.viz.plotRevenueStreams(results);

figure('Name', 'Payback Curve');
tribe.viz.plotPaybackCurve(results);
