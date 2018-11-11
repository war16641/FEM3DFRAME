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

function test_verifymodel2(testcase)
%��֤ģ��2
f=FEM3DFRAME();
f.node.AddByCartesian(1001,0,0,0);
f.node.AddByCartesian(1002,1.14,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1001 1002],sec);
tmp.GetKel()
end