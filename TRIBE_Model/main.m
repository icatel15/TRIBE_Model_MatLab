function results = main(config)
%MAIN Run the TRIBE model with default or supplied configuration.

if nargin < 1
    config = [];
end

model = tribe.Model(config);
results = model.run();
end
