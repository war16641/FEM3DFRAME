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
            %形成节点与刚度矩阵的映射
            obj.f.node.SetupMapping();
            
            obj.GetK();
            
            %初始化非线性
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                e.InitialKT();
            end
            %检查边界条件是否重复
            obj.bc.Check();
            
           
            %K1为引入边界条件的总刚度矩阵
            obj.dof=6*obj.f.node.ndnum;
            u=zeros(obj.dof,1);
            
            %先处理位移边界
            df=zeros(obj.dof,1);
            
            in=[];%存储不激活的自由度 位移限制的自由度
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%得到序号
                df=df-obj.K(:,index)*ln(3);
                u(index)=ln(3);%保存位移
                in=[in index];
            end
            obj.activeindex=1:obj.dof;
            
            %处理未被单元激活自由度
            hit=zeros(obj.dof,1);%自由度被击中次数
            
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                e.CalcHitbyele();
                for it1=1:length(e.nds)
                    xh=obj.f.node.GetXuhaoByID(e.nds(it1));
                    hit(xh:xh+5)=hit(xh:xh+5)+e.hitbyele(it1,:)';%hit加1
                end
            end
            %收集未被单元激活的自由度
            tmp=1:obj.dof;
            deadindex=tmp(hit==0);
            %输出未被单元激活的自由度信息
            if ~isempty(deadindex)
                disp('存在未被单元激活的自由度')
            end
            for it=1:length(deadindex)
                [id,~,label]=obj.f.node.GetIdByXuhao(deadindex(it));
                disp(['节点' num2str(id) ' ' label]);
            end
            
            %位移荷载对应的自由度与未被单元激活的自由度是否重叠 当自由度缺少的单元在边界处时 会出现这种情况
            [~,ia,~]=unique([in deadindex]);
            if ia<length(in)+length(deadindex)
                warning('位移荷载对应的自由度与未被单元激活的自由度重叠。（当自由度缺少的单元在边界处时会出现这种情况，这是正常的，其他是异常的。')
            end
            %删除两种类型未激活的自由度
            obj.activeindex([in deadindex])=[];
            
            %处理力边界条件
            index_force=[];%力荷载 击中的自由度序号
            ft=zeros(obj.dof,1);
            for it=1:obj.bc.force.num
                ln=obj.bc.force.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;
                ft(index)=ft(index)+ln(3);
                index_force=[index_force index];
            end
            f1=ft+df;
            
            %检查力是否加载在未被单元激活的自由度上
            [~,ia,~]=unique([index_force deadindex]);
            if length(index_force)+length(deadindex)>length(ia)
                error('matlab:myerror','力加载在未被单元激活的自由度上')
            end
            
            K1=obj.K(obj.activeindex,obj.activeindex);
            f1=f1(obj.activeindex);%有效自由度
            %判断工况是线性的还是非线性的
            if obj.f.flag_nl==0%线性结构
                %求解
                
                u1=K1\f1;
                
                %处理求解后所有自由度上的力和位移
                
                u(obj.activeindex)=u1;
                f=obj.K*u;
                
                %把结果保存到noderst
                %static工况只有一个名为static的非时间结果
                obj.rst.AddNontime('static',f,u);
                
                %初始化结果指针
                obj.rst.SetPointer();
            else%非线性结构
                %检查是否存在位移边界条件
                
                
                j=0;%迭代次数
                u_all=zeros(obj.dof,1);%未引入边界条件
                u=u_all(obj.activeindex);
                du=u;
                tol=1e-4;
                Fs_n=zeros(obj.dof,1);
                KT=zeros(obj.dof,obj.dof);
                norm_f1=norm(f1);%f1范数
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
                    R=f1-K1*u-Fs_n1;
                    if norm(R)/norm_f1<tol%收敛
                        %结束nr状态
                        for it=1:obj.f.manager_ele.num
                            e=obj.f.manager_ele.Get('index',it);
                            if e.flag_nl==0%线性单元
                                continue;
                            end
                            e.FinishNR();
                            
                        end
                        
                        %保存结果
                        u_all(obj.activeindex)=u;
                        f=obj.K*u_all;
                        
                        %把结果保存到noderst
                        %static工况只有一个名为static的非时间结果
                        obj.rst.AddNontime('static',f,u_all);
                        
                        %初始化结果指针
                        obj.rst.SetPointer();
                            
                        break;
                    else%不收敛
                        du=(K1+KT1)^-1*R;%增量
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
                    end

                end
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
    end
end

