function [dtheta] = VFD01_plotsurf_rec(a,b,n,N)
% -------------�������-------------
%   a   �Ӵ���
%   b   �������� b:=rho*g*L^2/gamma
%    ���У�
%     �ܶ�         rho  1000(ˮ) 
%     �������ٶ�    g    9.8
%     ��������      L    0.001
%     ��������ϵ�� gamma 0.0728(ˮ-����)
%   n   Plot footstep length
%   N   Verification footstep length
% -------------�������-------------
%   dtheta  �Ӵ������
% ---------------end---------------
global const alpha sigma
alpha = a;
sigma = b;
% calculate the initial value of z and the integral constant
z0    = sqrt(2*(1 - sin(alpha))/sigma);
sq0   = sqrt(1-sigma*z0*z0/4);
const = - log(1+sq0) + 2*sq0 + log(z0);
% plot the curve
x = zeros(1,n);
y = zeros(1,n);
d = z0/n;
for i = 1:n
    y(i) = z0 - d*(i-1);
    x(i) = leng(y(i));
end
plot(x,y);
% verificate the curve
y1 = z0;
y2 = z0 - 1/N;
x1 = leng(y1);
x2 = leng(y2);
dtheta = atan((x2-x1)/(y1-y2)) - alpha;
end

function [x] = leng(z)
global const sigma
% define the curve
sq = sqrt(1-sigma*z*z/4);
x  = (log(1+sq) - 2*sq - log(z) + const)/sqrt(sigma);
end

