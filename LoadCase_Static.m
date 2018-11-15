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
            obj.GetK();
            
            %检查边界条件是否重复
            obj.bc.Check();
            
            %K1为引入边界条件的总刚度矩阵
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %先处理位移边界
            df=zeros(dof,1);
            
            in=[];%存储不激活的自由度 位移限制的自由度
            for it=1:size(obj.bc.displ,1)
%                 index=2*(obj.bc.displ(it,1)-1)+obj.bc.displ(it,2);
                index=obj.f.node.GetXuhaoByID(obj.bc.displ(it,1))+obj.bc.displ(it,2)-1;%得到序号
                df=df-obj.K(:,index)*obj.bc.displ(it,3);
                u(index)=obj.bc.displ(it,3);%保存位移
                in=[in index];
            end
            activeindex=1:dof;
            
            %处理未被单元激活自由度
            hit=zeros(dof,1);%自由度被击中次数
            
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.objects(it);
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
            for it=1:size(obj.bc.force,1)
                index=obj.f.node.GetXuhaoByID(obj.bc.force(it,1))+obj.bc.force(it,2)-1;
                ft(index)=ft(index)+obj.bc.force(it,3);
                index_force=[index_force index];
            end
            f1=ft+df;
            
            %检查力是否加载在未被单元激活的自由度上
            [~,ia,~]=unique([index_force deadindex]);
            if length(index_force)+length(deadindex)>length(ia)
                error('matlab:myerror','力加载在未被单元激活的自由度上')
            end
            
            %求解
            K1=obj.K(activeindex,activeindex);%简化方程组 去除一部分自由度
            u1=K1\f1(activeindex);
            
            %处理求解后所有自由度上的力和位移
            
            u(activeindex)=u1;
            f=obj.K*u;
            %把结果保存到noderst
            obj.noderst.Reset();
            
            for it=1:obj.f.node.ndnum
                [~,id]=obj.f.node.nds.Get('index',it);
                xuhao=obj.f.node.GetXuhaoByID(id);
                obj.noderst.SetLine('displ',it,id,u(xuhao:xuhao+5)');
            end
            for it=1:obj.f.node.ndnum
                [~,id]=obj.f.node.nds.Get('index',it);
                xuhao=obj.f.node.GetXuhaoByID(id);
                obj.noderst.SetLine('force',it,id,f(xuhao:xuhao+5)');
            end
        end
        function GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            %形成节点与刚度矩阵的映射
            obj.f.node.SetupMapping();

            
            
            K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'组装刚度矩阵','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.objects(it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
    end
end

