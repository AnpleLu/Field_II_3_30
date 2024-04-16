%  Make a combined CFM and B-mode image from
%  simulated data
%
%  Version 1.0, 3/4-97, JAJ
%  Version 1.1, 23/10-2022, JAJ
%     Update with pre-allocation

%  Do the gray scale data first

make_image

%  Then do the cfm image

cfm_image

%  Combine the two images
%  Ndist is the number of samples between two velocity estimates

Ndist_new=D*Ndist*fn_bmode/fs;  %  New conversion factor between sampling frequencies

%  Calculate scaling factor for velocity

max_v=v0*cos(theta);  %  Maximum velocity [m/s]
[Nsamples,Nlines]=size(new_env);
[Nest,Nlest]=size(new_est);
comb_image=zeros(Nsamples,Nlines);  %  Pre-allocate resuting image

for line=1:Nlines
    if rem(line,100) == 0
        disp(['Making for line ', num2str(line)])
    end
    for sample=1:Nsamples
        if (sample/Ndist_new+1 < Nest)
            if (new_est(round(sample/Ndist_new+1),line) > 0.1)
                comb_image(sample,line)=new_est(round(sample/Ndist_new+1),line)/max_v*64 + 64;
            else
                comb_image(sample,line)=new_env(sample,line);
            end
        else
            comb_image(sample,line)=new_env(sample,line);
        end
    end
end

%  Make a color map for the combined image

map=[[0:dB_range 0:63]; [0:dB_range zeros(1,64)]; [0:dB_range zeros(1,64)]]/63;
colormap(map')

%  Display the combined result

clf
dx=40/500;
image( ((1:Nlines)-Nlines/2)*dx,((1:Nsamples)/fn_bmode)*c/2*1000,comb_image)
xlabel('Lateral distance [mm]')
ylabel('Axial distance [mm]')
colormap(map')
axis('image')
axis([-image_width/2 image_width/2 start_depth end_depth]*1000)
title('Color flow map image')
print -depsc cfm_image.eps



