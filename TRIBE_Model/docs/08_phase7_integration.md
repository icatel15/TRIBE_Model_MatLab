# Phase 7 — Integration, Validation & Testing

## Objective

Provide a single model entry point, configuration, and a validation suite that compares MATLAB results to the Excel workbook.

## Scope

- Create `+tribe/Config.m` containing defaults matching `0. Rack Profile`, `1. Module Criteria`, `3. Module Opex`, `5. Buyer Profile`, and system-level % uplifts.
- Create `+tribe/Model.m` (or `main.m`) to run the full chain in the correct order.
- Create tests in `tests/` to validate each calc module independently and end-to-end.

## Excel Parity Strategy

- Prefer validating **numeric cells** (ignore explanatory text columns).
- For cells that are display-only (e.g., ✓/✗ strings), either validate exact strings or validate their underlying numeric conditions.
- Build a cell-map from `A1_formula_reference.md` to expected outputs for the default configuration.

## Suggested Validation Harness

- A script `validation/validate_against_excel.m` that:
  1) loads the Excel workbook (or a frozen JSON of key cells),
  2) runs the MATLAB model with matching inputs,
  3) compares every formula cell with tolerances by unit (e.g., currency rounding).

