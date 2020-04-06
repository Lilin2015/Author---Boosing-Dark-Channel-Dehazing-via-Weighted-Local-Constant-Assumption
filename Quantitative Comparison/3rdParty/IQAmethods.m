function score = IQAmethods( img1, img2, method )
img1 = im2double(img1);
img2 = im2double(img2);
img2 = imresize(img2,[size(img1,1),size(img1,2)]);

if strcmp(method,'ms-ssim')
    img1 = rgb2gray(img1);
    img2 = rgb2gray(img2);
    score = msssim(255*img1,255*img2);
end
if strcmp(method,'ssim')
    score = ssim(rgb2gray(img1),rgb2gray(img2));
end
if strcmp(method,'mse')
    score = Lee_MSE(img1,img2);
end
if strcmp(method,'CIEDE2000')
    img1 = rgb2lab(img1);
    img2 = rgb2lab(img2);
    img1 = reshape(img1,[size(img1,1)*size(img1,2),3]);
    img2 = reshape(img2,[size(img2,1)*size(img2,2),3]);
    score = deltaE2000(img1,img2);
end
if strcmp(method,'FSIM')
    [score,~] = FeatureSIM(255*img1,255*img2);
end
if strcmp(method,'FSIMc')
    [~,score] = FeatureSIM(255*img1,255*img2);
end
if strcmp(method,'RFSIM')
    score = RFSIM(img1,img2);
end
if strcmp(method,'IW-SSIM')
    score = iwssim(img1,img2);
end
if strcmp(method,'VIF')
    score = vifvec(255*rgb2gray(img1),255*rgb2gray(img2));
end
if strcmp(method,'iw-ssim')
    score = iwssim(255*rgb2gray(img1),255*rgb2gray(img2));
end

end

