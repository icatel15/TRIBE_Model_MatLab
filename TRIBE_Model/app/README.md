# TRIBE Model Front End

An interactive MATLAB GUI for the TRIBE thermal recovery model, providing configuration editing, model execution, output visualization, and sensitivity analysis.

## Quick Start

### Running the App

1. Open MATLAB R2021a or later
2. Navigate to the TRIBE_Model directory
3. Add the project to the path:
   ```matlab
   addpath(genpath('TRIBE_Model'))
   ```
4. Launch the application:
   ```matlab
   app = TribeFrontEnd();
   ```

### Basic Workflow

1. **Configure**: Use the left panel to set model parameters
   - **Guided Mode**: Key parameters with sensible defaults
   - **Advanced Mode**: Full access to all configuration fields

2. **Run**: Click "RUN MODEL" to execute the simulation

3. **Analyze**: View results in the right panel tabs
   - **Dashboard**: KPI tiles and summary charts
   - **Details**: Full field-by-field breakdown
   - **Sensitivity**: Parameter sweep analysis
   - **Scenarios**: Save and compare configurations

## Required Toolboxes

- **MATLAB** (R2021a or later) - base installation only
- No additional toolboxes required for core functionality

Optional toolboxes for extended features:
- Statistics and Machine Learning Toolbox (for advanced statistical analysis)

## Application Layout

```
┌──────────────────┬─────────────────────────────────────┐
│  Configuration   │           Results                   │
│                  │                                     │
│  [Guided Mode]   │  ┌─────────────────────────────────┐│
│  • Chipset       │  │ Dashboard │ Details │ Sens │ ...││
│  • Cooling       │  ├─────────────────────────────────┤│
│  • Process       │  │                                 ││
│  • IT Capacity   │  │  KPI Tiles: Payback, ROI, etc.  ││
│  • Compute Rate  │  │                                 ││
│  • Heat Pump     │  │  Charts: Capex, Opex, Revenue   ││
│                  │  │                                 ││
│  [Advanced Mode] │  └─────────────────────────────────┘│
│  • Full config   │                                     │
│    tree view     │                                     │
│                  │                                     │
│  [RUN MODEL]     │                                     │
│  [Reset] [Save]  │                                     │
└──────────────────┴─────────────────────────────────────┘
```

## Features

### Configuration Editing

- **Guided Mode**: Curated set of key parameters with dropdowns for categorical selections
- **Advanced Mode**: Tree view of all 26 configuration parameters across 5 sections
- **Presets**: Quick selection of chipsets, cooling methods, and industrial processes
- **Validation**: Real-time validation of input values

### Model Execution

- Single-click model execution with progress indication
- Error handling with user-friendly messages
- Configuration snapshot preserved with each run

### Output Visualization

**Dashboard Tab**:
- 6 KPI tiles: Payback, ROI, Margin, Capex, Profit, Modules
- 4 charts: Capex Breakdown, Opex Breakdown, Revenue Streams, Payback Curve

**Details Tab**:
- Select any output section (System P&L, System Flow, etc.)
- View all fields with values and types
- Formatted values with appropriate units

### Sensitivity Analysis

**Tornado Chart**: Shows which parameters have the greatest impact on key metrics

**1D Parameter Sweep**: Vary a single parameter across a range and plot the effect on any output metric

**2D Heatmap**: Vary two parameters simultaneously and visualize the combined effect as a color map

Supported metrics:
- Simple Payback (years)
- Unlevered ROI (%)
- Gross Margin (%)

### Scenario Management

- Save current configuration and results as named scenarios
- Load and restore previous scenarios
- Compare multiple scenarios side-by-side
- Delete unwanted scenarios

### Export Options

**Configuration**:
- JSON format (human-readable, version control friendly)
- MAT format (preserves MATLAB types exactly)

**Results**:
- CSV format (for Excel/analysis)
- MAT format (for MATLAB)
- JSON format (for other tools)

**Charts**:
- PNG format (high-resolution images)

## Helper Classes

The application uses several helper classes in the `+tribe/+ui/` package:

| Class | Purpose |
|-------|---------|
| `ConfigInspector` | Introspect config schema, enumerate fields, get dropdown choices |
| `ConfigEditor` | Manage config state with validation and undo support |
| `ModelRunner` | Execute model with exception handling, export results |
| `SensitivityRunner` | Run sensitivity analysis and parameter sweeps |
| `OutputCatalog` | Provide field metadata (units, labels, descriptions) |

### Programmatic Usage

The helper classes can be used independently of the GUI:

```matlab
% Create and modify configuration
editor = tribe.ui.ConfigEditor();
editor.setField('rack_profile.chipset', 'NVIDIA H200');
editor.setField('buyer_profile.process_id', 'District heating - Medium');

% Run model
runner = tribe.ui.ModelRunner();
[results, success, errMsg] = runner.run(editor.getConfig());

% Get KPIs
kpis = runner.getKPIs();
fprintf('Payback: %.1f years\n', kpis.simple_payback_years);

% Run sensitivity analysis
sensRunner = tribe.ui.SensitivityRunner(editor.getConfig());
sensitivity = sensRunner.runSensitivity();

% Export results
runner.exportResults('results.csv', 'csv');
```

## Extending the Application

### Adding New Config Fields

1. Add the field to `tribe.Config.default()` in `+tribe/Config.m`
2. Add validation in `tribe.Config.validate()`
3. The field will automatically appear in Advanced Mode
4. For Guided Mode, update the `createGuidedPanel()` method in `TribeFrontEnd.m`

### Adding New Output Fields

1. New output fields from the model will automatically appear in the Details tab
2. To add as a KPI tile, update `tribe.ui.OutputCatalog.getKPIFields()`
3. To add formatting, add an entry in `tribe.ui.OutputCatalog.getCatalog()`

### Adding New Industrial Processes

Add entries to `tribe.data.ProcessLibrary.build_()` in `+tribe/+data/ProcessLibrary.m`. They will automatically appear in the Process dropdown.

## Running Tests

```matlab
% Run all UI tests
results = runtests('tests/ui');

% Run specific test file
results = runtests('tests/ui/test_ConfigEditor');

% Display results
disp(results);
```

## Troubleshooting

### App doesn't launch
- Ensure MATLAB R2021a or later
- Verify the TRIBE_Model directory is on the path
- Check for syntax errors: `checkcode('+tribe/+ui/ConfigInspector.m')`

### Model run fails
- Check the error message in the status bar
- Validate configuration: `[valid, errors] = editor.validate()`
- Review config values in Advanced Mode

### Charts don't update
- Ensure a successful model run has completed
- Check that `app.LastResults` is populated
- Try clicking RUN MODEL again

## Version History

- **v1.0**: Initial release with full configuration editing, visualization, and sensitivity analysis

## License

This application is part of the TRIBE Model project.
