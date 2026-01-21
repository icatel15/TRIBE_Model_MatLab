# Phase 8 — Scenario Analysis & Visualization

## Objective

Add parameter sweeps, sensitivity analysis, and visualization once Excel parity is achieved.

## Recommended Components

- `tribe.analysis.parameterSweep(base_config, param_name, values)`
- `tribe.analysis.sensitivityAnalysis(base_config)` (±10%, ±20% tornado data)
- `tribe.analysis.compareScenarios(configs)` (chipset/cooling/process comparisons)
- Plot utilities under `+tribe/+viz/` (capex breakdown, opex breakdown, revenue streams, payback curves)

## Validation

- Scenario tooling should not change core calculation outputs; it should only orchestrate runs and visualize results.

