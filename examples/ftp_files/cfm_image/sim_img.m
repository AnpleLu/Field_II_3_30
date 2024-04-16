%  Example of use of the new Field II program running under Matlab
%
%  This example shows how a linear array B-mode system scans an image
%
%  This script assumes that the field_init procedure has been called
%  Here the field simulation is performed and the data is stored
%  in rf-files; one for each rf-line done. The data must then
%  subsequently be processed to yield the image. The data for the
%  scatteres are read from the file pht_data.mat, so that the procedure
%  can be started again or run for a number of workstations.
%
%  Version 2.1 by Joergen Arendt Jensen, August 14, 1998 for Matlab 5.
%  Version 3.0 by Joergen Arendt Jensen, October 23, 2022
%     Updated with new transducer parameters
%  Version 4.0, 24/10-2022, JAJ
%    Version with one routine for setting parameters

%  Set parameters for the simulation

define_parameters

%  Set the sampling frequency

set_sampling(fs);

%  Generate aperture for emission

emit_aperture = xdc_focused_array (N_elements, width, element_height, kerf, elevation_focus, 1, 10, focus);

%  Set the impulse response and excitation of the emit aperture

impulse_response=sin(2*pi*f0*(0:1/fs:1/f0));
impulse_response=impulse_response.*hanning(max(size(impulse_response)))';
xdc_impulse (emit_aperture, impulse_response);

excitation=sin(2*pi*f0*(0:1/fs:M_cycles_B_mode/f0));
xdc_excitation (emit_aperture, excitation);

%  Generate aperture for reception

receive_aperture = xdc_focused_array (N_elements, width, element_height, kerf, elevation_focus, 1, 10, focus);

%  Set the impulse response for the receive aperture

xdc_impulse (receive_aperture, impulse_response);

%   Set a Hanning apodization on the apertures

apo=hanning(xmit_N_active)';

%   Load the computer phantom data

load pht_data

%  Set the different focal zones for reception

Nf=max(size(focal_zones));
focus_times=(focal_zones-1/1000)/1540;

%  Make the directory for the result

mkdir('sim_bmd')

%   Do linear array imaging

d_x=image_width/no_lines_B_mode;    %  Increment for image
for i=1:no_lines_B_mode

    disp(['Simulating for line ',num2str(i)])

    %  Find the direction for the imaging

    x= -image_width/2 + (i-1)*d_x;

    %   Set the focus for this direction

    xdc_center_focus (emit_aperture, [x 0 0]);
    xdc_focus (emit_aperture, 0, [x 0 z_focus_transmit]);
    xdc_center_focus (receive_aperture, [x 0 0]);
    xdc_focus (receive_aperture, focus_times, [x*ones(Nf,1), zeros(Nf,1), focal_zones]);

    %  Calculate the apodization

    N_pre  = round(x/(width+kerf) + N_elements/2 - xmit_N_active/2);
    N_post = N_elements - N_pre - xmit_N_active;
    apo_vector=[zeros(1,N_pre) apo zeros(1,N_post)];
    xdc_apodization (emit_aperture, 0, apo_vector);
    xdc_apodization (receive_aperture, 0, apo_vector);

    %   Calculate the received response

    [rf_data, tstart]=calc_scat(emit_aperture, receive_aperture, phantom_positions, phantom_amplitudes);

    %  Store the result

    cmd=['save sim_bmd/rf_ln',num2str(i),'.mat rf_data tstart'];
    eval(cmd)

    %  Steer in another direction

    x = x + d_x;
end

%   Free space for apertures

xdc_free (emit_aperture)
xdc_free (receive_aperture)
