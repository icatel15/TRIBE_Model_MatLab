function ax = plotRevenueStreams(results)
%PLOTREVENUESTREAMS Plot compute vs heat revenue streams.

spl = pickStruct(results, 'spl', 'SystemPL');

components = [
    spl.total_compute_revenue_gbp_per_yr,
    spl.heat_revenue_gbp_per_yr
    ];
labels = [
    "Compute",
    "Heat"
    ];

ax = gca;
bar(ax, 1, components, 'stacked');
ax.XTick = 1;
ax.XTickLabel = "Annual revenue";
ylabel(ax, 'GBP per year');
title(ax, 'Revenue Streams');
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
    error('viz:plotRevenueStreams', 'Expected %s or %s in results.', primary, fallback);
end
end
