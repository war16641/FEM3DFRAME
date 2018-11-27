classdef LoadCase_Earthquake<LoadCase
    %地震时程工况
    
    properties
        ei%地震波
        algorithm%算法名
        func%算法入口
        arg%参数
        damp DAMPING
        
        R%质量影响列向量 参见《桥梁抗震》 P72
        K1%边界条件处理后的三个矩阵
        M1
        C1 %在damp的make函数中生成
        R1 %质量影响列向量 引入边界条件后

    end
    
    methods
        function obj = LoadCase_Earthquake(f,name)
            obj=obj@LoadCase(f,name);
            obj.ei=[];
            obj.algorithm='';
            obj.arg={};
            obj.damp=DAMPING(obj);
            obj.K1=[];
            obj.M1=[];
            obj.C1=[];
        end
        
        function SetAlgorithm(obj,varargin)%设置算法
            switch varargin{1}
                case 'newmark'
                    obj.algorithm='newmark';
                    if length(varargin)~=3
                        error('matlab:myerror','newmark有2参数')
                    end
                    obj.func=@obj.Newmark;
                    obj.arg=varargin(2:end);
                otherwise
                    error('matlab:myerror','未知算法')
            end
        end
        function AddEarthquakeInput(obj,ei)%暂时只做成一条波
            obj.ei=ei;
        end
        function Solve(obj)
            obj.GetK();
            obj.GetM();
            dof=size(obj.K,1);
            %计算R
            obj.R=zeros(dof,3);
            tmp=1:6:6*dof;
            obj.R(tmp,1)=1;%ux uy uz的质量影响为1
            obj.R(tmp+1,2)=1;
            obj.R(tmp+2,3)=1;
            
            %检查边界条件是否重复
            obj.bc.Check();
            
            %K1为引入边界条件的总刚度矩阵
            
            u=zeros(dof,1);
            
            %先处理位移边界
            df=zeros(dof,1);
            
            in=[];%存储不激活的自由度 位移限制的自由度
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%得到序号
                df=df-obj.K(:,index)*ln(3);
                u(index)=ln(3);%保存位移
                if ln(3)~=0
                    error('matlab:myerror','自振工况不能出现位移不为0的边界条件')
                end
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
                if ln(3)~=0
                    error('matlab:myerror','自振工况不能出现力不为0的边界条件')
                end
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
            obj.K1=obj.K(activeindex,activeindex);%去除一部分自由度
            obj.M1=obj.M(activeindex,activeindex);
            obj.R1=obj.R(activeindex,:);
            
            %计算阻尼
            obj.damp.Make();%注意：在计算刚度 质量后计算阻尼
            
            %调用算法求解地震工况
            [v, dv, ddv ]=obj.func();
            
            %处理求解后所有自由度上的力和位移 保存结果
            for it=1:obj.ei.ew.numofpoint
                u(activeindex)=v(:,it);
                f=obj.K*u;
                obj.rst.AddTime(obj.ei.tn(it),f,u);
            end
            
            %统计结果
            

            
            
            %初始化结果指针
            obj.rst.SetPointer('time',1);

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
    methods(Access=private)
        function [v, dv, ddv ]=Newmark(obj)
            %newmark-β法求解多自由度动力响应 在地震作用下
            %要求结构是线性 K矩阵不变
            %算法参见《有限单元法》王 P480
            %K,M,C三个矩阵
            %v0是列向量 每个自由度上的初始位移 dv0 ddv0初始速度和加速度
            %F是矩阵 代表每个自由度上的力 一列代表某一时刻结构所受到的力 注意 F的列数与 time的列数相等 F第k列对应于t=（k-1)*dt时受力 F的第一列(0时刻)不重要
            %gamma beta两个参数 0.5,0.25常加速度
            %time 时间向量 与 F 对应 等差数列
            K=obj.K1;
            M=obj.M1;
            C=obj.C1;
            R=obj.R1;
            tmp=size(K,1);
            v0=zeros(tmp,1);
            dv0=v0;
            ddv0=v0;
            gamma=obj.arg{1};
            beta=obj.arg{2};
            time=obj.ei.tn;
            
            
            
            
            n=size(K,1);%自由度个数
            dt=time(2)-time(1);
            
            %% 检查gamma和beta的参数是否满足要求
            if gamma<0.5||beta<0.25*(0.5+gamma)^2
                %     error('参数gamma和beta不满足要求');
            end
            %% 将地面加速度转化为等效节点荷载
            timelen=length(time);
            F=zeros(n,timelen);
            for it=1:timelen
                F(:,it)=-M*R*obj.ei.accn(:,it);
            end
            %% 常数的计算
            c0=1/beta/dt^2;
            c1=gamma/beta/dt;
            c2=1/beta/dt;
            c3=1/2/beta-1;
            c4=gamma/beta-1;
            c5=dt/2*(gamma/beta-2);
            c6=dt*(1-gamma);
            c7=gamma*dt;
            %%
            Kpa=K+c0*M+c1*C;
            Kpali=Kpa^-1;
            %% 循环求解部分
            % len=floor(tend/dt);
            len=length(time);
            v=[ zeros(n,len)];v(:,1)=v0;
            dv=[zeros(n,len)];dv(:,1)=dv0;
            ddv=[zeros(n,len)];ddv(:,1)=ddv0;
            f=waitbar(0,'时程工况计算','Name','FEM3DFRAME');
            for it=2:len%it是当前要算的 已经算到it-1
                Fnowpa=F(:,it)+M*(c0*v(:,it-1)+c2*dv(:,it-1)+c3*ddv(:,it-1))+C*(c1*v(:,it-1)+c4*dv(:,it-1)+c5*ddv(:,it-1));
                v(:,it)=Kpali*Fnowpa;
                ddv(:,it)=c0*(v(:,it)-v(:,it-1))-c2*dv(:,it-1)-c3*ddv(:,it-1);
                dv(:,it)=dv(:,it-1)+c6*ddv(:,it-1)+c7*ddv(:,it);
                waitbar(it/len,f,['时程工况计算' num2str(it) '/' num2str(len)]);
            end
            close(f);
            %% 后处理 做出位移时程图

            %plot(time,v);
        end
    end
end

