%  Compress the data to show 40 dB of
%  dynamic range for the CFM phantom image
%
%  version 1.2 by Joergen Arendt Jensen, April 6, 1997.
%  version 1.3 by Joergen Arendt Jensen, October 23, 2022
%     Fixed errors with integers
%     Make quantitative image display
%  Version 4.0, 24/10-2022, JAJ
%    Version with one routine for setting parameters

%  Set parameters for the simulation

define_parameters

d_x=40/1000/no_lines_B_mode;     %  Increment for image

%  Read the data and adjust it in time

min_sample=0;
for i=1:no_lines_B_mode

    %  Load the result

    cmd=['load sim_bmd/rf_ln',num2str(i),'.mat'];
    eval(cmd)

    %  Find the envelope

    if (tstart>0)
        rf_env=abs(hilbert([zeros(round(tstart*fs-min_sample),1); rf_data]));
    else
        rf_env=abs(hilbert( rf_data( abs(round(tstart*fs)):max(size(rf_data)) ) ));
    end
    env(1:max(size(rf_env)),i)=rf_env;
end

%  Do logarithmic compression

log_env=env(1:D:max(size(env)),:)/max(max(env));
log_env=20*log10(log_env);
log_env=log_env+dB_range;

%  Make an interpolated image

ID_bmode=10;
[n,m]=size(log_env);
new_env=zeros(n,m*ID_bmode);
for i=1:n
     new_env(i,:)=abs(interp(log_env(i,:),ID_bmode));
end
[n,m]=size(new_env);

fn_bmode=fs/D;
clf
imagesc(((1:(ID_bmode*no_lines_B_mode-1))*d_x/ID_bmode-no_lines_B_mode*d_x/2)*1000,((1:n)/fn_bmode+min_sample/fs)*1540/2*1000,new_env)
colormap(gray(dB_range))
caxis([0 dB_range])
xlabel('Lateral distance [mm]')
ylabel('Axial distance [mm]')
axis('image')
axis([-image_width/2 image_width/2 start_depth end_depth]*1000)
colorbar
