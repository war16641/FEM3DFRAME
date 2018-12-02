classdef LoadCase<handle & matlab.mixin.Heterogeneous
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        f FEM3DFRAME
        name char%工况名
        bc BC
        rst 
        
        dof%自由度数 未引入边界条件前
        activeindex%有效自由度索引
        f_ext double%外荷载力向量 引入边界条件前 由bc中force数据生成
        f_ext1 double%映入边界条件
        f_node double%节点力 由f_ext+df组成
        f_node1 double
        u_beforesolve double%求解前的位移向量（全自由度的） 保存位移荷载
        u double %求解后的位移向量 也可以说是 当前的位移向量（对于有多步荷载的工况） 全自由度
        u1 double %有效自由度
        K double%结构刚度矩阵 处理边界条件前
        M double
        C double
        K1 double%引入边界条件
        M1
        C1
        
    end
    
    methods
        function obj = LoadCase(f,name)
            obj.f=f;
            obj.name=name;
            obj.bc=BC(obj);
            obj.rst=Result(obj);
           

        end
        
        function AddBC(obj,type,ln)%ln=ndid,dir,value         dir=1~6
            obj.bc.Add(type,ln);
        end
        function CloneBC(obj,lc)%从其他工况复制BC
            for it=1:lc.bc.displ.num
                ln=lc.bc.displ.Get('index',it);
                obj.AddBC('displ',ln);
                
                
            end
            for it=1:lc.bc.force.num
                ln=lc.bc.force.Get('index',it);
                obj.AddBC('force',ln);
            end
        end
        function PreSolve(obj)%执行solve前 每个工况都需要执行的代码
            %纵自由度个数 所有自由度
            obj.dof=6*obj.f.node.ndnum;
            %形成节点与刚度矩阵的映射
            obj.f.node.SetupMapping();
            %形成线性刚度矩阵K
            obj.GetK();
            %形成M
            obj.GetM();
            %初始化非线性
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                e.InitialKT();
            end
            %检查边界条件是否重复
            obj.bc.Check();
            
            %根据工况的需要检查自己的bc条件是否有问题 checkbc是每个工况都要重写的函数（虚函数）
            obj.CheckBC();
            %初始化activeindex
            obj.activeindex=1:obj.dof;
            
            %处理位移边界荷载
            df=zeros(obj.dof,1);%因删除位移荷载自由度而生成的额外力向量
            displindex=[];%存储不激活的自由度 位移限制的自由度
            obj.u_beforesolve=zeros(obj.dof,1);%初始化求解前位移
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%得到序号
                df=df-obj.K(:,index)*ln(3);
                obj.u_beforesolve(index)=ln(3);%保存位移
                displindex=[displindex index];
            end
            obj.u=obj.u_beforesolve;%将当前位移置为求解前位移
            
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
            [~,ia,~]=unique([displindex deadindex]);
            if ia<length(displindex)+length(deadindex)
                warning('位移荷载对应的自由度与未被单元激活的自由度重叠。（当自由度缺少的单元在边界处时会出现这种情况，这是正常的，其他是异常的。')
            end
            
            %删除两种类型未激活的自由度
            obj.activeindex([displindex deadindex])=[];
            
            
            
            
            %处理力边界条件 生成f_ext
            index_force=[];%力荷载 击中的自由度序号
            obj.f_ext=zeros(obj.dof,1);
            for it=1:obj.bc.force.num
                ln=obj.bc.force.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;
                obj.f_ext(index)=obj.f_ext(index)+ln(3);
                index_force=[index_force index];
            end
            %生成 f_node
            obj.f_node=obj.f_ext+df;
            
            %检查力是否加载在未被单元激活的自由度上
            [~,ia,~]=unique([index_force deadindex]);
            if length(index_force)+length(deadindex)>length(ia)
                error('matlab:myerror','力加载在未被单元激活的自由度上')
            end
            
            %生成K1 f_node1
            obj.K1=obj.K(obj.activeindex,obj.activeindex);
            obj.M1=obj.M(obj.activeindex,obj.activeindex);
            obj.f_node1=obj.f_node(obj.activeindex);
        end
    end
    methods(Abstract)
        Solve(obj)
        GetK(obj)
        GetM(obj)
        CheckBC(obj)
    end
end

