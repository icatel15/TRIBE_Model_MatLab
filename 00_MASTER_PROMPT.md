# TRIBE Digital Boiler Model — Excel to MATLAB Conversion

## Project Overview

You are converting a financial/engineering model for modular data centre heat recovery ("digital boilers") from Excel to MATLAB. The Excel model calculates capital expenditure, operating expenditure, thermal hydraulics, and profit/loss for systems that capture waste heat from GPU compute and sell it to industrial partners.

**Key characteristics of the source model:**
- 14 sheets, ~300 formulas total
- Deterministic, non-iterative (no circular references or solvers)
- Clear hierarchical data flow: Rack Profile → Module → Buyer Profile → System
- Mix of configuration inputs, lookup tables, and calculated outputs
- Units: GBP (£), kW/kWth, °C, m³/hr, MWh

**Attached artifact:** `Tribe_model_20.1.26.xlsx` — the authoritative source model

---

## Critical Instructions for All Phases

1. **Each phase starts with a FRESH CHAT with clean context** — do not continue from previous phase conversations
2. **Always read the phase-specific documentation file first** before writing any code
3. **Do not attempt to complete multiple phases in one session**
4. **Validate outputs against Excel values before marking phase complete**
5. **Use consistent naming conventions throughout** (defined in Phase 1 output)

---

## Phase Structure

| Phase | Deliverable | Estimated Complexity |
|-------|-------------|---------------------|
| 1 | Documentation & Architecture Design | Medium |
| 2 | Reference Data & Lookup Tables | Low |
| 3 | Rack Profile Module | Medium |
| 4 | Module Criteria, Capex, Opex, Flow | Medium-High |
| 5 | Buyer Profile & Process Library | High |
| 6 | System Capex, Opex, Flow, P&L | Medium |
| 7 | Integration, Validation & Testing | Medium |
| 8 | Scenario Analysis & Visualization | Low-Medium |

---

# PHASE 1: Documentation & Architecture Design

## Objective
Create comprehensive documentation that will guide all subsequent phases. This phase produces NO code — only markdown documentation files that subsequent agents will consume.

## Instructions

### Step 1: Analyze the Excel Model Structure

Read the Excel file and document:

1. **Sheet-by-sheet inventory**
   - For each sheet: purpose, input cells (yellow), output cells, formula cells
   - Identify which sheets are pure reference data vs. calculation sheets

2. **Data flow mapping**
   - Document every cross-sheet reference
   - Create a dependency graph showing which sheets feed which
   - Identify the critical path from inputs to final P&L outputs

3. **Formula catalog**
   - Extract every unique formula pattern
   - Group by type: simple arithmetic, conditionals, lookups, aggregations
   - Flag any formulas requiring special handling in MATLAB

### Step 2: Define MATLAB Architecture

Document the chosen architecture:

1. **File structure**
```
TRIBE_Model/
├── +tribe/                    % Package namespace
│   ├── +data/                 % Reference data modules
│   ├── +calc/                 % Calculation modules
│   ├── +util/                 % Utility functions
│   └── Config.m               % Configuration class
├── tests/                     % Unit tests
├── examples/                  % Usage examples
├── validation/                % Excel comparison scripts
└── main.m                     % Entry point
```

2. **Naming conventions**
   - Variable names: how Excel cell references map to MATLAB variables
   - Function names: one function per logical "sheet" or calculation block
   - Struct field names: consistent with Excel row labels (snake_case)

3. **Data structures**
   - Define the main structs: `RackProfile`, `ModuleCriteria`, `ModuleCapex`, `ModuleOpex`, `ModuleFlow`, `BuyerProfile`, `SystemCapex`, `SystemOpex`, `SystemFlow`, `SystemPL`
   - Specify field names, types, units for each

### Step 3: Create Phase-Specific Guides

Create a separate markdown file for each subsequent phase containing:

1. **Scope** — exactly which Excel sheets/cells to implement
2. **Dependencies** — which prior phase outputs are required
3. **Input specification** — struct fields expected as input
4. **Output specification** — struct fields to produce
5. **Formula transcription list** — every formula to implement, with:
   - Excel cell reference
   - Excel formula
   - Equivalent MATLAB expression
   - Any edge cases or guards needed
6. **Validation criteria** — specific Excel values to test against

## Deliverables for Phase 1

Create these files in `TRIBE_Model/docs/`:

