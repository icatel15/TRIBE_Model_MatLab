function chipsets = Chipsets()
%CHIPSETS Return chipset definitions.
% Units: tdp_per_chip_w in W, t_junction_c in C.

ref = tribe.data.ReferenceData();
data = ref.chipsets;

chipsets = struct();
chipsets.H100 = selectByName("NVIDIA H100");
chipsets.H200 = selectByName("NVIDIA H200");
chipsets.B200 = selectByName("NVIDIA B200");
chipsets.MI300X = selectByName("AMD MI300X");
chipsets.Gaudi3 = selectByName("Intel Gaudi 3");

    function chipset = selectByName(name)
        idx = find(data.name == name, 1);
        if isempty(idx)
            error('Chipsets:NotFound', 'Chipset not found: %s', name);
        end
        chipset = struct( ...
            'name', data.name(idx), ...
            'tdp_per_chip_w', data.tdp_per_chip_w(idx), ...
            'chips_per_server', data.chips_per_server(idx), ...
            't_junction_c', data.t_junction_c(idx), ...
            'notes', data.notes(idx));
    end
end
