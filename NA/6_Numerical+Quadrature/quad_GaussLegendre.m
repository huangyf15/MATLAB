function [I,I0,err,exp] = quad_GaussLegendre(f,a,b,n,l)
% ���ܣ�����n��Gauss-Legendre�����ʽ��l�θ�����ʽ����������������ڸ��������ϵĻ��֣����������
% �����������������f����������[a,b]���ڵ�����n(Ĭ��Ϊ5)����������l(Ĭ��Ϊ4)
% �����������ֵ����ֵI����ȷ����ֵI0�����ּ������err.[��������ʱ��"tic-toc"]
% ��������˵����
%   [1]���ű�����
%       ����f(x)���Ա���     x
%       �滻��ı���         t
%       �����滻ʽx(t)       xt
%       �滻��ĺ���f(x(t))  ft
%   [2]��ֵ������
%       Legendre����ʽ���   x0
%       P'_n����㴦��ȡֵ   y1
%       P_n-1����㴦��ȡֵ  y2
%       ���ϵ��             A
%       ������˵�          [a1,b1]
%       f(x)����㴦��ȡֵ   f_x0
%       ��ֵ����ֵ           I
%       ��ȷ����ֵ           I0
%       ���ּ������         err
tic
if nargin == 4
    l = 4;
elseif nargin == 3
    n = 5;
    l = 4;
end
% Ԥ�����ڴ�
A = zeros(n,1);
f_x0 = zeros(n,1);
I = 0;
% ����Gauss������ϵ��
[x0,y1,y2] = Gauss(n);
for j = 1:1:n
   A(j) = 2 /(n * y1(j) * y2(j));
end
% ����n��Gauss-Legendre�������
for i = 1:1:l
    % ��[a,b]��Ϊl��������
    a1 = a + (i-1)/l * (b-a);
    b1 = a + i    /l * (b-a);
    % ͨ�������滻������������[a,b]��׼��Ϊ[-1,1]
    syms x xt t;
    x = symvar(sym(f));
    k = (b1-a1)/2;
    m = (b1+a1)/2;
    xt = k * t + m;
    ft = subs(f,x,xt);
    % ����Gauss�㴦��������ֵ
    for j = 1:1:n
        f_x0(j) = subs(ft, t ,x0(j));
    end
    % ������ֵ���ֽ�������뾫ȷֵ�Ƚ�
    I = I + k * dot(A,f_x0);
end
I0  = vpa(int(f,symvar(sym(f)),a,b));
err = vpa(abs(I - I0));
toc
exp = log10(err);
end

function [x0,Pn_prime,Pn_minus_1] = Gauss(n)
% Ԥ�����ڴ�
Pn_prime   = zeros(n,1);
Pn_minus_1 = zeros(n,1);
% ����n-1,n��Legendre����ʽ
an1  = 1/(2^(n-1) * factorial(n-1));
an   = an1 /(2 * n);
syms x;
Pnm1 = an1* diff((x^2-1)^(n-1),x,n-1);
Pn   = an * diff((x^2-1)^n,    x,n  );
Pnp  = an * diff((x^2-1)^n,    x,n+1);
% ����n��Legendre����ʽ��㼰���躯��ֵ
[x0] = solve(Pn);
for i = 1:1:n
    Pn_prime(i)   = subs(Pnp, x,x0(i));
    Pn_minus_1(i) = subs(Pnm1,x,x0(i));
end
end
