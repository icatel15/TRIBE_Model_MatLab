# Phase 2 — Reference Data & Lookup Tables

## Scope

- Implement `11. Reference Data` and `12. Process Library` sheets as MATLAB data modules.

## Dependencies

- None (Phase 2 is the base layer for all calculations).

## Data To Extract (Exact Ranges)

### 11. Reference Data

- Heat rejection infrastructure table: `11. Reference Data!A10:E12`
- Rejection capacity thresholds: `11. Reference Data!B15:B16`
- Cooling method characteristics: `11. Reference Data!A23:E27`
- Chipset specifications: `11. Reference Data!A34:E38`
- Heat pump efficiency params: `11. Reference Data!B110:B112`
- Module hardware capex rates (line items): `11. Reference Data!A71:B105`
- Source loop ΔT by cooling method (used by Module Flow): `11. Reference Data!E23:E27`
- Hydraulic augmentation rates: `11. Reference Data!A120:B124`

### 12. Process Library

- Process table (42 rows): `12. Process Library!A4:J45`
- Dropdown key used throughout: column `G` ("Dropdown Name")

## MATLAB API Targets

- `tribe.data.ReferenceData()` → struct containing all the tables above.
- `tribe.data.ProcessLibrary.getProcess(process_id)` → struct with fields:
  - `name`, `size_category`, `required_temp_c`, `heat_demand_kwth`, `operating_hours_per_year`, `delta_t_c`, `notes`, `source`, `source_url`

## Formula Transcription List

| Sheet!Cell | Label | Excel formula | MATLAB transcription | Notes |
|---|---|---|---|---|
| `11. Reference Data!B47` | 11. Reference Data B47 | `=B44-A47` | `ref.target_delivery_temp_c-A47;` |  |
| `11. Reference Data!C47` | 11. Reference Data C47 | `=ROUND(B110*(B44+273.15)/B47,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B47,1);` |  |
| `11. Reference Data!D47` | 11. Reference Data D47 | `=ROUND(1/C47,3)` | `round(1/C47,3);` |  |
| `11. Reference Data!B48` | 11. Reference Data B48 | `=B44-A48` | `ref.target_delivery_temp_c-A48;` |  |
| `11. Reference Data!C48` | 11. Reference Data C48 | `=ROUND(B110*(B44+273.15)/B48,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B48,1);` |  |
| `11. Reference Data!D48` | 11. Reference Data D48 | `=ROUND(1/C48,3)` | `round(1/C48,3);` |  |
| `11. Reference Data!B49` | 11. Reference Data B49 | `=B44-A49` | `ref.target_delivery_temp_c-A49;` |  |
| `11. Reference Data!C49` | 11. Reference Data C49 | `=ROUND(B110*(B44+273.15)/B49,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B49,1);` |  |
| `11. Reference Data!D49` | 11. Reference Data D49 | `=ROUND(1/C49,3)` | `round(1/C49,3);` |  |
| `11. Reference Data!B50` | 11. Reference Data B50 | `=B44-A50` | `ref.target_delivery_temp_c-A50;` |  |
| `11. Reference Data!C50` | 11. Reference Data C50 | `=ROUND(B110*(B44+273.15)/B50,1)` | `round(ref.carnot_efficiency_factor*(ref.target_delivery_temp_c+273.15)/B50,1);` |  |
| `11. Reference Data!D50` | 11. Reference Data D50 | `=ROUND(1/C50,3)` | `round(1/C50,3);` |  |

## Validation Criteria

- Every constant in the ranges above matches Excel exactly (string match for text, exact numeric match for rates).
- `getProcess()` returns correct row for at least 5 spot-check IDs including the default `Pasteurisation - Medium`.

