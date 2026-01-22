function ax = plotOpexBreakdown(results)
%PLOTOPEXBREAKDOWN Plot stacked system opex components.

sopex = pickStruct(results, 'sopex', 'SystemOpex');

components = [
    sopex.total_module_opex,
    sopex.shared_overhead_gbp_per_yr,
    sopex.heat_rejection_opex_gbp_per_yr,
    sopex.augmentation_pump_electricity_gbp_per_yr
    ];
labels = [
    "Modules",
    "Shared overhead",
    "Heat rejection",
    "Hydraulic aug"
    ];

ax = gca;
bar(ax, 1, components, 'stacked');
ax.XTick = 1;
ax.XTickLabel = "System";
ylabel(ax, 'GBP per year');
title(ax, 'System Opex Breakdown');
legend(ax, labels, 'Location', 'eastoutside');
grid(ax, 'on');
end

function out = pickStruct(results, primary, fallback)
if isstruct(results)
    if isfield(results, primary)
        out = results.(primary);
    elseif isfield(results, fallback)
        out = results.(fallback);
    else
        out = [];
    end
else
    out = [];
end

if isempty(out)
    error('viz:plotOpexBreakdown', 'Expected %s or %s in results.', primary, fallback);
end
end
