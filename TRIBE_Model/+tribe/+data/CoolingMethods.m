function methods = CoolingMethods()
%COOLINGMETHODS Return cooling method definitions.
% Units: heat_capture_rate_pct is fraction, capture_temperature_c in C,
% capex_premium_pct in percent points, source_deltat_c in C.

ref = tribe.data.ReferenceData();
data = ref.cooling_methods;

methods = struct();
methods.DTC = selectByName("Direct-to-Chip (DTC)");
methods.SinglePhaseImmersion = selectByName("Single-Phase Immersion");
methods.TwoPhaseImmersion = selectByName("Two-Phase Immersion");
methods.RDHX = selectByName("Rear Door Heat Exchanger");
methods.AirCooled = selectByName("Air Cooled (Reference)");

    function method = selectByName(name)
        idx = find(data.name == name, 1);
        if isempty(idx)
            error('CoolingMethods:NotFound', 'Cooling method not found: %s', name);
        end
        method = struct( ...
            'name', data.name(idx), ...
            'heat_capture_rate_pct', data.heat_capture_rate_pct(idx), ...
            'capture_temperature_c', data.capture_temperature_c(idx), ...
            'capex_premium_pct', data.capex_premium_pct(idx), ...
            'source_deltat_c', data.source_deltat_c(idx));
    end
end
