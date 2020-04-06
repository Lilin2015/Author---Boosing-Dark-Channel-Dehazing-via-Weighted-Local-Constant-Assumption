%% a tool
% I, input image
% step, 1 - D is the minimal map of each channel.
%       2 - D is eroded.
% r, mask radius
function [ D ] = wdc_dx( I, step, r )
    %% prepare
    [m,n,c] = size(I);
    if nargin <= 2
        r = ceil(0.05*min(m,n));
    end
    if nargin <= 1
        step = 1;
    end
    
    %% step 1. channel min only
    if c == 1
        B = I;
    else
        B = min(I(:,:,1),I(:,:,2));
        B = min(I(:,:,3),B);
    end
    if step <= 1
        D = B;
        return;
    end
    
    %% step 2. erode
    se=strel('disk',r);
    D=imerode(B,se);
    if step <= 2
        return;
    end
end

