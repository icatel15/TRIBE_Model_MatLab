function ax = plotPaybackCurve(results, horizon_years)
%PLOTPAYBACKCURVE Plot cumulative cash flow over time.

spl = pickStruct(results, 'spl', 'SystemPL');

capex = spl.total_system_capex_gbp;
annual_profit = spl.gross_profit_gbp_per_yr;

if nargin < 2 || isempty(horizon_years)
    if spl.simple_payback_years > 0
        horizon_years = max(10, ceil(spl.simple_payback_years * 1.5));
    else
        horizon_years = 10;
    end
end

years = 0:horizon_years;
cumulative_cash = -capex + years * annual_profit;

ax = gca;
plot(ax, years, cumulative_cash, 'LineWidth', 2);
hold(ax, 'on');
xline(ax, 0, ':k');
yline(ax, 0, '--k');

xlabel(ax, 'Years');
ylabel(ax, 'Cumulative cash flow (GBP)');
title(ax, 'Payback Curve');
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
    error('viz:plotPaybackCurve', 'Expected %s or %s in results.', primary, fallback);
end
end
