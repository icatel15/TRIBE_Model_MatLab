function bounds = getOptimizableBounds()
%GETOPTIMIZABLEBOUNDS Return bounds for continuous optimization parameters.
%
% Returns struct array with fields:
%   .path     - Config path (e.g., 'rack_profile.module_it_capacity_target_kw')
%   .paths    - Optional cell array of config paths to set together
%   .lower    - Lower bound
%   .upper    - Upper bound
%   .default  - Default value
%   .label    - Human-readable label
%
% Note: Market-constrained parameters (electricity rate, heat prices, compute
% rate, utilization) are fixed to rational defaults in twoStageOptimizer.m
% rather than optimized. Only true design variables are included here.

bounds = struct('path', {}, 'paths', {}, 'lower', {}, 'upper', {}, 'default', {}, 'label', {});

% System sizing - true design variable
bounds(end+1) = struct('path', 'rack_profile.module_it_capacity_target_kw', ...
    'paths', {{}}, 'lower', 100, 'upper', 500, 'default', 250, ...
    'label', 'Module IT Capacity (kW)');

end