```
docs/
├── 01_model_overview.md           % Sheet inventory, data flow, dependency graph
├── 02_architecture.md             % File structure, naming conventions, data structures
├── 03_phase2_reference_data.md    % Guide for Phase 2
├── 04_phase3_rack_profile.md      % Guide for Phase 3
├── 05_phase4_module_calcs.md      % Guide for Phase 4
├── 06_phase5_buyer_profile.md     % Guide for Phase 5
├── 07_phase6_system_calcs.md      % Guide for Phase 6
├── 08_phase7_integration.md       % Guide for Phase 7
├── 09_phase8_scenarios.md         % Guide for Phase 8
└── A1_formula_reference.md        % Complete formula catalog
```

## Completion Criteria for Phase 1

- [ ] All 10 documentation files created
- [ ] Every formula in the Excel model appears in the formula reference
- [ ] Data flow diagram shows all cross-sheet dependencies
- [ ] Each phase guide contains complete formula transcription lists
- [ ] Struct definitions include all fields with types and units

---

# PHASE 2: Reference Data & Lookup Tables

## Objective
Implement all static reference data and lookup tables from `11. Reference Data` and `12. Process Library` sheets.

## Instructions

**START BY READING:** `docs/03_phase2_reference_data.md`

### Implementation Requirements

1. **Create `+tribe/+data/ReferenceData.m`**
   - Static class or function returning structs
   - Heat rejection infrastructure (capacity thresholds, capex/opex rates)
   - Cooling method characteristics (capture rates, temps, premiums, ΔT)
   - Chipset specifications (TDP, chips/server, T_junction)
   - Heat pump parameters (Carnot efficiency, COP bounds)
   - Module hardware capex rates (all line items from rows 71-105)
   - Hydraulic augmentation rates

2. **Create `+tribe/+data/ProcessLibrary.m`**
   - Load/define all 42 industrial processes
   - Fields: name, size_category, required_temp, heat_demand, operating_hours, delta_t, notes
   - Implement lookup function: `getProcess(process_id)` → process struct

3. **Create `+tribe/+data/CoolingMethods.m`**
   - Enum or struct defining: DTC, SinglePhaseImmersion, TwoPhaseImmersion, RDHX, AirCooled
   - Associated properties for each method

4. **Create `+tribe/+data/Chipsets.m`**
   - Enum or struct defining: H100, H200, B200, MI300X, Gaudi3
   - Associated specifications for each

### Validation

Create `validation/test_reference_data.m`:
- Compare every reference value against Excel
- Print pass/fail for each comparison
- Target: 100% match

## Completion Criteria for Phase 2

- [ ] All reference data modules created
- [ ] Process library lookup works correctly
- [ ] Validation script passes 100%
- [ ] Code includes units in comments

---

# PHASE 3: Rack Profile Module

## Objective
Implement `0. Rack Profile` sheet calculations — the foundation that determines hardware configuration, cooling characteristics, and per-module thermal properties.

## Instructions

**START BY READING:** `docs/04_phase3_rack_profile.md`

### Implementation Requirements

1. **Create `+tribe/+calc/calcRackProfile.m`**

   Function signature:
   ```matlab
   function rp = calcRackProfile(chipset, cooling_method, module_it_target, electricity_price, annual_hours)
   ```

   Must calculate (in order):
   - Chipset specifications (TDP, chips/server, server power, junction temp, coolant inlet)
   - Cooling characteristics (capture rate, capture temp, coolant type, PUE, capex premium, thermal limit)
   - Rack configuration (servers/rack, GPUs/rack, actual rack power, utilisation)
   - Module summary (racks/module, servers/module, GPUs/module, actual IT capacity)
   - Heat output (captured heat, residual heat)
   - Heat recovery assessment (quality rating, HP requirement, recommended HP output, estimated COP)
   - Heat pump economics (temperature lift, COP, electricity per kWth, total heat output, costs)
   - Annual analysis (heat delivered, HP electricity, HP cost)

2. **Handle conditional logic for:**
   - Chipset selection (5-way switch)
   - Cooling method selection (5-way switch)
   - Heat pump optional/recommended/required logic
   - COP bounds (min 2, max 8)

3. **Output struct `rp` with all calculated fields**

### Validation

Create `validation/test_rack_profile.m`:
- Test with Excel's default inputs (H100, DTC, 250kW target)
- Compare all 35 calculated values
- Test alternate configurations (H200, Immersion, etc.)

