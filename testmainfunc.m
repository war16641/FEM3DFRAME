function tests=testmainfunc()
%���Ժ���
tests=functiontests(localfunctions);
end
function test1(testcase)
f=FEM3DFRAME();
f.node.AddByCartesian(0,1,1,1);
f.node.AddByCartesian(0,2,1,1);
f.node.AddByCartesian(0,3,1,1);
testcase.verifyTrue(f.node.ndnum==3,'��ӽڵ���󣨲�ָ��id)');
testcase.verifyTrue(f.node.maxnum==3,'��ӽڵ���󣨲�ָ��id)');
testcase.verifyTrue(f.node.nds(end,1)==3,'��ӽڵ���󣨲�ָ��id)');

%ָ��id ���
f.node.AddByCartesian(4,4,1,1);
testcase.verifyTrue(f.node.ndnum==4,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.maxnum==4,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.nds(end,1)==4,'��ӽڵ����ָ��id)');

%��������������
f.node.AddByCartesian(10,10,1,1);
testcase.verifyTrue(f.node.ndnum==5,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.maxnum==10,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.nds(end,1)==10,'��ӽڵ����ָ��id)');

%����һ���ڵ����հ״�
f.node.AddByCartesian(5,5,1,1);
testcase.verifyTrue(f.node.ndnum==6,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.maxnum==10,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.nds(end-1,1)==5,'��ӽڵ����ָ��id)');

%����һ���ڵ�����ֵ��
f.node.AddByCartesian(5,5,2,1);
testcase.verifyTrue(f.node.ndnum==6,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.maxnum==10,'��ӽڵ����ָ��id)');
testcase.verifyTrue(f.node.nds(end-1,3)==2,'��ӽڵ����ָ��id)');
f.node.AddByCartesian(11,1,1,2);

%��Ӳ���
f.manager_mat.Add(1,0.2,1,'concrete');
f.manager_mat.objects(1)
testcase.verifyTrue(strcmp(f.manager_mat.objects(1).name,'concrete'),'��Ӳ��ϴ���');
f.manager_mat.Add(10,0.2,1,'steel');
tmp=f.manager_mat.GetByIndex(2);
testcase.verifyTrue(strcmp(tmp.name,'steel'),'��Ӳ��ϴ���');
tmp=f.manager_mat.GetByIdentifier('concrete');
testcase.verifyTrue(tmp.E==1,'��Ӳ��ϴ���');
tmp=MATERIAL(2,0.2,1,'c30');
f.manager_mat.Add(tmp);
tm=f.manager_mat.GetByIdentifier('c30');
testcase.verifyTrue(tm.v==0.2,'��Ӳ��ϴ���');
tmp=f.manager_mat.GetByIdentifier('c50');
testcase.verifyTrue(isempty(tmp),'��Ӳ��ϴ���');

%��ӽ���
% mat=f.manager_mat.objects(1);
% f.manager_sec.Add('pile',mat,1,1,1);
% f.manager_sec.Add('cap',mat,2,2,2);
% tmp=SECTION('girder',mat,3,3,3);
% f.manager_sec.Add(tmp);
% tmp=f.manager_sec.GetByIndex(1);
% testcase.verifyTrue(tmp.A==1,'��ӽ������');
% tmp=f.manager_sec.GetByIdentifier('cap');
% testcase.verifyTrue(tmp.A==2,'��ӽ������');
% tmp=f.manager_sec.GetByIdentifier('girder');
% testcase.verifyTrue(tmp.A==3,'��ӽ������');
% tmp=f.manager_sec.GetByIdentifier('cap1');
% testcase.verifyTrue(isempty(tmp),'��ӽ������');
% tmp=SECTION('girder',mat,300,3,3);
% testcase.verifyWarning(@()f.manager_sec.Add(tmp),'MATLAB:mywarning');
% f.manager_sec.flag_overwrite=f.manager_sec.OVERWRITE_FALSE;
% f.manager_sec.Add(tmp);
% testcase.verifyFalse(300==f.manager_sec.objects(3).A,'��ӽ������');
% f.manager_sec.flag_overwrite=1;
% f.manager_sec.Add(tmp);
% testcase.verifyTrue(300==f.manager_sec.objects(3).A,'��ӽ������');
mat=f.manager_mat.objects(1);
f.manager_sec.Add('pile',mat,1,1,1);
f.manager_sec.Add('cap',mat,2,2,2);
tmp=SECTION('girder',mat,3,3,3);
f.manager_sec.Add(tmp);
tmp=f.manager_sec.GetByIndex(1);
testcase.verifyTrue(tmp.A==2,'��ӽ������');
tmp=f.manager_sec.GetByIdentifier('cap');
testcase.verifyTrue(tmp.A==2,'��ӽ������');
tmp=f.manager_sec.GetByIdentifier('girder');
testcase.verifyTrue(tmp.A==3,'��ӽ������');
tmp=f.manager_sec.GetByIdentifier('cap1');
testcase.verifyTrue(isempty(tmp),'��ӽ������');
tmp=SECTION('girder',mat,300,3,3);
testcase.verifyWarning(@()f.manager_sec.Add(tmp),'MATLAB:mywarning');
f.manager_sec.flag_overwrite=f.manager_sec.OVERWRITE_FALSE;
f.manager_sec.Add(tmp);
testcase.verifyFalse(300==f.manager_sec.objects(2).A,'��ӽ������');
f.manager_sec.flag_overwrite=1;
f.manager_sec.Add(tmp);
testcase.verifyTrue(300==f.manager_sec.objects(2).A,'��ӽ������');

