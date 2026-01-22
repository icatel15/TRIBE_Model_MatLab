function bounds = getOptimizableBounds()
%GETOPTIMIZABLEBOUNDS Return bounds for continuous optimization parameters.
%
% Returns struct array with fields:
%   .path    - Config path (e.g., 'module_criteria.compute_rate_gbp_per_kw_per_month')
%   .lower   - Lower bound
%   .upper   - Upper bound
%   .default - Default value
%   .label   - Human-readable label

bounds = struct('path', {}, 'lower', {}, 'upper', {}, 'default', {}, 'label', {});

% Core pricing parameters (high impact)
bounds(end+1) = struct('path', 'module_criteria.compute_rate_gbp_per_kw_per_month', ...
    'lower', 50, 'upper', 300, 'default', 150, 'label', 'Compute Rate (GBP/kW/month)');

bounds(end+1) = struct('path', 'module_criteria.target_utilisation_rate_pct', ...
    'lower', 0.5, 'upper', 0.99, 'default', 0.9, 'label', 'Utilisation Rate (%)');

% System sizing (high impact)
bounds(end+1) = struct('path', 'rack_profile.module_it_capacity_target_kw', ...
    'lower', 100, 'upper', 500, 'default', 250, 'label', 'Module IT Capacity (kW)');

% Heat pricing (medium impact)
bounds(end+1) = struct('path', 'module_criteria.base_heat_price_no_hp_gbp_per_mwh', ...
    'lower', 10, 'upper', 50, 'default', 25, 'label', 'Heat Price - No HP (GBP/MWh)');

bounds(end+1) = struct('path', 'module_criteria.premium_heat_price_with_hp_gbp_per_mwh', ...
    'lower', 20, 'upper', 80, 'default', 40, 'label', 'Heat Price - With HP (GBP/MWh)');

% Operating costs (high impact)
bounds(end+1) = struct('path', 'module_opex.electricity_rate_gbp_per_kwh', ...
    'lower', 0.10, 'upper', 0.30, 'default', 0.18, 'label', 'Electricity Rate (GBP/kWh)');

end
