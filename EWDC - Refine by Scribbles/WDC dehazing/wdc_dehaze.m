function [J, T] = wdc_dehaze( img_in, ref_map )
    I = im2double(img_in);
    I(I>1)=0; I(I<0)=0;
    if exist('ref_map','var')
        [J, T, ~] = wdc_hazeFree(I, [], ref_map);
    else
        [J, T, ~] = wdc_hazeFree(I);
    end
end

