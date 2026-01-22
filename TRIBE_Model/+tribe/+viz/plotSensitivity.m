function ax = plotSensitivity(sensitivity, metric)
%PLOTSENSITIVITY Plot a tornado chart for the selected metric.

if nargin < 2 || isempty(metric)
    metric = "simple_payback_years";
end
metric = string(metric);

if ~isstruct(sensitivity) || ~isfield(sensitivity, 'tornado')
    error('viz:plotSensitivity', 'Sensitivity input must include tornado data.');
end
if ~isfield(sensitivity.tornado, metric)
    error('viz:plotSensitivity', 'Metric not found: %s', metric);
end

data = sensitivity.tornado.(metric);
impact = max(abs([data.low_delta, data.high_delta]), [], 2);
[~, order] = sort(impact, 'descend');
data = data(order, :);

low = data.low_delta;
high = data.high_delta;
labels = data.parameter_label;
if isempty(labels) || all(labels == "")
    labels = data.parameter;
end

y = 1:numel(low);
ax = gca;
barh(ax, y, high, 'FaceColor', [0.2, 0.6, 0.8], 'EdgeColor', 'none');
hold(ax, 'on');
barh(ax, y, low, 'FaceColor', [0.9, 0.4, 0.4], 'EdgeColor', 'none');
xline(ax, 0, '--k');

ax.YTick = y;
ax.YTickLabel = labels;
ax.YDir = 'reverse';

title(ax, "Sensitivity: " + formatMetricLabel(metric));
xlabel(ax, 'Change from baseline');
legend(ax, ["High", "Low"], 'Location', 'best');
grid(ax, 'on');
end

function label = formatMetricLabel(metric)
label = strrep(metric, "_", " ");
end