## Completion Criteria for Phase 3

- [ ] `calcRackProfile.m` implemented
- [ ] All 35 formulas from sheet transcribed
- [ ] Validation passes for default configuration
- [ ] Validation passes for at least 2 alternate configurations

---

# PHASE 4: Module Calculations (Criteria, Capex, Opex, Flow)

## Objective
Implement the four module-level calculation sheets that depend on Rack Profile.

## Instructions

**START BY READING:** `docs/05_phase4_module_calcs.md`

### Implementation Requirements

1. **Create `+tribe/+calc/calcModuleCriteria.m`**
   ```matlab
   function mc = calcModuleCriteria(rack_profile, hp_enabled, hp_output_temp, utilisation, hours_per_year, base_heat_price, premium_heat_price)
   ```
   - Heat capture specifications
   - Heat pump COP calculation (Carnot-based with bounds)
   - Thermal output with/without HP: `Q_hot = Q_cold * COP/(COP-1)`
   - Heat pricing logic

2. **Create `+tribe/+calc/calcModuleCapex.m`**
   ```matlab
   function capex = calcModuleCapex(rack_profile, module_criteria, ref_data)
   ```
   - Enclosure & structure costs
   - DTC cooling costs (conditional)
   - Immersion cooling costs (conditional)
   - Power distribution costs
   - Thermal integration costs
   - Monitoring & controls costs
   - Heat pump costs (conditional on HP enabled)
   - Cooling premium calculation
   - Total and per-unit metrics

3. **Create `+tribe/+calc/calcModuleOpex.m`**
   ```matlab
   function opex = calcModuleOpex(rack_profile, module_criteria, module_capex, electricity_rate)
   ```
   - Infrastructure electricity cost
   - Heat pump electricity cost (with HP enabled guard)
   - Maintenance costs (% of capex)
   - Insurance (% of capex)
   - Other operating costs (site, NOC, admin)

4. **Create `+tribe/+calc/calcModuleFlow.m`**
   ```matlab
   function flow = calcModuleFlow(module_criteria, cooling_method, ref_data)
   ```
   - Source loop calculations (thermal power, temps, ΔT, flow rates)
   - Sink loop calculations (thermal power, temps, ΔT, flow rates)
   - Pipe sizing guidance (velocity-based ID calculation, DN selection)

### Validation

Create `validation/test_module_calcs.m`:
- Chain: RackProfile → ModuleCriteria → ModuleCapex/Opex/Flow
- Compare all outputs against Excel
- Test with HP enabled and disabled

## Completion Criteria for Phase 4

- [ ] All 4 module calculation functions implemented
- [ ] ~87 formulas transcribed (10 + 46 + 11 + 20)
- [ ] Validation passes for default configuration
- [ ] HP enabled/disabled toggle works correctly

---

# PHASE 5: Buyer Profile & Process Library Integration

## Objective
Implement `5. Buyer Profile` — the most complex sheet with 78 formulas, including process selection, system sizing, heat balance, and equipment dependencies.

## Instructions

**START BY READING:** `docs/06_phase5_buyer_profile.md`

### Implementation Requirements

1. **Create `+tribe/+calc/calcBuyerProfile.m`**
   ```matlab
   function bp = calcBuyerProfile(rack_profile, module_criteria, module_flow, process_id, ref_data)
   ```

   Sections to implement:
   - **Process selection**: Lookup from Process Library
   - **Calculated demand**: Annual heat, process ΔT, required flow rate
   - **System sizing**: Modules needed (thermal), flow constraint check, final module count
   - **Utilisation analysis**: Thermal/flow utilisation, augmentation flag
   - **Heat balance**: System generation, buyer absorption, excess heat, rejection sizing
   - **Hardware dependencies**: HP requirements, hydraulic infrastructure, electrical, space
   - **Bill of materials**: Equipment counts

2. **Critical formulas requiring care:**
   - Flow rate: `kWth / (4.18 * ΔT) * 3.6`
   - Rejection method selection (threshold-based)
   - Augmentation pump sizing (rounded up to whole pumps)
   - HP electrical demand with ISNUMBER guard

3. **Handle the INDEX/MATCH pattern:**
   ```matlab
   process = tribe.data.ProcessLibrary.getProcess(process_id);
   ```

### Validation

