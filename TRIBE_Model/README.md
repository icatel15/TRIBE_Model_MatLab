# TRIBE Model (MATLAB)

## Quick Start

```matlab
addpath('TRIBE_Model');
results = main();
```

## App Front End (TribeFrontEnd)

Launch the App Designer UI from the repo root:

```matlab
addpath('TRIBE_Model');
rehash toolboxcache;
app = TribeFrontEnd;
```

If you are not in the repo root, use an absolute path to the `TRIBE_Model`
folder:

```matlab
addpath('/Users/icatel/Desktop/Coding/TRIBE_Modelling_MatLab/TRIBE_Model');
rehash toolboxcache;
app = TribeFrontEnd;
```

If MATLAB cannot find the UI classes, verify the package path:

```matlab
which tribe.ui.ConfigEditor
```

You should see a path under `TRIBE_Model/+tribe/+ui/ConfigEditor.m`.

## Configuration

```matlab
cfg = tribe.Config.default();
cfg.rack_profile.chipset = "NVIDIA H200";
cfg.buyer_profile.process_id = "Pasteurisation - Medium";
results = tribe.Model(cfg).run();
```

Helper presets:

```matlab
cfg = tribe.Config.forCoolingMethod("Single-Phase Immersion");
results = tribe.Model(cfg).run();
```

## Excel Validation

```matlab
addpath('TRIBE_Model/validation');
report = validate_against_excel();
```

To relax the coverage threshold (for example, when running without a cache),
override the minimum coverage:

```matlab
report = validate_against_excel('min_coverage', 0);
```

To use cached values on non-Windows machines, generate the cache on a machine
with Excel and then re-run validation:

```matlab
addpath('TRIBE_Model/validation');
cache_excel_values('use_excel', true);
report = validate_against_excel();
```

## Tests

```matlab
addpath('TRIBE_Model');
runtests('TRIBE_Model/tests');
```
