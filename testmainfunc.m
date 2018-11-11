function tests=testmainfunc()
%测试函数
tests=functiontests(localfunctions);
end
function test1(testcase)
f=FEM3DFRAME();
f.node.AddByCartesian(0,1,1,1);
f.node.AddByCartesian(0,2,1,1);
f.node.AddByCartesian(0,3,1,1);
testcase.verifyTrue(f.node.ndnum==3,'添加节点错误（不指定id)');
testcase.verifyTrue(f.node.maxnum==3,'添加节点错误（不指定id)');
testcase.verifyTrue(f.node.nds(end,1)==3,'添加节点错误（不指定id)');

%指定id 添加
f.node.AddByCartesian(4,4,1,1);
testcase.verifyTrue(f.node.ndnum==4,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.maxnum==4,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.nds(end,1)==4,'添加节点错误（指定id)');

%不按连续编号添加
f.node.AddByCartesian(10,10,1,1);
testcase.verifyTrue(f.node.ndnum==5,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.nds(end,1)==10,'添加节点错误（指定id)');

%插入一个节点至空白处
f.node.AddByCartesian(5,5,1,1);
testcase.verifyTrue(f.node.ndnum==6,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.nds(end-1,1)==5,'添加节点错误（指定id)');

%插入一个节点至有值处
f.node.AddByCartesian(5,5,2,1);
testcase.verifyTrue(f.node.ndnum==6,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
testcase.verifyTrue(f.node.nds(end-1,3)==2,'添加节点错误（指定id)');
f.node.AddByCartesian(11,1,1,2);

%添加材料
f.manager_mat.Add(1,0.2,1,'concrete');
f.manager_mat.objects(1)
testcase.verifyTrue(strcmp(f.manager_mat.objects(1).name,'concrete'),'添加材料错误');
f.manager_mat.Add(10,0.2,1,'steel');
tmp=f.manager_mat.GetByIndex(2);
testcase.verifyTrue(strcmp(tmp.name,'steel'),'添加材料错误');
tmp=f.manager_mat.GetByIdentifier('concrete');
testcase.verifyTrue(tmp.E==1,'添加材料错误');
tmp=MATERIAL(2,0.2,1,'c30');
f.manager_mat.Add(tmp);
tm=f.manager_mat.GetByIdentifier('c30');
testcase.verifyTrue(tm.v==0.2,'添加材料错误');
tmp=f.manager_mat.GetByIdentifier('c50');
testcase.verifyTrue(isempty(tmp),'添加材料错误');

%添加截面
% mat=f.manager_mat.objects(1);
% f.manager_sec.Add('pile',mat,1,1,1);
% f.manager_sec.Add('cap',mat,2,2,2);
% tmp=SECTION('girder',mat,3,3,3);
% f.manager_sec.Add(tmp);
% tmp=f.manager_sec.GetByIndex(1);
% testcase.verifyTrue(tmp.A==1,'添加截面错误');
% tmp=f.manager_sec.GetByIdentifier('cap');
% testcase.verifyTrue(tmp.A==2,'添加截面错误');
% tmp=f.manager_sec.GetByIdentifier('girder');
% testcase.verifyTrue(tmp.A==3,'添加截面错误');
% tmp=f.manager_sec.GetByIdentifier('cap1');
% testcase.verifyTrue(isempty(tmp),'添加截面错误');
% tmp=SECTION('girder',mat,300,3,3);
% testcase.verifyWarning(@()f.manager_sec.Add(tmp),'MATLAB:mywarning');
% f.manager_sec.flag_overwrite=f.manager_sec.OVERWRITE_FALSE;
% f.manager_sec.Add(tmp);
% testcase.verifyFalse(300==f.manager_sec.objects(3).A,'添加截面错误');
% f.manager_sec.flag_overwrite=1;
% f.manager_sec.Add(tmp);
% testcase.verifyTrue(300==f.manager_sec.objects(3).A,'添加截面错误');
mat=f.manager_mat.objects(1);
f.manager_sec.Add('pile',mat,1,1,1);
f.manager_sec.Add('cap',mat,2,2,2);
tmp=SECTION('girder',mat,3,3,3);
f.manager_sec.Add(tmp);
tmp=f.manager_sec.GetByIndex(1);
testcase.verifyTrue(tmp.A==2,'添加截面错误');
tmp=f.manager_sec.GetByIdentifier('cap');
testcase.verifyTrue(tmp.A==2,'添加截面错误');
tmp=f.manager_sec.GetByIdentifier('girder');
testcase.verifyTrue(tmp.A==3,'添加截面错误');
tmp=f.manager_sec.GetByIdentifier('cap1');
testcase.verifyTrue(isempty(tmp),'添加截面错误');
tmp=SECTION('girder',mat,300,3,3);
testcase.verifyWarning(@()f.manager_sec.Add(tmp),'MATLAB:mywarning');
f.manager_sec.flag_overwrite=f.manager_sec.OVERWRITE_FALSE;
f.manager_sec.Add(tmp);
testcase.verifyFalse(300==f.manager_sec.objects(2).A,'添加截面错误');
f.manager_sec.flag_overwrite=1;
f.manager_sec.Add(tmp);
testcase.verifyTrue(300==f.manager_sec.objects(2).A,'添加截面错误');

%添加单元
sec=f.manager_sec.GetByIndex(1);
tmp=ELEMENT_EULERBEAM(f,1,[2 1],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue(1==f.manager_ele.maxnum,'添加单元错误');
testcase.verifyError(@()f.manager_ele.Add(f,2,[1 2],sec),'MATLAB:myerror','添加单元错误');
testcase.verifyError(@()f.manager_ele.Add(f,2,[1 2]),'MATLAB:myerror','添加单元错误');
testcase.verifyError(@()ELEMENT_EULERBEAM(f,1,[1 6],sec),'MATLAB:myerror','添加单元错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((2==f.manager_ele.num)&&(2==f.manager_ele.maxnum),'添加单元错误');
tmp=ELEMENT_EULERBEAM(f,10,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((3==f.manager_ele.num)&&(10==f.manager_ele.maxnum),'添加单元错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 10],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue((4==f.manager_ele.num)&&(11==f.manager_ele.maxnum),'添加单元错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 11],sec);
f.manager_ele.Add(tmp);



%验证方向向量
f.node.AddByCartesian(100,0,0,0);
f.node.AddByCartesian(101,1,0,1);
tmp=ELEMENT_EULERBEAM(f,0,[100 101],sec);
f.manager_ele.Add(tmp);
testcase.verifyTrue(norm(f.manager_ele.objects(end).zdir-[-1/sqrt(2) 0 1/sqrt(2)])<1e-10,'添加单元错误');
tmp=ELEMENT_EULERBEAM(f,0,[100 101],sec,[0 1 0]);
f.manager_ele.Add(tmp);
testcase.verifyTrue(norm(f.manager_ele.objects(end).zdir-[0 1 0])<1e-10,'添加单元错误');


end

function test_verifymodel2(testcase)
%验证模型2
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