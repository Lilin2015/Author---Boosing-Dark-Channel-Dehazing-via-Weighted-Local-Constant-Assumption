function e = corr( img1_filename, img2_filename )

    img1 = im2double(imread(img1_filename));
    img2 = im2double(imread(img2_filename));
%     img1 = imresize(img1,[500,500]);
%     img2 = imresize(img2,[500,500]);
    x1 = reshape(img1,[size(img1,1)*size(img1,2)*3,1]);
    x2 = reshape(img2,[size(img2,1)*size(img2,2)*3,1]);
    e = min(min(corrcoef(x1, x2)));
%     a = rgb2gray(img1);
%     b = rgb2gray(img2);
%     a = a - mean2(a);
%     b = b - mean2(b);
%     e = sum(sum(a.*b))/sqrt(sum(sum(a.*a))*sum(sum(b.*b)));

end