Create `validation/test_buyer_profile.m`:
- Test with "Pasteurisation - Medium" (default in Excel)
- Test with at least 3 different processes covering:
  - Flow-constrained (low ΔT)
  - Thermal-constrained (high ΔT)
  - Different temperature requirements

## Completion Criteria for Phase 5

- [ ] `calcBuyerProfile.m` implemented
- [ ] All 78 formulas transcribed
- [ ] Process lookup working
- [ ] Validation passes for multiple process types
- [ ] Augmentation logic correct

---

# PHASE 6: System-Level Calculations

## Objective
Implement the four system-level sheets that aggregate module calculations based on buyer requirements.

## Instructions

**START BY READING:** `docs/07_phase6_system_calcs.md`

### Implementation Requirements

1. **Create `+tribe/+calc/calcSystemCapex.m`**
   ```matlab
   function capex = calcSystemCapex(module_capex, buyer_profile, ref_data)
   ```
   - Module capex × module count
   - Shared infrastructure percentage
   - Integration & commissioning
   - Heat rejection capex
   - Hydraulic augmentation capex

2. **Create `+tribe/+calc/calcSystemOpex.m`**
   ```matlab
   function opex = calcSystemOpex(module_opex, buyer_profile, ref_data)
   ```
   - Module opex × module count
   - Shared overhead percentage
   - Heat rejection opex
   - Augmentation pump electricity

3. **Create `+tribe/+calc/calcSystemFlow.m`**
   ```matlab
   function flow = calcSystemFlow(module_criteria, buyer_profile)
   ```
   - Buyer requirements vs system capacity comparison
   - Supply/demand match indicators
   - Utilisation summary
   - Binding constraint determination (Thermal vs Flow)
   - System pipe sizing

4. **Create `+tribe/+calc/calcSystemPL.m`**
   ```matlab
   function pl = calcSystemPL(module_criteria, buyer_profile, system_capex, system_opex)
   ```
   - Compute revenue (rack rate × capacity × utilisation × 12)
   - Heat revenue (actual absorption × hours × price)
   - Total revenue
   - Total opex
   - Gross profit and margin
   - Payback period and ROI
   - Efficiency metrics (heat utilisation, inefficiency costs)

### Validation

Create `validation/test_system_calcs.m`:
- Full chain from inputs to P&L
- Compare all system-level outputs against Excel
- Verify revenue, cost, and profit figures match

## Completion Criteria for Phase 6

- [ ] All 4 system calculation functions implemented
- [ ] ~121 formulas transcribed (31 + 22 + 32 + 36)
- [ ] Full model chain executes without error
- [ ] P&L figures match Excel within rounding tolerance

---

# PHASE 7: Integration, Validation & Testing

## Objective
Create the main entry point, comprehensive validation suite, and unit tests.

## Instructions

**START BY READING:** `docs/08_phase7_integration.md`

### Implementation Requirements

1. **Create `main.m` or `+tribe/Model.m` class**
   ```matlab
   % Option A: Functional
   function results = runModel(config)

   % Option B: Object-oriented
   classdef Model
       methods
           function obj = Model(config)
           function results = run(obj)
       end
   end
   ```
   - Single entry point accepting configuration struct
   - Calls all calculation functions in correct order
   - Returns comprehensive results struct

2. **Create `+tribe/Config.m`**
   - Default configuration matching Excel
   - Validation of input parameters
   - Helper methods for common configurations

3. **Create comprehensive test suite in `tests/`**
   ```
   tests/
   ├── test_reference_data.m
   ├── test_rack_profile.m
   ├── test_module_criteria.m
   ├── test_module_capex.m
   ├── test_module_opex.m
   ├── test_module_flow.m
   ├── test_buyer_profile.m
   ├── test_system_capex.m
   ├── test_system_opex.m
   ├── test_system_flow.m
   ├── test_system_pl.m
   └── test_full_model.m
   ```

4. **Create `validation/validate_against_excel.m`**
   - Load Excel file programmatically (if possible) or use hardcoded expected values
   - Run MATLAB model with matching inputs
   - Compare every calculated cell
   - Generate report: matched, mismatched, tolerance

### Validation

- All unit tests pass
- Full model validation shows <0.01% deviation from Excel (allowing for rounding)

## Completion Criteria for Phase 7

- [ ] Main entry point working
- [ ] Configuration system working
- [ ] All unit tests created and passing
- [ ] Excel validation report shows full match
- [ ] README with usage instructions

---

# PHASE 8: Scenario Analysis & Visualization

