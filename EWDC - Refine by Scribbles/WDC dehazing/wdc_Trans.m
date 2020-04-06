function T = wdc_Trans( Iw, r, lambda, ref_map )
    if ~exist('r','var') || isempty(r)
        r = ceil(0.05*min(size(Iw,1),size(Iw,2)));
    end
    if ~exist('lambda','var') || isempty(lambda)
        lambda = 0.02;
    end
    if ~exist('ref_map','var') || isempty(ref_map)
        ref_map = 1 - wdc_dx(Iw,2,r);
    end
    
    B = 1 - wdc_dx(Iw,1);
    mask = 1./max(( B - ref_map).^2,0.001)/1000;
    
    c = size(Iw,3);
    if c==1
        T = wls_optimization(ref_map, mask, repmat(Iw,[1,1,3]), lambda);
    elseif c==3
        T = wls_optimization(ref_map, mask, Iw, lambda);
    end
    T = max(B,T);
end

