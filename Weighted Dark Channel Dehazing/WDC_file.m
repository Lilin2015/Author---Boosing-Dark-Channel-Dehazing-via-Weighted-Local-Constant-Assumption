%% weighted dark channel dehazing
% this is a demo of the paper "boosting dark channel dehazing via weighing local constant assumption"
% step 1. put interested hazy images in the file "inputs", gray images are also applicable
% step 2. check the params
% step 3. run this script
% step 4. check results in the file "results"

%% prepare
clear
close all
path(path,strcat(pwd,'/inputs'));
path(path,strcat(pwd,'/WDC dehazing'))
loadfile = dir(strcat(pwd,'/inputs'));
savefile = strcat(pwd,'/results'); 
image_num = length(loadfile);

%% params
%{
Following params are all set to the values used in the manuscript.
Haze removal result can be better if you tune them more carefully.
If you feel these is too much haze retained in the result, try to decrease epsilon, such as 0.05.
If you want to handle big images, increase lsize, but it might be blocked if the input is too large, such as more than 2000.
%}
lambda  = 0.02;     % the lambda
epsilon = 0.05;      % the epsilon
lsize   = 640;      % the maximum of input width and height, 
                    % if this param is enlarged, remember to also check the block size below.
bsz     = 25;       % size of the Omega(x)

%{ 
The two params below are set to zero, thus not included in the manuscript
1. reserve:     set an extra lowerbound to tranmissions, if you feel there is too much
                noise in far distance, try to increase this param, such as 0.1.
2. postEnhance: post-enhancement is not fair to comparision, thus excluded in the experiment 
                and the appended video.
                To enable it, set this param to 1.
                The post-enhancement code is provided by:
                    Non-Local Image Dehazing. Berman, D. and Treibitz, T. and Avidan S., CVPR2016.
                can be found in
                    www.eng.tau.ac.il/~berman/NonLocalDehazing/NonLocalDehazing_CVPR2016.pdf
%}
reserve = 0;      % the minimum of transmissions
postEnhance = 0;    % employ post-enhancement or not

CWDC = 0;           % consider lower-bound constraint in the solving process or not

% Notes:
% It is better to check haze removal result by "imshow" or Photo Viewer,
% the preview provided by matlab might be inaccurate.
%% dehaze
for i = 1:image_num
    fileName = loadfile(i).name;
    [~,name,suffix] = fileparts(fileName);
    if strcmpi(suffix,'.jpg') || strcmpi(suffix,'.bmp') || strcmpi(suffix,'.png')
        % read input
        I = im2double(imread(fileName));
        % set size of the input.
        I = imresize(I,lsize/max(size(I,1),size(I,2)));
        % estimate A
        A = wdc_airLight(I,bsz);
        % A = [1,1,1];  
        % providing true air-light is good for a fair comparison on transmission estimation
        
        % solve T
        Iw = wdc_whiteImage(I,A);        
        
        B  = 1 - min(Iw,[],3);               % lower bound
        Ti = imdilate(B,strel('disk',bsz));  % initial trans. map
        W = 1./max( (B-Ti).^2,0.001)/1000;   % weight map
        
        if CWDC == 1
            Tt = wdc_BoxCDC(Ti, W, Iw, B, lambda); % CWDC algorithm
        else
            Tt = wls_optimization(Ti, W, Iw, lambda); % final trans. map
        end
        
        % dehaze
        haze_factor = 1 + epsilon;
        T = (max(B,Tt) + (haze_factor-1) )/haze_factor;
        J = wdc_radiance(I,max(reserve,T),A);
        
        if postEnhance == 1
            J = J.^0.9;
            % J = imadjust(J,[0.005, 0.995]);
        end
        
        J(:,:,1) = J(:,:,1);
        % result save
        % imwrite(I,[savefile,'/',name,'_hazy.bmp']);
        imwrite(J,[savefile,'/',name,'_J_wdc.bmp']);
        imwrite(ind2rgb(gray2ind(T,255),jet(255)),[savefile,'/',name,'_T_wdc.bmp']);
    end
end
