%  This is a demo program, which automatically does background suppression for X-ray angiography images.
%
%  Demo is written by Z.Xu Universitat Autonoma de Barcelona (JAN. 2015)


close all

% add path
addpath(genpath('./'))

% read image file and do frangi enhancement
t = cputime;   % count the running time                                              
file_name = '39468421-4x1024x1024-3.000-2_Bytes-LittleEndian';
ln = 4;
bg_suppression([file_name,'.raw'],ln,file_name);


%display the running time
t = cputime - t;
fprintf('The time for computing is %d seconds\n', t);
