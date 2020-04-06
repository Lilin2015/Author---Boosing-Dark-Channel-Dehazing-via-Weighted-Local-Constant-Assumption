function [ J, T, A] = wdc_hazeFree( I, A, ref_map )
    
    if ~exist('A','var') || isempty(A)
        A = wdc_airLight(I);
    end
    Iw = wdc_whiteImage(I,A);    

    %% trans.
    Tr = wdc_Trans(Iw,[],[],ref_map);
    
    %% brighter
    haze_factor = 1.1;
    T = (Tr + (haze_factor-1) )/haze_factor;
    
    J = wdc_radiance(I,T,A);

end

