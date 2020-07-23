function [I,I0,err,exp,k] = quad_Romberg(f,a,b,eps)
% ���ܣ�����Romberg�㷨����������������ڸ��������ϸ������ȵĻ��֣�������������������
% �����������������f����������[a,b]�����㾫��eps(Ĭ��Ϊ1e-7)
% �����������ֵ����ֵI����ȷ����ֵI0�����ּ������err���������� k.[��������ʱ��"tic-toc"]
% ��������˵����
%   [1]���ű�����
%       ����f(x)���Ա���     x
%   [2]��ֵ������
%       �������             h(:)
%       ������е����       H(:)
%       ���ι�ʽ�������ֵ   T(:,1)
%       Romberg���ٵ���ֵ    T(:,n)[���У�n>1]
%       ��ֵ����ֵ           I
%       ��ȷ����ֵ           I0
%       ���ּ������         err
tic
if nargin == 3
    eps = 1e-7;
end
% Ԥ�����ڴ�
H = zeros(50,1);
T = zeros(50);
h = zeros(50,1);
% ������ֵ����
T01 = (b-a) * (f(a) + f(b)) / 2;
h0 = b - a;
H0 = f(a + h0/2);
k = 1;
T(k,1) = (T01+h0*H0)/2;
T(k,k+1) = (4*T(k,1)-T01)/3;
error = abs(T01 - T(k,k+1));
% Romberg��������
while (error >= eps)
    % �Ⱦ�����������
    h(k) = (b - a)/(2^k);
    H(k) = 0;
    for l = 1:1:2^k
        H(k) = H(k) + f(a + (l-1/2)*h(k));
    end
    T(k+1,1) = (T(k,1)+h(k)*H(k))/2;
    % Richardson����
    for j = 1:1:(k+1)
        T(k+1,j+1) = (4^j * T(k+1,j) - T(k,j))/(4^j - 1);
    end
    error = abs(T(k,k+1) - T(k+1,k+2));
    k = k + 1;
    if k > 50
        error('�������ܲ�������');
    end
end
if k > 1
    k = k - 1;
end
I   = vpa(T(k,k+1));
I0  = int(f,symvar(sym(f)),a,b);
err = vpa(abs(I-I0));
exp = log10(err);
toc
end