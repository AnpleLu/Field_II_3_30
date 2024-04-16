%  Make the scatteres for a simulation and store
%  it in a file for later simulation use
%
%   Joergen Arendt Jensen, April 2, 1998
%  Version 3.0, 24/10-2022, JAJ
%    Version with one routine for setting parameters

%  Set parameters for the simulation

define_parameters

%  Set the seed of the random number generator

rng('default')

%  Set the number of scatterers. It should be roughly
%  10 scatterers per point spread function volume

N_B_mode=round(10*x_range/(F_number*lambda)*y_range/(F_number_elevation*lambda)*z_range/(lambda*M_cycles_B_mode));
disp([num2str(N_B_mode),' Scatterers'])

[phantom_positions, phantom_amplitudes] = tissue_pht(N_B_mode);
save pht_data.mat phantom_positions phantom_amplitudes
