include_flags;

% �����������������Ŀ��Ҫ��Ϊż��
num = 100;
% �����������������(x0,y0)
[x0,y0] = airfoildata;

% ģ�͵��ҳ�
len  = max(x0)-min(x0);
% ��Զ��������ҳ�
fac  = 15;
% ������������ָ��
mag  = 1;

% ��������ksi[i=const,1:2*m+num+1], eta[j=const,1:n]
m = 50;
n = 100;
% Poisson ����Դ��ϵ��
% - Format: (fgksi, ksi, fgeta, eta, amplitude, decay factor)
attr_num = 3;
attr = [1,1,      0,1,    100,10
        1,m+1,    1,1,    10000,10
        1,m+num+1,1,1,    10,10];
% ����ָ�꣺ճ�ϵ���(1)/��(0)�����������
iterflag_glueline = 0;
% ����ָ�꣺β������(1)/��(0)�����������
iterflag_mode = 1;
% ����ָ�꣺������֮�������������
qual = 1e-2;