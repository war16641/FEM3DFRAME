classdef LoadCase_Static<LoadCase
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = LoadCase_Static(f,name)
            obj=obj@LoadCase(f,name);
        end
        function Solve(obj)

            obj.PreSolve();
            %判断工况是线性的还是非线性的
            if obj.f.flag_nl==0%线性结构
                %求解
                u1=obj.K1\obj.f_node1;
                
                %处理求解后所有自由度上的力和位移
                u=obj.u_beforesolve;
                u(obj.activeindex)=u1;
                f=obj.K*u;
                
                %把结果保存到noderst
                %static工况只有一个名为static的非时间结果
                obj.rst.AddNontime('static',f,u);
                
                %初始化结果指针
                obj.rst.SetPointer();
            else%非线性结构
                %检查是否存在位移边界条件
                obj.CheckBC1();
                u_all=obj.Script_NR();
                
                %计算弹性部分力
                f=obj.K*u_all;
                %把结果保存到rst
                %static工况只有一个名为static的非时间结果
                obj.rst.AddNontime('static',f,u_all);
                
                %初始化结果指针
                obj.rst.SetPointer();

            end


        end
        function u_all=Script_NR(obj)%NR迭代过程
            %u是位移向量 全自由度
            j=0;%迭代次数
            maxj=10;%最大迭代次数
            u=obj.u_beforesolve(obj.activeindex);
            tol=1e-4;
            Fs_n=zeros(obj.dof,1);
            KT=zeros(obj.dof,obj.dof);
            norm_f1=norm(obj.f_node1);%f1范数
            %求起始Fs_n和KT
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                if e.flag_nl==0%线性单元
                    continue;
                end
                KT=e.FormMatrix(KT,e.KTel);
                Fs_n=e.FormVector(Fs_n,e.Fsel);
            end
            while 1
                KT1=KT(obj.activeindex,obj.activeindex);
                Fs_n1=Fs_n(obj.activeindex);%有效ziyoudu
                f_unbalance=obj.f_node1-obj.K1*u-Fs_n1;%不平衡力
                %检查是否满足误差条件
                if norm(f_unbalance)/norm_f1<tol%收敛
                    %结束nr状态
                    for it=1:obj.f.manager_ele.num
                        e=obj.f.manager_ele.Get('index',it);
                        if e.flag_nl==0%线性单元
                            continue;
                        end
                        e.FinishNR();
                        
                    end
                    
                    %输出节点位移
                    u_all=obj.u_beforesolve;
                    u_all(obj.activeindex)=u;
                    
                    break;
                end
                %检查是否已经达到最大迭代次数
                if j>=maxj
                    error('nyh:error','已经达到最大NR次数')
                end
                %不收敛
                du=(obj.K1+KT1)^-1*f_unbalance;%增量
                u=u+du;
                %重置
                Fs_n=zeros(obj.dof,1);
                KT=zeros(obj.dof,obj.dof);
                
                %将增量写入到各个非线性单元中
                for it=1:obj.f.manager_ele.num
                    e=obj.f.manager_ele.Get('index',it);
                    if e.flag_nl==0%线性单元
                        continue;
                    end
                    
                    duel=e.GetMyVec(du,obj);
                    [Fsel,KTel]=e.AddNRHistory(duel);
                    Fs_n=e.FormVector(Fs_n,Fsel);
                    KT=e.FormMatrix(KT,KTel);
                    
                end
                j=j+1;%迭代次数加1
                
                
            end
        end
        function GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            

            
            
            K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'组装刚度矩阵','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
        function CheckBC(obj)
            %静力工况对bc无额外要求
            return;
        end
        function CheckBC1(obj)%非线性工况需要这个bc条件
            %要求位移边界条件全是0
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                if ln(3)~=0
                    error('nyh:error','非弹性工况不能出现位移不为0的边界条件')
                end
            end
        end
        function GetM(obj)
            %静力工况不需要M
            obj.M=zeros(obj.dof,obj.dof);
        end
    end
end

