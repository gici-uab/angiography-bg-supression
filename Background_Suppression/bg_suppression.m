function [final_BGsuppressed, mask] = bg_suppression(ima,ln,file_name) 

% BG_SUPPRESSION(IMA, LN, file_name), returns a raw image 'final_BGsuppressed' which is background suppressed, and a mask image 'mask'.
%
%   It uses the radical-symmetrical feature of X-ray angiography images, and uses ray-casting and alpha-shape methods. More details, please refer to our work:
%   [1] Z. Xu, J. Bartrina-Rapesta, V. Sanchez, J. Serra-Sagrist`a, and J. Munoz-G ́omez, “Diagnostically lossless compression of x-ray angiography images 
%       based on automatic segmentation using ray-casting and α-shapes,” in Image Processing (ICIP), 2013 20th IEEE International Conference on. IEEE, 2013, pp. 738–742.
%
%   For alpha-shape method, source codes from [2] are used and include in folder 'aslib_13apr2010'. 
%   [2] http://www.mathworks.com/matlabcentral/fileexchange/6760-ashape--a-pedestrian-alpha-shape-extractor
%
%   IMA.  A string of the image's filename. If the image is not in the current folder, or in a folder on the MATLAB® path,
%   specify the full pathname. 
%
%   LN.  A scalar that tells the number of frames in the image.
%
%   FILE_NAME. A string of the image's filename, but without the file
%   extension and the folder path.
%   
%   Examples for usage, see the demo.m
%
%   Function is written by Z.Xu Universitat Autonoma de Barcelona (JAN. 2015)

% read image file
fid = fopen(ima,'r');
GY = fread(fid, 1024*1024*ln, 'uint16');
m = reshape(GY,1024,1024,ln);
I1 = zeros(1024);


% compute the average frame 
for i = 1:ln
    I1 = I1 + m(:,:,i);
end
I1 = I1/ln;

% reduce noises
num_iter = 15;
delta_t = 1/7;
kappa = 30;
option = 1;
I2 = anisodiff2D(I1,num_iter,delta_t,kappa,option);


% amax=max(max(I2));
% amin=min(min(I2));
% I3=(I2-amin)*(1/(amax-amin));


c_final = zeros(1024);

% the two parameters defining the sliding windows sizes
thr_width = 10;
thr_width2 = 50;

c1_jump = zeros(512,1);                            % store the increasing values
c2_jump = zeros(512,1);
c3_jump = zeros(512,1);
c4_jump = zeros(512,1);

for i = 1:1024
    [cx1,cy1,c1] = improfile(I2,[1,512],[i,512],'nearest');
    
    [cx2,cy2,c2] = improfile(I2,[1024,512],[1024-i+1,512],'nearest');
    
    [cx3,cy3,c3] = improfile(I2,[i,512],[1,512],'nearest');
    
    [cx4,cy4,c4] = improfile(I2,[1024-i+1,512],[1024,512],'nearest');
    
    for j = 1:512
        c1_jump(j) = max(c1(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)))-min(c1(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));    
        c2_jump(j) = max(c2(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)))-min(c2(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c3_jump(j) = max(c3(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)))-min(c3(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c4_jump(j) = max(c4(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)))-min(c4(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));    
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    t=0.7;   % the parameter defines the threshold value
    max12 = 0;
    for j = 1:512

        [c1_jump_max,c1_jump_max_i] = max(c1(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c1_jump_min = min(c1(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c1_jump_max_i));

        [c2_jump_max,c2_jump_max_i] = max(c2(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c2_jump_min = min(c2(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c2_jump_max_i));       
        maxtemp12 = max((c1_jump_max - c1_jump_min),(c2_jump_max - c2_jump_min));
        if maxtemp12>=max12
             max12 = maxtemp12;
        end 
        
    end  

    thr_incre12 = max12*t;
    
    for j = 1:512

        [c1_jump_max,c1_jump_max_i] = max(c1(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c1_jump_min = min(c1(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c1_jump_max_i));

        [c2_jump_max,c2_jump_max_i] = max(c2(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c2_jump_min = min(c2(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c2_jump_max_i));       
        
        if (((c1_jump_max - c1_jump_min) > thr_incre12) || ((c2_jump_max - c2_jump_min) > thr_incre12))
            [c12_jump_max,c12_nam] = max([(c1_jump_max-c1_jump_min),(c2_jump_max-c2_jump_min)]);
            c12_j = j;
            break;
        end
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   max34 = 0;  
   for j = 1:512
        
        [c3_jump_max,c3_jump_max_i] = max(c3(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c3_jump_min = min(c3(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c3_jump_max_i));
        
        [c4_jump_max,c4_jump_max_i] = max(c4(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c4_jump_min = min(c4(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c4_jump_max_i));
        maxtemp34 = max((c3_jump_max - c3_jump_min),(c4_jump_max - c4_jump_min));
        if maxtemp34>=max34
             max34 = maxtemp34;
        end        
   end 
    
   thr_incre34 = max34*t;
   
    for j = 1:512
        
        [c3_jump_max,c3_jump_max_i] = max(c3(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c3_jump_min = min(c3(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c3_jump_max_i));
        
        [c4_jump_max,c4_jump_max_i] = max(c4(((j-thr_width)>0)*(j-thr_width-1)+1:512-(512-j-thr_width>0)*(512-j-thr_width)));
        c4_jump_min = min(c4(((j-thr_width)>0)*(j-thr_width-1)+1:((j-thr_width)>0)*(j-thr_width-1)+c4_jump_max_i));
        
        if (((c3_jump_max - c3_jump_min) > thr_incre34) || ((c4_jump_max - c4_jump_min) > thr_incre34))
            [c34_jump_max,c34_nam] = max([(c3_jump_max-c3_jump_min),(c4_jump_max-c4_jump_min)]);
            c34_j = j;
            break;
        end
        
    end
    

    if c12_nam == 1
        for k = ((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1:c12_j+thr_width2
            c2_jump(k) = max(c2(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))-min(c2(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))));
        end
        [c2_jump_max,c2_j] = max(c2_jump(((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1:c12_j+thr_width2));
        c2_j = c2_j  +  ((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1  - 1;
        c1_j = c12_j;
    elseif c12_nam == 2     
        for k = ((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1:c12_j+thr_width2
            c1_jump(k) = max(c1(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))-min(c1(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))));
        end
        [c1_jump_max,c1_j] = max(c1_jump(((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1:c12_j+thr_width2));
        c1_j = c1_j  +  ((c12_j-thr_width2)>0)*(c12_j-thr_width2-1)+1  - 1;
        c2_j = c12_j;
    end
    
    if c34_nam == 1
        for k = ((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1:c34_j+thr_width2
            c4_jump(k) = max(c4(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))-min(c4(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))));
        end
        [c4_jump_max,c4_j] = max(c4_jump(((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1:c34_j+thr_width2));
        c4_j = c4_j  +  ((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1  - 1;
        c3_j = c34_j;
    elseif c34_nam == 2     
        for k = ((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1:c34_j+thr_width2
            c3_jump(k) = max(c3(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))-min(c3(((k-thr_width)>0)*(k-thr_width-1)+1:512-(512-k-thr_width>0)*(512-k-thr_width))));
        end
        [c3_jump_max,c3_j] = max(c3_jump(((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1:c34_j+thr_width2));       
        c3_j = c3_j  +  ((c34_j-thr_width2)>0)*(c34_j-thr_width2-1)+1  - 1;
        c4_j = c34_j;
    end
    
    c_final(round(cy1(c1_j)),round(cx1(c1_j))) = 1;
    c_final(round(cy2(c2_j)),round(cx2(c2_j))) = 1;
    c_final(round(cy3(c3_j)),round(cx3(c3_j))) = 1;
    c_final(round(cy4(c4_j)),round(cx4(c4_j))) = 1;
    
end
%figure,imshow(c_final);
%imwrite(c_final,'~/Desktop/ori.pgm','pgm');
c_final2 = zeros(1024);

[c_x,c_y] = find(c_final);

% c_p = ashape(c_y,1024-c_x+1,100,'-nc','-g');                        % containing Coordinate transformation

% c_p = ashape(c_y,1024-c_x+1,100,'-bc','-cm','hsv'); 
c_p = ashape(c_y,1024-c_x+1,100,'-nc','-g');  

c_as = c_p.ashape;

c_xs = c_p.x(c_as{1});
c_ys = c_p.y(c_as{1});

xs_s = size(c_xs,1);

for i = 1:xs_s
    if abs(c_xs(i,1)-c_xs(i,2)) >= abs(c_ys(i,1)-c_ys(i,2))
        c_xsi = min(c_xs(i,1),c_xs(i,2)):max(c_xs(i,1),c_xs(i,2));
        c_ysi = interp1(c_xs(i,:),c_ys(i,:),c_xsi);
        c_ysi = round(c_ysi);
        for j = 1:size(c_xsi,2)
            c_final2(1024-c_ysi(j)+1,c_xsi(j)) = 1;
        end
    else
        c_ysi = min(c_ys(i,1),c_ys(i,2)):max(c_ys(i,1),c_ys(i,2));
        c_xsi = interp1(c_ys(i,:),c_xs(i,:),c_ysi);
        c_xsi = round(c_xsi);
        for j = 1:size(c_ysi,2)
            c_final2(1024-c_ysi(j)+1,c_xsi(j)) = 1;
        end
    end
    
    c_final2(1024-c_ys(i,1)+1,c_xs(i,1)) = 1;
    c_final2(1024-c_ys(i,2)+1,c_xs(i,2)) = 1;
    
end   

c_final_ashape_filled = imfill(c_final2,'holes');

mask = c_final_ashape_filled;


final_BGsuppressed = zeros(1024,1024,ln);

for i = 1:ln
    final_BGsuppressed(:,:,i) = c_final_ashape_filled.*m(:,:,i);
end

ff=fopen([file_name,'_BGsuppressed.raw'],'w','b');
fwrite(ff,final_BGsuppressed,'uint16',0,'ieee-le');
fclose(ff);

imwrite(mask,[file_name,'_mask.pgm']','pgm');
% close all

end
