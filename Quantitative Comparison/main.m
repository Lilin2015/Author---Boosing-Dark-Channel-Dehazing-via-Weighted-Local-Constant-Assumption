% copy results into corresponding files, don't forget copy groundtruth into GT
% run this script
% check the value of "score" and "score_sta"(first row: mean, second row: median)
clear
close all

%% prepare
path(path,strcat(pwd,'\3rdParty\vifvec_release'));
path(path,strcat(pwd,'\3rdParty\matlabPyrTools-master'));
path(path,strcat(pwd,'\3rdParty\iwssim_iwpsnr'));
path(path,strcat(pwd,'\3rdParty'));
path(path,strcat(pwd,'\Results\GT'));
path(path,strcat(pwd,'\Results\our-EM'));
path(path,strcat(pwd,'\Results\our-WDC'));
path(path,strcat(pwd,'\Results\our-CWDC'));
path(path,strcat(pwd,'\Results\He-DC'));
path(path,strcat(pwd,'\Results\Meng'));
path(path,strcat(pwd,'\Results\Berman'));
path(path,strcat(pwd,'\Results\MSCNN'));
path(path,strcat(pwd,'\Results\AOD'));
path(path,strcat(pwd,'\Results\DCPCN'));
path(path,strcat(pwd,'\Results\DehazeNet'));
loadfile = dir(strcat(pwd,'\Results\GT'));
image_num = length(loadfile);

%% process
score = [];
for i = 1:image_num
    fileName = loadfile(i).name;
    [~,name,suffix] = fileparts(fileName);
    if strcmpi(suffix,'.jpg') || strcmpi(suffix,'.bmp') || strcmpi(suffix,'.png')
        
        picName = fileName(1:findstr(fileName,'_')-1);
        fprintf([picName,'\n']);
        GT = im2double(imresize(imread(fileName),[480 640]));
        suffix = '_J_';
        
        he = im2double(imread([picName,suffix,'he.bmp']));
        meng = im2double(imread([picName,suffix,'meng.bmp']));
        berman = im2double(imread([picName,suffix,'berman.bmp']));
        mscnn = im2double(imread([picName,suffix,'MSCNN.bmp']));
        AOD = im2double(imread([picName,suffix,'AOD.bmp']));
        DCPCN = im2double(imread([picName,suffix,'DCPCN.png']));
        DehazeNet = im2double(imread([picName,suffix,'DehazeNet.bmp']));
        ourEM = im2double(imread([picName,suffix,'em.bmp']));
        ourWDC = im2double(imread([picName,suffix,'wdc.bmp']));
        ourCWDC = im2double(imread([picName,suffix,'cwdc.bmp']));
        
        % methods = "mse","CIEDE2000","ssim","ms-ssim","VIF","iw-ssim","RFSIM","FSIM","FSIMc"
        methods = 'mse';
        score_he = IQAmethods(GT,he,methods);
        score_meng = IQAmethods(GT,meng,methods);
        score_berman = IQAmethods(GT,berman,methods);
        score_mscnn = IQAmethods(GT,mscnn,methods);
        score_AOD = IQAmethods(GT,AOD,methods);
        score_DCPCN = IQAmethods(GT,DCPCN,methods);
        score_DehazeNet = IQAmethods(GT,DehazeNet,methods);
        score_ourEM = IQAmethods(GT,ourEM,methods);
        score_ourWDC = IQAmethods(GT,ourWDC,methods);
        score_ourCWDC = IQAmethods(GT,ourCWDC,methods);

        score = [score;score_he, score_berman, score_meng, score_mscnn, score_AOD, score_DCPCN, score_DehazeNet, score_ourEM, score_ourWDC, score_ourCWDC];
    end
end

score_mean = mean(score);
score_median = median(score);
score_sta = [score_mean;score_median];
