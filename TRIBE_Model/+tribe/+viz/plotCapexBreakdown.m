function ax = plotCapexBreakdown(results)
%PLOTCAPEXBREAKDOWN Plot stacked system capex components.

scapex = pickStruct(results, 'scapex', 'SystemCapex');
heat_rejection = getField(scapex, 'heat_rejection_capex__b44', 'heat_rejection_capex');

components = [
    scapex.total_module_capex,
    scapex.shared_infrastructure_gbp,
    scapex.integration_commissioning,
    heat_rejection,
    scapex.hydraulic_augmentation_capex
    ];
labels = [
    "Modules",
    "Shared infra",
    "Integration",
    "Heat rejection",
    "Hydraulic aug"
    ];

ax = gca;
bar(ax, 1, components, 'stacked');
ax.XTick = 1;
ax.XTickLabel = "System";
ylabel(ax, 'GBP');
title(ax, 'System Capex Breakdown');
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
    error('viz:plotCapexBreakdown', 'Expected %s or %s in results.', primary, fallback);
end
end

function value = getField(data, primary, fallback)
if isfield(data, primary)
    value = data.(primary);
elseif isfield(data, fallback)
    value = data.(fallback);
else
    value = 0;
end
end
