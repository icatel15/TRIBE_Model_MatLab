function style = style_constants()
%STYLE_CONSTANTS Return UI styling constants for TribeFrontEnd.
% Provides consistent colors, fonts, and spacing for the application.

style = struct();

%% Colors - TRIBE brand palette
style.colors = struct();

% Primary colors
style.colors.primary = [0.2 0.4 0.8];          % Blue - primary actions
style.colors.primary_light = [0.4 0.6 0.9];    % Light blue - hover states
style.colors.primary_dark = [0.1 0.2 0.5];     % Dark blue - active states

% Secondary colors
style.colors.secondary = [0.2 0.7 0.5];        % Green - success/positive
style.colors.secondary_light = [0.4 0.8 0.6];  % Light green
style.colors.warning = [0.9 0.6 0.2];          % Orange - warnings
style.colors.error = [0.8 0.2 0.2];            % Red - errors

% Neutral colors
style.colors.background = [0.95 0.95 0.97];    % Light gray background
style.colors.panel = [1 1 1];                  % White panel background
style.colors.border = [0.8 0.8 0.85];          % Border color
style.colors.text = [0.1 0.1 0.15];            % Primary text
style.colors.text_secondary = [0.5 0.5 0.55];  % Secondary text
style.colors.text_muted = [0.7 0.7 0.75];      % Muted text

%% Chart colors
style.chart = struct();

% Bar chart colors (for breakdowns)
style.chart.capex = [
    0.3 0.5 0.8   % Module capex
    0.4 0.6 0.9   % Infrastructure
    0.5 0.7 0.95  % Integration
    0.8 0.5 0.3   % Heat rejection
    0.7 0.4 0.6   % Augmentation
];

style.chart.opex = [
    0.2 0.6 0.4   % Module opex
    0.3 0.7 0.5   % Overhead
    0.8 0.4 0.3   % Heat rejection
    0.6 0.5 0.7   % Augmentation
];

style.chart.revenue = [
    0.2 0.5 0.8   % Compute revenue
    0.3 0.7 0.4   % Heat revenue
];

% Line chart colors
style.chart.line_primary = [0.2 0.4 0.8];
style.chart.line_secondary = [0.3 0.7 0.4];
style.chart.line_reference = [0.6 0.6 0.65];

% Heatmap colormap
style.chart.heatmap_low = [0.2 0.6 0.9];   % Blue (good payback)
style.chart.heatmap_mid = [0.9 0.9 0.7];   % Yellow
style.chart.heatmap_high = [0.9 0.3 0.2];  % Red (long payback)

%% Fonts
style.fonts = struct();
style.fonts.family = 'Arial';
style.fonts.size_title = 16;
style.fonts.size_heading = 14;
style.fonts.size_label = 12;
style.fonts.size_body = 11;
style.fonts.size_small = 10;
style.fonts.weight_bold = 'bold';
style.fonts.weight_normal = 'normal';

%% Spacing
style.spacing = struct();
style.spacing.panel_padding = 15;
style.spacing.component_gap = 10;
style.spacing.section_gap = 20;
style.spacing.tile_gap = 8;

%% Sizes
style.sizes = struct();
style.sizes.button_height = 30;
style.sizes.input_height = 25;
style.sizes.tile_width = 150;
style.sizes.tile_height = 80;
style.sizes.left_panel_width = 350;
style.sizes.app_width = 1400;
style.sizes.app_height = 900;

%% KPI Tile styling
style.tiles = struct();
style.tiles.good = [0.85 0.95 0.85];    % Light green - good metrics
style.tiles.warning = [1 0.95 0.85];    % Light orange - warning
style.tiles.bad = [1 0.9 0.9];          % Light red - poor metrics
style.tiles.neutral = [0.95 0.95 0.97]; % Light gray - neutral

%% Status colors
style.status = struct();
style.status.ready = [0.2 0.7 0.3];     % Green
style.status.running = [0.9 0.6 0.1];   % Orange
style.status.error = [0.8 0.2 0.2];     % Red
style.status.idle = [0.5 0.5 0.55];     % Gray

end
