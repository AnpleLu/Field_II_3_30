%  Make a simulation of the received rf signal from
%  flow with a parabolic velocity profile
%  The result is stored as scatterer positions in a file
%
%  Version 2.0, 2/4-98, JAJ
%  Version 2.1, 23/10-2022, JAJ
%    Make the directory for the scatterers
%    Changed seed in random number generator
%  Version 3.0, 24/10-2022, JAJ
%    Version with one routine for setting parameters

%  Set parameters for the simulation

define_parameters

%  Set the seed of the random number generator

rng('default')

%  Set the number of scatterers. It should be roughly
%  10 scatterers per point spread function volume

N=round(10*x_range/(F_number*lambda)*y_range/(F_number_elevation*lambda)*z_range/(lambda*M_cycles_cfm));
disp([num2str(N),' Scatterers'])

%  Generate the coordinates and amplitude
%  Coordinates are rectangular within the range.
%  The amplitude has a Gaussian distribution.

x=x_range*(rand(1,N)-0.5);
y=y_range*(rand(1,N)-0.5);
z=z_range*(rand(1,N)-0.5);

%  Find which scatterers that lie within the blood vessel

r=(y.^2+z.^2).^0.5;
within_vessel= r < R;

%  Assign an amplitude and a velocity for each scatterer

velocity=v0*(1-(r/R).^2).*within_vessel;
amp=randn(1,N).*((1-within_vessel) + within_vessel*blood_to_stationary);
amp=amp';

%  Generate files for the scatteres over a number of pulse emissions
%  Make the directory holding the scatterers

mkdir sim_flow

%  Make scatterers for all the emissions

for i=1:Ncfm

    %  Generate the rotated and offset block of sample

    xnew=x*cos(theta)+z*sin(theta);
    znew=z*cos(theta)-x*sin(theta) + z_offset;
    positions=[xnew; y; znew;]';

    %   Save the matrix with the values

    cmd = ['save sim_flow/scat_',num2str(i),'.mat positions amp'];
    eval(cmd)
    disp(['Saving using the command: ', cmd])

    %  Propagate the scatterers and aliaze them
    %  to lie within the correct range

    x1=x;
    x=x + velocity*Tprf;
    outside_range= (x > x_range/2);
    x=x - x_range*outside_range;
end