## Objective
Add capabilities that leverage MATLAB's strengths: parameter sweeps, sensitivity analysis, and visualization.

## Instructions

**START BY READING:** `docs/09_phase8_scenarios.md`

### Implementation Requirements

1. **Create `+tribe/+analysis/parameterSweep.m`**
   ```matlab
   function results = parameterSweep(base_config, param_name, param_values)
   ```
   - Run model across range of parameter values
   - Return table of results for analysis

2. **Create `+tribe/+analysis/sensitivityAnalysis.m`**
   - Vary key inputs ±10%, ±20%
   - Calculate impact on payback period, ROI, gross margin
   - Generate tornado chart data

3. **Create `+tribe/+analysis/compareScenarios.m`**
   - Compare multiple configurations side-by-side
   - Chipset comparison
   - Cooling method comparison
   - Process/buyer comparison

4. **Create visualization functions in `+tribe/+viz/`**
   - `plotCapexBreakdown.m` — stacked bar of capex components
   - `plotOpexBreakdown.m` — stacked bar of opex components
   - `plotRevenueStreams.m` — compute vs heat revenue
   - `plotSensitivity.m` — tornado chart
   - `plotPaybackCurve.m` — cumulative cash flow over time

5. **Create example scripts in `examples/`**
   ```
   examples/
   ├── example_basic_run.m
   ├── example_chipset_comparison.m
   ├── example_cooling_method_comparison.m
   ├── example_sensitivity_analysis.m
   └── example_process_screening.m
   ```

### Deliverables

- Working parameter sweep capability
- At least 3 visualization types
- Example scripts demonstrating usage

## Completion Criteria for Phase 8

- [ ] Parameter sweep function working
- [ ] Sensitivity analysis function working
- [ ] Visualization functions created
- [ ] Example scripts run without error
- [ ] Basic documentation/comments in all files

---

# Appendix: Key Formulas Quick Reference

## Heat Pump Thermodynamics
```matlab
% COP (Carnot-based with efficiency factor)
COP = eta * (T_hot_K) / (T_hot - T_cold)  % where T_hot_K = T_hot + 273.15

% Bounded COP
COP = max(COP_min, min(COP_max, COP))  % typically min=2, max=8

% Heat output from captured heat
Q_hot = Q_cold * COP / (COP - 1)

% Electrical input
W = Q_hot / COP  % or equivalently: W = Q_cold / (COP - 1)
```

## Flow Rate Calculation
```matlab
% Mass flow rate (kg/s)
m_dot = Q_kW / (cp * delta_T)  % cp = 4.18 kJ/kg·K for water

% Volume flow rate (m³/hr)
V_dot = m_dot / rho * 3.6  % rho ≈ 1 kg/L for water, 3.6 converts L/s to m³/hr
```

## Server Power
```matlab
server_power_kW = TDP_W * chips_per_server / 1000 * 1.15  % 15% overhead
```

## Module Sizing
```matlab
servers_per_rack = floor(rack_thermal_limit / server_power)
racks_per_module = ceil(module_target / actual_rack_power)
```

---

# Appendix: Validation Test Values

These are the expected outputs for the default Excel configuration:

**Inputs:**
- Chipset: NVIDIA H100
- Cooling: Direct-to-Chip (DTC)
- Module IT target: 250 kW
- HP enabled: Yes
- HP output temp: 90°C
- Process: Pasteurisation - Medium

**Key outputs to validate:**
- Module IT capacity: [read from Excel]
- Module thermal output: [read from Excel]
- Modules required: [read from Excel]
- Total system capex: [read from Excel]
- Total system opex: [read from Excel]
- Gross profit: [read from Excel]
- Simple payback: [read from Excel]

*(Phase 1 agent should populate these values from the Excel file)*

---

## How to Use This Prompt

1. **Start Phase 1**: Give this entire document plus the Excel file to your coding agent
2. **Phase 1 produces documentation**: No code, only the `docs/` folder with detailed guides
3. **Start Phase 2**: Fresh chat, give only `docs/03_phase2_reference_data.md` plus Excel file
4. **Continue pattern**: Each phase gets fresh context with only its specific guide document
5. **Phase 7 integrates everything**: May need to reference multiple docs
6. **Phase 8 extends**: Adds analysis capabilities beyond Excel parity

**Important**: Validate each phase against Excel before proceeding to the next. Do not accumulate errors.