%��ӵ�Ԫ
sec=f.manager_sec.GetByIndex(1);
tmp=ELEMENT_EULERBEAM(f,1,[2 1],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue(1==f.manager_ele.maxnum,'��ӵ�Ԫ����');
testcase.verifyError(@()f.manager_ele.Add(f,2,[1 2],sec),'MATLAB:myerror','��ӵ�Ԫ����');
testcase.verifyError(@()f.manager_ele.Add(f,2,[1 2]),'MATLAB:myerror','��ӵ�Ԫ����');
testcase.verifyError(@()ELEMENT_EULERBEAM(f,1,[1 6],sec),'MATLAB:myerror','��ӵ�Ԫ����');
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((2==f.manager_ele.num)&&(2==f.manager_ele.maxnum),'��ӵ�Ԫ����');
tmp=ELEMENT_EULERBEAM(f,10,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((3==f.manager_ele.num)&&(10==f.manager_ele.maxnum),'��ӵ�Ԫ����');
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((4==f.manager_ele.num)&&(11==f.manager_ele.maxnum),'��ӵ�Ԫ����');
tmp=ELEMENT_EULERBEAM(f,0,[1 11],sec);
f.manager_ele.Add(tmp);



%��֤��������
f.node.AddByCartesian(100,0,0,0);
f.node.AddByCartesian(101,1,0,1);
tmp=ELEMENT_EULERBEAM(f,0,[100 101],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue(norm(f.manager_ele.objects(end).zdir-[-1/sqrt(2) 0 1/sqrt(2)])<1e-10,'��ӵ�Ԫ����');
tmp=ELEMENT_EULERBEAM(f,0,[100 101],sec,[0 1 0]);
f.manager_ele.Add(tmp);
testcase.verifyTrue(norm(f.manager_ele.objects(end).zdir-[0 1 0])<1e-10,'��ӵ�Ԫ����');


end
function test_verifymodel1(testcase)
%��֤ģ��1 ������ 2�ڵ�
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%ʵ�������д���ڵ�ĵ�Ԫ
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','��֤����');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%ָ��z����Ϊ-y����
f.manager_ele.Add(tmp);
%���ô���Ľڵ�߽����� �ڵ㲻����
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','��֤����');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%���ҽڵ�ʩ������λ�� uyλ��

f.Solve();
rea1=[-6.55	-10.67	6.63	5.33	-7.05	-6.08];
rea2=[6.55	10.67	-6.63	5.33	-7.05	-6.08];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end


function test_verifymodel2(testcase)
%��֤ģ��2 ������ 2�ڵ�
f=FEM3DFRAME();
f.node.AddByCartesian(1001,0,0,0);
f.node.AddByCartesian(1002,1.14,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]);%ָ��z����Ϊ-y����
f.manager_ele.Add(tmp);
f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[1002 1 1;1002 2 1;1002 3 0;1002 4 0;1002 5 0; 1002 6 0;]);%���ҽڵ�ʩ������λ�� uyλ��
f.Solve();
rea1=[-0.96 -25.11 0  0  0 -14.31 ];
rea2=[0.96 25.11 0  0  0 -14.31 ];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end
function test_verifymodel3(testcase)
%��֤ģ��3 ��1��ģ�ͻ����Ͻ�z�����Ϊz��
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%ʵ�������д���ڵ�ĵ�Ԫ
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','��֤����');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%ָ��z����Ϊz����
f.manager_ele.Add(tmp);
%���ô���Ľڵ�߽����� �ڵ㲻����
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','��֤����');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%���ҽڵ�ʩ������λ�� uyλ��

f.Solve();
rea1=[-5.05	-14.11	4.93	7.05	-5.33	-8.04];
rea2=[5.05	14.11	-4.93	7.05	-5.33	-8.04];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end
function test_verifymodel4(testcase)
%��֤ģ��4 ��3��ģ�� ���ظ�Ϊj�ڵ�����λ��Ϊ1
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%ʵ�������д���ڵ�ĵ�Ԫ
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','��֤����');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%ָ��z����Ϊz����
f.manager_ele.Add(tmp);
%���ô���Ľڵ�߽����� �ڵ㲻����
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','��֤����');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%���ҽڵ�ʩ������λ�� uyλ��

f.Solve();
rea1=[5.21	-13.12	-7.5	2.94	4.84	-10.99];
rea2=[-5.21	13.12	7.5	10.19	8.92	-3.97];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end
function test_verifymodel5(testcase)
%��֤ģ��5 ��3��ģ�� ���ظ�Ϊj�ڵ�������Ϊ1
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%ʵ�������д���ڵ�ĵ�Ԫ
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','��֤����');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%ָ��z����Ϊz����
f.manager_ele.Add(tmp);
%���ô���Ľڵ�߽����� �ڵ㲻����
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','��֤����');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('force',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%���ҽڵ�ʩ������λ�� uyλ��

f.Solve();
rea1=[-1	-1	-1	0	-0.86	-2.14];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
displ2=[1.684273	0.309404	1.030101	0.089553	0.454933	0.497021];
testcase.verifyTrue(norm(f.node.nds_displ(2,2:7)-displ2)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_displ(1,2:7))<0.0001,'��֤����');
end
function test_verifymodel6(testcase)
%��֤ģ��6 ����ģ�� ������ 2�ڵ� j����1 2 0 ���淽��x
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[1 0 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 1;2 2 0;2 3 0;2 4 0;2 5 0;2 6 0;]);%���ҽڵ�ʩ��

