%% estimate A based on Retinex Theory
% I, input image
% A, air color
function [ A ] = wdc_airLight( I, r )
    if nargin < 2
        r = ceil(0.05*min(size(I,1),size(I,2)));
    end
    A = wdc_atmosphere(im2double(I), wdc_dx(I, 2, r));
end

