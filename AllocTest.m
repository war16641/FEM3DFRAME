%runtests('AllocTest.m')
%r = runperf('AllocTest')
classdef AllocTest < matlab.perftest.TestCase   % 性能测试的公共父类

    methods(Test)
        
        function test1(testcase)
            f=FEM3DFRAME();
            f.node.AddByCartesian(0,1,1,1);
            f.node.AddByCartesian(0,2,1,1);
            f.node.AddByCartesian(0,3,1,1);
            testcase.verifyTrue(f.node.ndnum==3,'添加节点错误（不指定id)');
            testcase.verifyTrue(f.node.maxnum==3,'添加节点错误（不指定id)');
            testcase.verifyTrue(f.node.nds.object{end,1}==3,'添加节点错误（不指定id)');
            
            %指定id 添加
            f.node.AddByCartesian(4,4,1,1);
            testcase.verifyTrue(f.node.ndnum==4,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.maxnum==4,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.nds.object{end,1}==4,'添加节点错误（指定id)');
            
            %不按连续编号添加
            f.node.AddByCartesian(10,10,1,1);
            testcase.verifyTrue(f.node.ndnum==5,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
            
            testcase.verifyTrue(f.node.nds.object{end,1}==10,'添加节点错误（指定id)');
            
            %插入一个节点至空白处
            f.node.AddByCartesian(5,5,1,1);
            testcase.verifyTrue(f.node.ndnum==6,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.nds.object{end-1,1}==5,'添加节点错误（指定id)');
            
            %插入一个节点至有值处
            f.node.AddByCartesian(5,5,2,1);
            testcase.verifyTrue(f.node.ndnum==6,'添加节点错误（指定id)');
            testcase.verifyTrue(f.node.maxnum==10,'添加节点错误（指定id)');
            tmp=f.node.nds.Get('index',f.node.ndnum-1);
            testcase.verifyTrue(tmp(2)==2,'添加节点错误（指定id)');
            tmp=f.node.nds.Get('index',f.node.ndnum-1);
            testcase.verifyTrue(tmp(2)==2,'添加节点错误（指定id)');
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
            t1=f.manager_ele.Get('index',f.manager_ele.num);
            testcase.verifyTrue(norm(t1.zdir-[-1/sqrt(2) 0 1/sqrt(2)])<1e-10,'添加单元错误');
            tmp=ELEMENT_EULERBEAM(f,0,[100 101],sec,[0 1 0]);
            f.manager_ele.Add(tmp);
            t1=f.manager_ele.Get('index',f.manager_ele.num);
            testcase.verifyTrue(norm(t1.zdir-[0 1 0])<1e-10,'添加单元错误');
            
            
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            %设置错误的节点边界条件 节点不存在
            testcase.verifyError(@()lc.AddBC('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加轴向位移 uy位移
            
            lc.Solve();
            rea1=[-6.55	-10.67	6.63	5.33	-7.05	-6.08];
            rea2=[6.55	10.67	-6.63	5.33	-7.05	-6.08];%支反力的理论解sap2000得到的
            % lc.noderst.Get('force',1,'all') lc.rst.Get('node','force',1,'all')
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm(lc.rst.Get('node','force',2,'all')-rea2)<0.01,'验证错误');
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]);%固接左节点
            lc.AddBC('displ',[1002 1 1;1002 2 1;1002 3 0;1002 4 0;1002 5 0; 1002 6 0;]);%对右节点施加轴向位移 uy位移
            lc.Solve();
            rea1=[-0.96 -25.11 0  0  0 -14.31 ];
            rea2=[0.96 25.11 0  0  0 -14.31 ];%支反力的理论解sap2000得到的  lc.rst.Get('node','force',1,'all')
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1001,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1002,'all')-rea2)<0.01,'验证错误');
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            %设置错误的节点边界条件 节点不存在
            testcase.verifyError(@()lc.AddBC('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 1;2 2 1;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加轴向位移 uy位移
            
            lc.Solve();
            rea1=[-5.05	-14.11	4.93	7.05	-5.33	-8.04];
            rea2=[5.05	14.11	-4.93	7.05	-5.33	-8.04];%支反力的理论解sap2000得到的
            testcase.verifyTrue(norm( lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm( lc.rst.Get('node','force',2,'all')-rea2)<0.01,'验证错误');
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            %设置错误的节点边界条件 节点不存在
            testcase.verifyError(@()lc.AddBC('displ',[1001 1 0;1001 2 0;1001 3 0;1001 4 0;1001 5 0;1001 6 0;]),'MATLAB:myerror','验证错误');
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加轴向位移 uy位移
            
            lc.Solve();
            rea1=[5.21	-13.12	-7.5	2.94	4.84	-10.99];
            rea2=[-5.21	13.12	7.5	10.19	8.92	-3.97];%支反力的理论解sap2000得到的
            testcase.verifyTrue(norm( lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm( lc.rst.Get('node','force',2,'all')-rea2)<0.01,'验证错误');
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
            
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);%指定z方向为z方向
            f.manager_ele.Add(tmp);
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('force',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加轴向位移 uy位移
            
            lc.Solve();
            rea1=[-1	-1	-1	0	-0.86	-2.14];%支反力的理论解sap2000得到的  lc.rst.Get('node','force',1,'all')
            testcase.verifyTrue(norm( lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            displ2=[1.684273	0.309404	1.030101	0.089553	0.454933	0.497021];
            testcase.verifyTrue(norm( lc.rst.Get('node','displ',2,'all')-displ2)<0.01,'验证错误');
            testcase.verifyTrue(norm( lc.rst.Get('node','displ',1,'all'))<0.0001,'验证错误');
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 1;2 2 0;2 3 0;2 4 0;2 5 0;2 6 0;]);%对右节点施加
            
            lc.Solve();
            rea1=[-2.76	1.13	0	0	0	3.33];
            rea2=[2.76	-1.13	0	0	0	3.33];%支反力的理论解sap2000得到的
            testcase.verifyTrue(norm( lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm( lc.rst.Get('node','force',2,'all')-rea2)<0.01,'验证错误');
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[1 0 0]);%指定z方向为
            f.manager_ele.Add(tmp);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 1;2 2 1;2 3 1;2 4 1;2 5 1;2 6 1;]);%对右节点施加
            
            lc.Solve();
            
            
            
            rea1=[-4.95	1.74	-2.2	-4.39	-1.44	4.44];%
            rea2=[4.95	-1.74	2.2	-0.01342	3.64	7.21];%支反力的理论解sap2000得到的
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1,'all')-rea1)<0.01,'验证错误');
            testcase.verifyTrue(norm(lc.rst.Get('node','force',2,'all')-rea2)<0.01,'验证错误');
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('displ',[2 1 0;2 2 0;2 3 1;2 4 0;2 5 0;2 6 0;]);%对右节点施加
            
            lc.Solve();
            testcase.verifyTrue(norm(lc.rst.Get('node','force',2,'uz')-0.4426)<0.01,'验证错误');
            
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%指定z方向为
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%指定z方向为
            f.manager_ele.Add(tmp);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);%固接左节点
            lc.AddBC('force',[3 1 1;]);%对右节点施加 norm(lc.noderst.Get('force',1,'ux')
            
            lc.Solve();
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1,'ux')+1)<0.01,'验证错误');%1节点ux反力
            testcase.verifyTrue(norm(lc.rst.Get('node','force',1,5)+3)<0.01,'验证错误');%1节点ry反力
            r=[26.203877	0	2.007E-16	6.022E-17	1.097561	-5.818011];
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',3,'all')-r)<0.01,'验证错误');
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
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0]);%指定z方向为
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec);%指定z方向为
            f.manager_ele.Add(tmp);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[2 1 0;]);
            lc.AddBC('force',[3 1 1;]);
            
            lc.Solve();
            
            r=[24.008755	0	2.007E-16	6.022E-17	0	-5.818011];
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',3,'all')-r)<0.01,'验证错误');
            
            %验证单元结果
            ui=lc.rst.Get('node','displ',2,'all');
            uj=lc.rst.Get('node','displ',3,'all');
            e=f.manager_ele.Get('id',2);
            [a,b]=e.GetEleResult([ui;uj]);
            
            lc.rst.Get('ele','deform',1,'all')
            r=lc.rst.Get('ele','force',1,'ij',4)
            testcase.verifyTrue(norm(r-[5 ;-5])<0.001,'验证错误');
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
            lc.AddBC('force',[2 2 1;]);
            
            lc.Solve();
            
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',2,'uy')-0.1335)<0.01,'验证错误');
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[4 1 0;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
            lc.AddBC('force',[2 1 1;]);
            
            lc.Solve();
            
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',2,'ux')-0.1683)<0.01,'验证错误');
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',3,'ux')-0.0103)<0.01,'验证错误');
            t=lc.rst.Get('ele','force',1,'i','all');
            t=t([2 6]);
            testcase.verifyTrue(norm(t-[0.94 1.22])<0.01,'验证错误');
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
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
            lc.AddBC('force',[2 4 1;]);
            lc.AddBC('force',[2 4 5;]);
            
            testcase.verifyError(@()lc.Solve(),'matlab:myerror','验证错误');
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
            tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[0 -1 0]);%指定z方向为 lc.noderst.Get('displ',2,1)
            f.manager_ele.Add(tmp);
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[4 1 1;4 2 0;4 3 0;4 4 0;4 5 0;4 6 0;]);
            lc.AddBC('force',[2 1 1;]);
            
            lc.Solve();
            
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',2,1)-0.2262)<0.01,'验证错误');
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',3,1)-0.9524)<0.01,'验证错误');
        end
        function test_verifymodel_15(testcase)
            %验证模型15 验证杆端释放
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            f.node.AddByCartesian(3,0,0,3);
            f.manager_mat.Add(1,0.2,1,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,1.1,3.1,4.1,13);
            f.manager_sec.Add(sec);
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 -1 0],'j');%指定z方向为
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_EULERBEAM(f,0,[2 3],sec,[0 -1 0],'i');%指定z方向为
            f.manager_ele.Add(tmp);
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
            lc.AddBC('force',[2 2 1;]);
            
            lc.Solve();
            
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',2,'uy')-0.1335)<0.01,'验证错误');
        end
        function test_verifymodel_16(testcase)
            %验证模型16 验证spring单元
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            f.node.AddByCartesian(3,1,0,0);
            f.node.AddByCartesian(4,1,0,1.2);
            f.manager_mat.Add(1,0.2,1,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,1.1,3.1,4.1,1e5);
            f.manager_sec.Add(sec);
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec,[0 1 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_EULERBEAM(f,0,[3 4],sec,[1 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 4],[1.15 0.8 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[3 1 0;3 2 0;3 3 0;3 4 0;3 5 0;3 6 0;]);
            lc.AddBC('force',[2 2 1;2 1 1]);
            
            lc.Solve();
            d4=[0.021828	0.01656	-7.874E-18	-0.0207	0.027285	0];
            testcase.verifyTrue(norm(lc.rst.Get('node','displ',4,'all')-d4)<0.001,'验证错误');
            t=lc.rst.Get('ele','eng',3);%看能量对不对
            testcase.verifyTrue(norm(t-[0.01468 0 0])<0.001,'验证错误');
        end
        function test_verifymodel_17(testcase)
            %验证模型17 悬臂梁自振
            n=60;%单元个数
            h=30;%墩高
            lenel=h/n;%单元长度
            
            f=FEM3DFRAME();
            f.manager_mat.Add(32.5e6,0.2,2.5,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,15.84375,31.378,31.378,1e5);
            f.manager_sec.Add(sec);
            for it=1:n+1
                f.node.AddByCartesian(0,0,0,(it-1)*lenel);
            end
            for it=1:n
                tmp=ELEMENT_EULERBEAM(f,0,[it it+1],sec);
                f.manager_ele.Add(tmp);
            end
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[n+1 1 1]);
            lc.Solve();
            
            
            lc=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            %删除扭转自由度
            for it=1:n+1
                lc.AddBC('displ',[it 6 0;it 3 0]);
                
            end
            lc.Solve();
            
        end
        function test_verifymodel_18(testcase)
            %验证模型18 一个单元
            n=1;%单元个数
            h=2;%墩高
            lenel=h/n;%单元长度
            
            f=FEM3DFRAME();
            f.manager_mat.Add(32.5e6,0.2,2.5,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,15.84375,31.378,31.378,1e5);
            f.manager_sec.Add(sec);
            for it=1:n+1
                f.node.AddByCartesian(0,0,0,(it-1)*lenel);
            end
            for it=1:n
                tmp=ELEMENT_EULERBEAM(f,0,[it it+1],sec);
                f.manager_ele.Add(tmp);
            end
            
            
            
            lc=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('displ',[2 1 0;2 3 0;2 5 0;2 6 0;]);
            lc.Solve();
        end
        function test_verifymodel_19(testcase)
            %测试 mass单元
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            
            tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,2,[23 25 30 0 0 0]);
            f.manager_ele.Add(tmp);
            
            lc=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc.Solve();
            
            w1=sqrt(0.8/23);
            w2=sqrt(1.15/30);
            [~,t]=lc.rst.GetPeriodInfo();
            testcase.verifyTrue(norm(t(3)-w1)<0.001,'验证错误');
            lc.rst.SetPointer(2);
            [~,t]=lc.rst.GetPeriodInfo();
            testcase.verifyTrue(norm(t(3)-w2)<0.001,'验证错误');
            
        end
        function test_verifymodel_20(testcase)%测试 地震工况 三自由度
            
            
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            f.node.AddByCartesian(3,2,0,0);
            f.node.AddByCartesian(4,3,0,0);
            m=267e3;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            k=1.75e9;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 3],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[3 4],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            lc1.rst.SetPointer(3);
            [~,pri]=lc1.rst.GetPeriodInfo();
            w2=pri(3);
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            
            % ew=EarthquakWave();
            % ew.LoadFromFile('landers','g','F:\TOB\地震波\Landers.txt','time&acc',0);
            
            dt=load('wjj.mat','dz');
            dt=dt.dz;
            ew=EarthquakWave(dt(:,1),dt(:,2),'m/s^2','dz');
            ei=EarthquakeInput(lc,'landers',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,w2,0.05,0.05);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            testcase.verifyTrue(norm(max(vn)-1.0106e-003)<0.001,'验证错误');
            
            lc=LoadCase_Earthquake(f,'eq1');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            ei=EarthquakeInput(lc,'landers',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('central');
            [a, b]=DAMPING.RayleighDamping(w1,w2,0.05,0.05);
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn1,tn1]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            hold on
            plot(tn1,vn1,'o')
            legend('newamrk','central')
            err=norm(vn1-vn)/sqrt(length(vn));
            testcase.verifyTrue(err<0.00005,'验证错误');
            
        end
        
        function test_verifymodel_21(testcase)
            %测试 地震工况 单节点受正玄波荷载
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            
            m=1;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            k=1;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.CloneBC(lc1);
            
            
            ew=EarthquakWave.MakeSin(2/2/pi,1,10,0.01);
            ei=EarthquakeInput(lc,'sin',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            syms t
            v_t=exp(-0.005*t)*(0.0022221*cos(0.99999*t) + 0.66666*sin(0.99999*t)) - 0.33332*sin(2.0*t) - 0.0022221*cos(2.0*t);
            v_v=subs(v_t,t,0:0.01:10);
            v_v=vpa(v_v,7);
            v_v=double(v_v);
            hold on
            plot(tn,-v_v,'+','markersize',3);
            legend('fem','精确值');
            syms t
            v_t=exp(-0.005*t)*(0.0022221*cos(0.99999*t) + 0.66666*sin(0.99999*t)) - 0.33332*sin(2.0*t) - 0.0022221*cos(2.0*t);
            v_v=subs(v_t,t,0:0.01:10);
            v_v=vpa(v_v,7);
            v_v=double(v_v);
            hold on
            plot(tn,-v_v,'+','markersize',3);
            legend('fem','精确值');
            er=v_v'+vn;
            testcase.verifyTrue(norm(er)<0.002,'验证错误');
            
            %中心差分法
            lc=LoadCase_Earthquake(f,'eq1');
            f.manager_lc.Add(lc);
            lc.CloneBC(lc1);
            ew=EarthquakWave.MakeSin(2/2/pi,1,10,0.01);
            ei=EarthquakeInput(lc,'sin',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('central');
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn1,tn1]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            err=norm(vn1-vn);
            testcase.verifyTrue(err<0.002,'验证错误');
        end
        function test_verifymodel_22(testcase)
            %测试 初始位移
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            
            m=1;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            k=1;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.CloneBC(lc1);
            testcase.verifyError(@()lc.intd.Add([1 1 1]),'nyh:error','验证错误');
            lc.intd.Add([2 1 1])
            
            ew=EarthquakWave.MakeConstant(0,20,0.01);
            ei=EarthquakeInput(lc,'const',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            
            
            
            %解析解
            [v]=dsolve('D2y+0.01*Dy+y=0','Dy(0)=0','y(0)=1');
            syms t
            v_v=subs(v,t,[0:0.01:20]);
            v_v=double(v_v);
            hold on
            plot(0:0.01:20,v_v,'o','markersize',2);
            
            er=norm(vn-v_v');
            
            testcase.verifyTrue(er/2001<0.002,'验证错误');
            
            %中心差分法
            lc=LoadCase_Earthquake(f,'eq1');
            f.manager_lc.Add(lc);
            lc.CloneBC(lc1);
            lc.intd.Add([2 1 1])
            
            ew=EarthquakWave.MakeConstant(0,20,0.01);
            ei=EarthquakeInput(lc,'const',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('central');
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn1,tn1]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            err=norm(vn-vn1)/sqrt(length(vn));
            plot(tn1,vn1);
            legend('newmark','解析解','central')
            testcase.verifyTrue(err<0.001,'验证错误');
        end
        function test_verifymodel_23(testcase)
            %测试 模态坐标 同时验证当初位移为第三阵型时，是否其他模态坐标为0
            
            order=2;
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            f.node.AddByCartesian(3,2,0,0);
            f.node.AddByCartesian(4,3,0,0);
            m=267e3;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            k=1.75e9;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 3],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[3 4],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            lc1.rst.SetPointer(order);
            [~,pri]=lc1.rst.GetPeriodInfo();
            w2=pri(3);
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            
            % ew=EarthquakWave();
            % ew.LoadFromFile('landers','g','F:\TOB\地震波\Landers.txt','time&acc',0);
            
            
            ew=EarthquakWave.MakeConstant(0,5,0.002);
            ei=EarthquakeInput(lc,'landers',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,w2,0.05,0.05);
            lc.damp.Set('rayleigh',0,0);
            %初位移
            u1=lc1.rst.Get('node','displ',2,1);
            u2=lc1.rst.Get('node','displ',3,1);
            u3=lc1.rst.Get('node','displ',4,1);
            lc.intd.Add([2 1 u1; 3 1 u2;4 1 u3]);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'eng');
            t=sum(vn,2);
            vn=[vn t];
            figure
            plot(tn,vn);
            title('能量')
            legend('势能','动能','耗能','总能量')
            %计算模态坐标
            md=lc.MakeModalDispl(lc1);
            [t,YY,eng]=md.PlotData();
            testcase.verifyTrue(t(order)/sum(t)>0.99,'验证错误');
            testcase.verifyTrue(norm(vn(:,1)-eng(:,end))<0.0001,'验证错误');%验证模态的势能和结构的势能是否一致
        end
        function test_verifymodel_24(testcase)
            %测试 恒载力
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            
            m=1;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            k=1;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            
            lcd=LoadCase_Static(f,'eq');
            f.manager_lc.Add(lcd);
            lcd.CloneBC(lc1);
            lcd.AddBC('force',[2 1 1]);
            lcd.Solve();
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.CloneBC(lcd);
            ew=EarthquakWave.MakeConstant(0,20,0.01);
            ei=EarthquakeInput(lc,'const',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            
            %解析解
            [v]=dsolve('D2y+0.01*Dy+y=1','Dy(0)=0','y(0)=0');
            syms t
            v_v=subs(v,t,[0:0.01:20]);
            v_v=double(v_v);
            hold on
            plot(0:0.01:20,v_v,'o','markersize',2);
            
            er=norm(vn-v_v');
            
            testcase.verifyTrue(er/2001<0.002,'验证错误');
            
            %中心差分法
            lc=LoadCase_Earthquake(f,'eq1');
            f.manager_lc.Add(lc);
            lc.CloneBC(lcd);
            ew=EarthquakWave.MakeConstant(0,20,0.01);
            ei=EarthquakeInput(lc,'const',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('central');
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn1,tn1]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            plot(tn1,vn1);
            legend('newmark','解析解','central')
            err=norm(vn-vn1)/sqrt(length(vn));
            testcase.verifyTrue(err<0.001,'验证错误');
        end
        function test_verifymodel_25(testcase)
            %测试 恒载力+初位移
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            
            m=1;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            k=1;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            
            lc1=LoadCase_Modal(f,'modal');
            f.manager_lc.Add(lc1);
            lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            lc1.Solve();
            [~,pri]=lc1.rst.GetPeriodInfo();
            w1=pri(3);
            
            lcd=LoadCase_Static(f,'eq');
            f.manager_lc.Add(lcd);
            lcd.CloneBC(lc1);
            lcd.AddBC('force',[2 1 1]);
            lcd.Solve();
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.CloneBC(lcd);
            
            lc.intd.Add([2 1 1])
            
            
            
            ew=EarthquakWave.MakeConstant(0,20,0.01);
            ei=EarthquakeInput(lc,'const',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            [a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);
            
            lc.damp.Set('rayleigh',a,b);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,vn)
            
            %解析解
            [v]=dsolve('D2y+0.01*Dy+y=1','Dy(0)=0','y(0)=1');
            syms t
            v_v=subs(v,t,[0:0.01:20]);
            v_v=double(v_v);
            hold on
            plot(0:0.01:20,v_v,'o','markersize',2);
            legend('fem','解析解')
            er=norm(vn-v_v');
            
            testcase.verifyTrue(er/2001<0.002,'验证错误');
        end
        
        
        function test_verifymodel_26(testcase)%验证模型26 %验证spring单元非线性
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
            tmp.SetNLProperty(1,[1 1 0.1]);
            f.manager_ele.Add(tmp);
            
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 1]);
            
            lc.Solve();
            r1=lc.rst.Get('node','displ',2,3);
            r2=lc.rst.Get('ele','force',1,'i','all');
            testcase.verifyTrue(norm(r1-1)<0.002,'验证错误');
            testcase.verifyTrue(norm(r2-[-1 0 0 0 0 0])<0.002,'验证错误');
            
            lc=LoadCase_Static(f,'dead2');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 1.5]);
            lc.Solve();
            r1=lc.rst.Get('node','displ',2,3);
            r2=lc.rst.Get('ele','force',1,'i','all');
            testcase.verifyTrue(norm(r1-6)<0.002,'验证错误');
            testcase.verifyTrue(norm(r2-[-1.5 0 0 0 0 0])<0.002,'验证错误');
        end
        
        
        function test_verifymodel_27(testcase)%验证模型27 %验证spring单元非线性 并联一个
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
            tmp.SetNLProperty(1,[1 1 0.1]);
            f.manager_ele.Add(tmp);
            
            f.manager_mat.Add(1,0.2,1,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,1.1,3.1,4.1,13);
            f.manager_sec.Add(sec);
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);
            f.manager_ele.Add(tmp);
            lc=LoadCase_Static(f,'dead');
            f.manager_lc.Add(lc);
            
            
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 2.2217]);
            
            lc.Solve();
            r1=lc.rst.Get('node','displ',2,3);
            r2=lc.rst.Get('ele','force',1,'i','all');
            testcase.verifyTrue(norm(r1-1.3)<0.002,'验证错误');
            
            
        end
        
        
        function test_verifymodel_28(testcase)%验证模型28 %验证多段弹性
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
            f.manager_ele.Add(tmp);
            
            f.manager_mat.Add(1,0.2,1,'concrete');
            mat=f.manager_mat.GetByIdentifier('concrete');
            sec=SECTION('ver',mat,1.1,3.1,4.1,13);
            f.manager_sec.Add(sec);
            tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);
            f.manager_ele.Add(tmp);
            
            
            lc=LoadCase_MultStepStatic(f,'dead');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 1;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 2.2217]);
            testcase.verifyError(@()lc.Solve(),'nyh:error','验证错误');
            
            
            lc=[];
            lc=LoadCase_MultStepStatic(f,'dead1');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 1]);
            ew=EarthquakWave.MakeSin(1,1,1,0.05,1);
            lc.Set(ew.tn,ew.accn);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,1,'node','displ',2,3);%获取时程结果
            vn_tar=ew.accn/2.0667;
            figure;
            plot(tn,vn)
            hold on
            plot(tn,vn_tar,'o')
            legend('fem','理论值')
            err=norm(vn-vn_tar);
            testcase.verifyTrue(err<0.001,'验证错误');
        end
        
        
        
        function test_verifymodel_29(testcase)%验证模型28 %验证多段非弹性
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,0,0,1.2);
            tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
            tmp.SetNLProperty(1,[1 1 0.1]);
            f.manager_ele.Add(tmp);
            
            % f.manager_mat.Add(1,0.2,1,'concrete');
            % mat=f.manager_mat.GetByIdentifier('concrete');
            % sec=SECTION('ver',mat,1.1,3.1,4.1,13);
            % f.manager_sec.Add(sec);
            % tmp=ELEMENT_EULERBEAM(f,0,[1 2],sec);
            % f.manager_ele.Add(tmp);
            
            
            
            
            
            lc=[];
            lc=LoadCase_MultStepStatic(f,'dead1');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
            lc.AddBC('force',[2 3 1]);
            ew=EarthquakWave.MakeSin(1,1,1,0.05,1);
            lc.Set(ew.tn,ew.accn);
            lc.Solve();
            [vn,tn]=lc.rst.GetTimeHistory(0,1,'node','displ',2,3);%获取时程结果
            [fn,tn]=lc.rst.GetTimeHistory(0,1,'ele','force',1,'j',1);%获取时程结果
            vn_tar=[1
                4.090169944
                6.877852523
                9.090169944
                10.51056516
                11
                10.95105652
                10.80901699
                10.58778525
                10.30901699
                10
                9.690983006
                9.412214748
                9.190983006
                9.048943484
                9
                9.048943484
                9.190983006
                9.412214748
                9.690983006
                10
                ];
            figure;
            plot(vn,fn)
            hold on
            plot(vn_tar,fn,'o');
            err=norm(vn-vn_tar);
            testcase.verifyTrue(err<0.001,'验证错误');
        end
        
        
        
        function test_verifymodel_30(testcase)
            %测试 地震工况 三自由度 非线性spring
            
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            f.node.AddByCartesian(3,2,0,0);
            f.node.AddByCartesian(4,3,0,0);
            m=267e3;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            k1=1.75e9;k2=k1*0.1;fy=k1*1e-4;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 3],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[3 4],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            
            
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            
            % ew=EarthquakWave();
            % ew.LoadFromFile('landers','g','F:\TOB\地震波\Landers.txt','time&acc',0);
            
            dt=load('wjj.mat','dz');
            dt=dt.dz;
            ew=EarthquakWave(dt(:,1),dt(:,2),'m/s^2','dz');
            ei=EarthquakeInput(lc,'landers',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('newmark',0.5,0.25);
            C1=[
                2.6955e+006  -962.0010e+003     0.0000e+000
                -962.0010e+003     2.6955e+006  -962.0010e+003
                0.0000e+000  -962.0010e+003     1.7335e+006];
            
            lc.damp.Set('matrix',C1);
            lc.Solve();
            [u3,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,u3)
            r=max(u3);
            testcase.verifyTrue(norm(r-0.0037219)<0.001,'验证错误');
            
            
        end
        
        function test_verifymodel_31(testcase)%乔普拉 EX16.2
            
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            f.node.AddByCartesian(3,2,0,0);
            f.node.AddByCartesian(4,3,0,0);
            f.node.AddByCartesian(5,4,0,0);
            f.node.AddByCartesian(6,5,0,0);
            m=0.259;
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,5,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,6,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            k1=100;
            k2=5;
            fy=125;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 3],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[3 4],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[4 5],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[5 6],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            
            
            
            % lc=LoadCase_Static(f,'dead');
            % f.manager_lc.Add(lc);
            % lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            % tmp=[2 1 125/15
            %     3  1  250/15
            %     4 1 375/15
            %     5 1 500/15
            %     6 1 625/15];
            % lc.AddBC('force',tmp);
            % lc.Solve();
            % r=[lc.rst.Get('node','displ',2,1)
            %     lc.rst.Get('node','displ',3,1)
            %     lc.rst.Get('node','displ',4,1)
            %     lc.rst.Get('node','displ',5,1)
            %     lc.rst.Get('node','displ',6,1)]
            
            lc=LoadCase_MultStepStatic(f,'dead');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            tmp=[2 1 125/15
                3  1  250/15
                4 1 375/15
                5 1 500/15
                6 1 625/15];
            lc.AddBC('force',tmp);
            scale=[0 1 1.1 1.2 1.3 1.4 1.5 1.6];
            tn=1:length(scale);tn=tn';
            lc.Set(tn,scale);
            lc.Solve();
            r1=lc.rst.GetTimeHistory(0,20,'node','displ',2,1);
            r1_tar=[     0.0000e+000
                1.2500e+000
                3.7500e+000
                6.2500e+000
                8.7500e+000
                11.2500e+000
                13.7500e+000
                16.2500e+000];
            err=norm(r1-r1_tar);
            testcase.verifyTrue(err<0.001,'验证错误');
        end
        function test_verifymodel_32(testcase) %测试 地震工况 三自由度 非线性spring
           
            
            f=FEM3DFRAME();
            f.node.AddByCartesian(1,0,0,0);
            f.node.AddByCartesian(2,1,0,0);
            f.node.AddByCartesian(3,2,0,0);
            f.node.AddByCartesian(4,3,0,0);
            m=267e3;
            
            tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
            f.manager_ele.Add(tmp);
            
            k1=1.75e9;k2=k1*0.1;fy=k1*1e-4;
            tmp=ELEMENT_SPRING(f,0,[1 2],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[2 3],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            tmp=ELEMENT_SPRING(f,0,[3 4],[k1 0 0 0 0 0]);
            tmp.SetNLProperty(1,[k1 fy k2]);
            f.manager_ele.Add(tmp);
            
            
            
            
            
            lc=LoadCase_Earthquake(f,'eq');
            f.manager_lc.Add(lc);
            lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
            
            % ew=EarthquakWave();
            % ew.LoadFromFile('landers','g','F:\TOB\地震波\Landers.txt','time&acc',0);
            
            dt=load('wjj.mat','dz');
            dt=dt.dz;
            ew=EarthquakWave(dt(:,1),dt(:,2),'m/s^2','dz');
            ei=EarthquakeInput(lc,'landers',ew,1,0);
            lc.AddEarthquakeInput(ei);
            lc.SetAlgorithm('central');
            C1=[
                2.6955e+006  -962.0010e+003     0.0000e+000
                -962.0010e+003     2.6955e+006  -962.0010e+003
                0.0000e+000  -962.0010e+003     1.7335e+006];
            
            lc.damp.Set('matrix',C1);
            lc.Solve();
            [u3,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
            figure
            plot(tn,u3)
            r=max(u3);
            testcase.verifyTrue(norm(r-0.0037219)<0.001,'验证错误');
            
            
        end
        
    end
end