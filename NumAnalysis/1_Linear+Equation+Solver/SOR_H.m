function SOR_H(n,w,eps)
H = ones(n);
x_0 = ones(n,1);
for i=1:1:n
    for j=1:1:n   
        H(i,j)=1/(i+j-1);
    end
end
b = H * x_0;
% ���ò��������б�Ҫ�ĸ�ֵ
if nargin==2
    eps=1.0e-8;
elseif nargin<2
    error('�������̫�٣�');
end
if(w<=0 || w>=2)
    error('������� w �ķ�Χ����');
end
x0 = zeros(n,1);
D = diag(diag(H));
L = -tril(H,-1);
% SOR����
f = w*((D-L*w)\b);
x_1 = (D-L*w)*((1-w)*D+w*L')\x0+f;
n_1 = 1;
while norm(x_1-x0) >= eps
    x0 = x_1;
    x_1 = B*x0+f;
    n_1 = n_1+1;
    if(n_1>3.0e6)
        disp('Warning:��������̫�࣬Ч�ʹ���')
        return;
    end
end
n_1
err = norm(x_1-x_0)
err1 = norm(x_1-x0)
end

