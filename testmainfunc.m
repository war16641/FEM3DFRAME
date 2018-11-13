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
function test_verifymodel1(testcase)
%验证模型1 单跨梁 2节点
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%实例化带有错误节点的单元
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','验证错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%指定z方向为-y方向
f.manager_ele.Add(tmp);
%设置错误的节点边界条件 节点不存在
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加轴向位移 uy位移

f.Solve();
rea1=[-6.55	-10.67	6.63	5.33	-7.05	-6.08];
rea2=[6.55	10.67	-6.63	5.33	-7.05	-6.08];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end


function test_verifymodel2(testcase)
%验证模型2 单跨梁 2节点
f=FEM3DFRAME();
f.node.AddByCartesian(1001,0,0,0);
f.node.AddByCartesian(1002,1.14,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]);%指定z方向为-y方向
f.manager_ele.Add(tmp);
f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]);%固接左节点
f.bc.Add('displ',[1002 1 1;1002 2 1;1002 3 0;1002 4 0;1002 5 0; 1002 6 0;]);%对右节点施加轴向位移 uy位移
f.Solve();
rea1=[-0.96 -25.11 0  0  0 -14.31 ];
rea2=[0.96 25.11 0  0  0 -14.31 ];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end
function test_verifymodel3(testcase)
%验证模型3 在1的模型基础上将z方向改为z向
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%实例化带有错误节点的单元
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','验证错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%指定z方向为z方向
f.manager_ele.Add(tmp);
%设置错误的节点边界条件 节点不存在
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加轴向位移 uy位移

f.Solve();
rea1=[-5.05	-14.11	4.93	7.05	-5.33	-8.04];
rea2=[5.05	14.11	-4.93	7.05	-5.33	-8.04];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end
function test_verifymodel4(testcase)
%验证模型4 在3的模型 荷载改为j节点所有位移为1
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%实例化带有错误节点的单元
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','验证错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%指定z方向为z方向
f.manager_ele.Add(tmp);
%设置错误的节点边界条件 节点不存在
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加轴向位移 uy位移

f.Solve();
rea1=[5.21	-13.12	-7.5	2.94	4.84	-10.99];
rea2=[-5.21	13.12	7.5	10.19	8.92	-3.97];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end
function test_verifymodel5(testcase)
%验证模型5 在3的模型 荷载改为j节点所有力为1
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.14,0,1);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

%实例化带有错误节点的单元
testcase.verifyError(@()ELEMENT_EULERBEAM(f,0,[1001 1002],sec,[0 -1 0]),'MATLAB:myerror','验证错误');
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%指定z方向为z方向
f.manager_ele.Add(tmp);
%设置错误的节点边界条件 节点不存在
testcase.verifyError(@()f.bc.Add('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('force',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加轴向位移 uy位移

f.Solve();
rea1=[-1	-1	-1	0	-0.86	-2.14];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
displ2=[1.684273	0.309404	1.030101	0.089553	0.454933	0.497021];
testcase.verifyTrue(norm(f.node.nds_displ(2,2:7)-displ2)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_displ(1,2:7))<0.0001,'验证错误');
end
function test_verifymodel6(testcase)
%验证模型6 单跨模型 单跨梁 2节点 j坐标1 2 0 截面方向x
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[1 0 0]);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 1;2 2 0;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加

f.Solve();
rea1=[-2.76	1.13	0	0	0	3.33];
rea2=[2.76	-1.13	0	0	0	3.33];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end
function test_verifymodel7(testcase)
%验证模型7 在模型6的基础上施加所有位移1荷载
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[1 0 0]);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加

f.Solve();



rea1=[-4.95	1.74	-2.2	-4.39	-1.44	4.44];
rea2=[4.95	-1.74	2.2	-0.01342	3.64	7.21];%支反力的理论解sap2000得到的
testcase.verifyTrue(norm(f.node.nds_force(1,2:7)-rea1)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_force(2,2:7)-rea2)<0.01,'验证错误');
end
function test_verifymodel8(testcase)
%验证模型8 单跨 j坐标1 2 3 位移为竖向1 方向z向
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,2,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('displ',[2 1 0;2 2 0;2 3 1;2 4 0;2 5 0;2 6 0;]);%对右节点施加

f.Solve();
testcase.verifyTrue(norm(f.node.nds_force(2,4)-0.4426)<0.01,'验证错误');

end
function test_verifymodel9(testcase)
%验证模型9 两个梁 一个z向 一个y向 荷载为fx=1 在悬臂端
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,3);
f.node.AddByCartesian(3,0,5,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
f.bc.Add('force',[3 1 1;]);%对右节点施加

f.Solve();
testcase.verifyTrue(norm(f.node.nds_force(1,2)+1)<0.01,'验证错误');%1节点ux反力
testcase.verifyTrue(norm(f.node.nds_force(1,6)+3)<0.01,'验证错误');%1节点ry反力
r=[26.203877	0	2.007E-16	6.022E-17	1.097561	-5.818011];
testcase.verifyTrue(norm(f.node.nds_displ(3,2:7)-r)<0.01,'验证错误');
end
function test_verifymodel10(testcase)
%验证模型10 在9的基础上 将节点2的ux固定 其他不变
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,3);
f.node.AddByCartesian(3,0,5,3);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);

tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[2 1 0;]);
f.bc.Add('force',[3 1 1;]);

f.Solve();

r=[24.008755	0	2.007E-16	6.022E-17	0	-5.818011];
testcase.verifyTrue(norm(f.node.nds_displ(3,2:7)-r)<0.01,'验证错误');
end
function test_verifymodel_11(testcase)
%验证模型11 验证杆端释放
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.2,0,0);
f.node.AddByCartesian(3,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'i');%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
f.bc.Add('force',[2 2 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,3)-0.1335)<0.01,'验证错误');
end
function test_verifymodel_12(testcase)
%验证模型12 验证杆端释放
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,1.3);
f.node.AddByCartesian(3,3,0,1.3);
f.node.AddByCartesian(4,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'ij');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[0 -1 0]);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[4 1 0;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
f.bc.Add('force',[2 1 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,2)-0.1683)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_displ(3,2)-0.0103)<0.01,'验证错误');
end
function test_verifymodel_13(testcase)
%验证模型13 未被单元激活的自由度上加力
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1.2,0,0);
f.node.AddByCartesian(3,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'i');%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
f.bc.Add('force',[2 2 1;]);
f.bc.Add('force',[2 2 5;]);

testcase.verifyError(@()f.Solve(),'matlab:myerror','验证错误');
end
function test_verifymodel_14(testcase)
%验证模型14 在12模型上同时施加力和位移
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,1.3);
f.node.AddByCartesian(3,3,0,1.3);
f.node.AddByCartesian(4,3,0,0);
f.manager_mat.Add(1,0.2,1,'concrete');
mat=f.manager_mat.GetByIdentifier('concrete');
sec=SECTION('ver',mat,1.1,3.1,4.1,13);
f.manager_sec.Add(sec);
tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'ij');%指定z方向为
f.manager_ele.Add(tmp);
tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[0 -1 0]);%指定z方向为
f.manager_ele.Add(tmp);

f.bc.Add('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
f.bc.Add('displ',[4 1 1;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
f.bc.Add('force',[2 1 1;]);

f.Solve();

testcase.verifyTrue(norm(f.node.nds_displ(2,2)-0.2262)<0.01,'验证错误');
testcase.verifyTrue(norm(f.node.nds_displ(3,2)-0.9524)<0.01,'验证错误');
end