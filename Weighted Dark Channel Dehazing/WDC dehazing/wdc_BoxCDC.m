function out = wdc_BoxCDC( in, data_weight, guidance, b, lambda )

%% param set
if size(guidance,3) == 1, guidance = repmat(guidance,[1,1,3]); end;
small_num = 0.00001;
if ~exist('lambda','var') || isempty(lambda), lambda = 0.05; end

%% matrix construction
[h,w,~] = size(guidance); k = h*w;
guidance = rgb2gray(guidance);

% Compute affinities between adjacent pixels based on gradients of guidance
jump=1;
dy = diff(guidance, 1, 1);  dy(dy>jump)=1;
dy = -lambda./(sum(abs(dy).^2,3) + small_num);
dy = padarray(dy, [1 0], 'post');
dy = dy(:);

dx = diff(guidance, 1, 2);  dx(dx>jump)=1;
dx = -lambda./(sum(abs(dx).^2,3) + small_num);
dx = padarray(dx, [0 1], 'post');
dx = dx(:);

% Construct a five-point spatially inhomogeneous Laplacian matrix
B = [dx, dy];
d = [-h,-1];
tmp = spdiags(B,d,k,k);

ea = dx;
we = padarray(dx, h, 'pre'); we = we(1:end-h);
so = dy;
no = padarray(dy, 1, 'pre'); no = no(1:end-1);

D = -(ea+we+so+no);
Asmoothness = tmp + tmp' + spdiags(D, 0, k, k);

data_weight = data_weight+small_num;

Adata = spdiags(data_weight(:), 0, k, k);

%% Param set
W = Adata;
L = Asmoothness;
t = in(:);
b = b(:);
num = size(t,1);
%% Standard form
Q = 2*(W+L);
c = 2*(b-t)'*W+2*b'*L;
x = ones(size(t));         % x initial 1
%% Newton Step
v = 0.0001; 
% sort
d = ones(size(x));
while max(abs(d))>0.0001
    % sort active or inactive
    y = v*(Q*x+c');
    active_set = find(x<=y);     act_num = size(active_set,1);
    inactive_set = find(x>y);
    % get d
    Qeye = speye(num);
    Qs = Q(:,[active_set;inactive_set]);
    Qs = Qs([active_set;inactive_set],:);
    Qs = v*Qs;
    Qs(1:act_num,:) = Qeye(1:act_num,:);
    xs = [x(active_set);y(inactive_set)];
    d = -Qs\xs; d([active_set;inactive_set]) = d;
    x = x + d;
end
out = reshape(x+b,size(guidance));
end

