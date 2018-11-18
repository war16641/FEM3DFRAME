classdef LoadCase_Modal<LoadCase
    %自振工况
    
    properties
        
    end
    
    methods
        function obj = LoadCase_Modal(f,name)
            obj=obj@LoadCase(f,name);
            obj.rst=Result_Modal(obj);%覆盖原有结果对象 改为使用模态专用结果对象
        end
        function Solve(obj)
            obj.GetK();
            obj.GetM();
            
            %检查边界条件是否重复
            obj.bc.Check();
            
            %K1为引入边界条件的总刚度矩阵
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %先处理位移边界
            df=zeros(dof,1);
            
            in=[];%存储不激活的自由度 位移限制的自由度
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%得到序号
                df=df-obj.K(:,index)*ln(3);
                u(index)=ln(3);%保存位移
                in=[in index];
            end
            activeindex=1:dof;
            
            %处理未被单元激活自由度
            hit=zeros(dof,1);%自由度被击中次数
            
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                for it1=1:length(e.nds)
                    xh=obj.f.node.GetXuhaoByID(e.nds(it1));
                    hit(xh:xh+5)=hit(xh:xh+5)+e.hitbyele(it1,:)';%hit加1
                end
            end
            %收集未被单元激活的自由度
            tmp=1:dof;
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
            activeindex([in deadindex])=[];
            
            %处理力边界条件
            index_force=[];%力荷载 击中的自由度序号
            ft=zeros(dof,1);
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
            
            %形成刚度 质量 矩阵 引入边界条件后
            K1=obj.K(activeindex,activeindex);%去除一部分自由度
            M1=obj.M(activeindex,activeindex);
            
            %调用算法求解特征值
            [w,mode]=LoadCase_Modal.GetInfoForFreeVibration_eig(K1,M1);
            
            %处理求解后所有自由度上的力和位移 保存结果
            tic
            for it=1:length(w)%这一块循环有点花时间
                w1=w(it);
                mode1=mode(:,it);
                u1=u;
                u1(activeindex)=mode1;
                f1=obj.K*u1;
                obj.rst.Add(it,w1,f1,u1);
            end
            toc

            

            
            
            %初始化结果指针
            obj.rst.SetPointer();

        end
        function GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            %形成节点与刚度矩阵的映射
            obj.f.node.SetupMapping();

            
            
            obj.K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'组装刚度矩阵','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.K=e.FormK(obj.K);
                
            end
            close(f);
        end
        function GetM(obj)%组装质量矩阵（边界条件引入之前) 务必先调用GetM形成映射
            %M是总质量矩阵(边界条件处理前) 阶数为6*节点个数
            
            
            
            
            obj.M=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'组装质量矩阵','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.M=e.FormM(obj.M);
                
            end
            close(f);
        end
    end
    methods(Static)
        function [w,mode]=GetInfoForFreeVibration_eig(k,m,nummode)
            %利用广义特征值 KV=BVD求解自振信息
            %nummode 可选 前几阶频率和振型
            if nargin==2
                nummode=size(k,1);
            end
            [mode,D]=eigs(k,m,nummode,'sm');%输出频率按从小到大排列
            w=sqrt(diag(D));
            %规格化振型
            for it=1:nummode
                mn=mode(:,it)'*m*mode(:,it);
                mode(:,it)=mode(:,it)/sqrt(mn);
            end
        end
    end
end