f.Solve();
rea1=[-2.76	1.13	0	0	0	3.33];
rea2=[2.76	-1.13	0	0	0	3.33];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end
function test_verifymodel7(testcase)
%��֤ģ��7 ��ģ��6�Ļ�����ʩ������λ��1����
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[1 0 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%���ҽڵ�ʩ��

f.Solve();



rea1=[-4.95	1.74	-2.2	-4.39	-1.44	4.44];
rea2=[4.95	-1.74	2.2	-0.01342	3.64	7.21];%֧���������۽�sap2000�õ���
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'��֤����');
end
function test_verifymodel8(testcase)
%��֤ģ��8 ���� j����1 2 3 λ��Ϊ����1 ����z��
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('displ',[2 1 0;2 2 0;2 3 1;2 4 0;2 5 0;2 6 0;]);%���ҽڵ�ʩ��

f.Solve();
testcase.verifyTrue(norm(f.node.nds_force(2,4)-0.4426)<0.01,'��֤����');

end
function test_verifymodel9(testcase)
%��֤ģ��9 ������ һ��z�� һ��y�� ����Ϊfx=1 �����۶�
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,3);
f.node.AddByCartesian(3,0,5,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%�̽���ڵ�
f.bc.Add('force',[3 1 1;]);%���ҽڵ�ʩ��

f.Solve();
testcase.verifyTrue(norm(f.node.nds_force(1,2)+1)<0.01,'��֤����');%1�ڵ�ux����
testcase.verifyTrue(norm(f.node.nds_force(1,6)+3)<0.01,'��֤����');%1�ڵ�ry����
r=[26.203877	0	2.007E-16	6.022E-17	1.097561	-5.818011];
testcase.verifyTrue(norm(f.node.nds_displ(3,2:7)-r)<0.01,'��֤����');
end
function test_verifymodel10(testcase)
%��֤ģ��10 ��9�Ļ����� ���ڵ�2��ux�̶� ��������
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,3);
f.node.AddByCartesian(3,0,5,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[2 1 0;]);
f.bc.Add('force',[3 1 1;]);

f.Solve();

r=[24.008755	0	2.007E-16	6.022E-17	0	-5.818011];
testcase.verifyTrue(norm(f.node.nds_displ(3,2:7)-r)<0.01,'��֤����');
end
function test_verifymodel_11(testcase)
%��֤ģ��11 ��֤�˶��ͷ�
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.2,0,0);
f.node.AddByCartesian(3,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'i');%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
f.bc.Add('force',[2 2 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,3)-0.1335)<0.01,'��֤����');
end
function test_verifymodel_12(testcase)
%��֤ģ��12 ��֤�˶��ͷ�
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,1.3);
f.node.AddByCartesian(3,3,0,1.3);
f.node.AddByCartesian(4,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'ij');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[0 -1 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[4 1 0;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
f.bc.Add('force',[2 1 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,2)-0.1683)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_displ(3,2)-0.0103)<0.01,'��֤����');
end
function test_verifymodel_13(testcase)
%��֤ģ��13 δ����Ԫ��������ɶ��ϼ���
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.2,0,0);
f.node.AddByCartesian(3,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'i');%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
f.bc.Add('force',[2 2 1;]);
f.bc.Add('force',[2 2 5;]);

testcase.verifyError(@()f.Solve(),'matlab:myerror','��֤����');
end
function test_verifymodel_14(testcase)
%��֤ģ��14 ��12ģ����ͬʱʩ������λ��
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,1.3);
f.node.AddByCartesian(3,3,0,1.3);
f.node.AddByCartesian(4,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'ij');%ָ��z����Ϊ
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[0 -1 0]);%ָ��z����Ϊ
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[4 1 1;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
f.bc.Add('force',[2 1 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,2)-0.2262)<0.01,'��֤����');
testcase.verifyTrue(norm(f.node.nds_displ(3,2)-0.9524)<0.01,'��֤����');
end