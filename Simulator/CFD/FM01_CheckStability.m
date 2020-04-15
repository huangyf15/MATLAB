function FM01_CheckStability(b,d1,d2,n)
% ������ճ�����±߽���������ȶ��ԣ�
%        { 2by,               0 <= y <= 1/2 (��) 
% U(y) = { 2(1-b)y+2b-1,     1/2 < y <= 1   (��)
%        { 1,                      y > 1    (��)
% ����˵����
%   d1��d2       ����˵�
%   n            ��ͼ�ڵ���
%   b            ����������b<0.5��Ӧ�йյ��ٶ����棬b>0.5��Ӧ�޹յ��ٶ����棩
l   = length(b);
a   = zeros(n,1);
a0  =    0;
b1  =  1.5;
b2  = -1.5;
sym = zeros(n,l);
for j = 1:l
    for i = 1:n
        a(i) = d1 + i/n*(d2-d1);
        K1   = (2*b(j)-1)/a(i);
        K2   = exp(a(i))/(1-exp(a(i)));
        K3    = 1 - b(j);
        a1   = a(i)*K2/K3;
        a2   = (-exp(-a(i))+a(i)-1)*K2+exp(-a(i));
        a3   = ( exp(-a(i))+a(i)-1)*K1;
        delta = (a2)^2 - 4*a1*a3;
        if delta >= 0
            sym(i,j)  =  1 - j/(2*l);
        else
            sym(i,j)  = -1 + j/(2*l);
        end
    end
end
plot(a0,b1,a0,b2);
hold on
for k = 1:l
    if sym(:,k) > 0
        p(k) = plot(a,sym(:,k),'k');
    else
        p(k) = plot(a,sym(:,k),'g');
    end
end
legend([p],...
    ['b(1) = ',num2str(b(1))], ...
    ['b(2) = ',num2str(b(2))]);
% legend([p(1),p(2)],['b(1) = ',num2str(b(1))],['b(2) = ',num2str(b(2))]);
title({'��άƽ��߽�������ȶ���';'(Note.sym>0Ϊ�ȶ�����)'});
xlabel('\alpha');
ylabel('sym');
end