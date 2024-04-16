%  Make imaging of phantom data for a single transmit focus
%  and multiple receive foci
%
%  Version 1.0, March 25, 1997, Joergen Arendt Jensen
%  Version 1.2, August 14, 1998, Joergen Arendt Jensen
%       Problem with focusing reference fixed

%  Make the apodization vector

apo=hanning(N_active)';

z_focus=60/1000;          %  Transmit focus

%  The different focal zones for reception

focal_transmit=[10 20 40 80]'/1000;
Nft=max(size(focal_transmit));
focus_times_transmit=([0 15 30 60]'/1000)/1540;

focal_receive=[30:20:150]'/1000;
Nfr=max(size(focal_receive));
focus_times_receive=(focal_receive-10/1000)/1540;

x= -image_width/2;
image_data=0;
for i=1:no_lines
   %   Set the focus for this direction

  xdc_center_focus (emit_aperture,[x 0 0]);
  xdc_focus (emit_aperture, focus_times_transmit, [x*ones(Nft,1), zeros(Nft,1), focal_transmit]);
  xdc_center_focus (receive_aperture,[x 0 0]);
  xdc_focus (receive_aperture, focus_times_receive, [x*ones(Nfr,1), zeros(Nfr,1), focal_receive]);

   %  Calculate the apodization 
   
  N_pre  = round(x/(width+kerf) + N_elements/2 - N_active/2);
  N_post = N_elements - N_pre - N_active;
  apo_vector=[zeros(1,N_pre) apo zeros(1,N_post)];
  xdc_apodization (emit_aperture, 0, apo_vector);
  xdc_apodization (receive_aperture, 0, apo_vector);

  %   Calculate the received response

  [v, t1]=calc_scat(emit_aperture, receive_aperture, phantom_positions, phantom_amplitudes);

  %  Store the result

  image_data(1:max(size(v)),i)=v;
  times(i) = t1;

  %  Steer in another angle

  x = x + d_x;
  end
