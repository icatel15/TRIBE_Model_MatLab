# TRIBE Model (MATLAB)

## Quick Start

```matlab
addpath('TRIBE_Model');
results = main();
```

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
