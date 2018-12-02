classdef LoadCase_Earthquake<LoadCase
    %地震时程工况
    
    properties
        ei%地震波
        algorithm%算法名
        func%算法入口
        arg%参数
        damp DAMPING
        intd InitialDispl%初始位移
        
        R%质量影响列向量 参见《桥梁抗震》 P72
        R1 %质量影响列向量 引入边界条件后

 
        md%模态坐标 有时会用到

    end
    properties(Access=private)

    end
    
    methods
        function obj = LoadCase_Earthquake(f,name)
            obj=obj@LoadCase(f,name);
            obj.ei=[];
            obj.algorithm='';
            obj.arg={};
            obj.damp=DAMPING(obj);
            obj.intd=InitialDispl(obj);
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
            obj.PreSolve();
            %计算R
            obj.R=zeros(obj.dof,3);
            tmp=1:6:6*obj.dof;
            obj.R(tmp,1)=1;%ux uy uz的质量影响为1
            obj.R(tmp+1,2)=1;
            obj.R(tmp+2,3)=1;
            
            %形成刚度 质量 矩阵 引入边界条件后
            obj.R1=obj.R(obj.activeindex,:);

            %计算阻尼
            obj.damp.Make();%注意：在计算刚度 质量后计算阻尼
            
            %计算初始位移条件
            obj.intd.MakeU0();

            %调用算法求解地震工况
            [v, dv, ddv ]=obj.func();
            
            %初始化结果指针
            obj.rst.SetPointer('time',1);
            
            


        end
        function GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            

            
            
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
        function md=MakeModalDispl(obj,mlc)%计算模态坐标
            %首先验证两者的activeindex是否一致
            if norm(obj.activeindex-mlc.activeindex)~=0
                error('nyh:error','要求modal工况的有效自由度和本工况一致，不一致可能是边界条件不同导致的。')
            end
            
            %检查modal工况是否用刚度规格化阵型
            if 'k'~=mlc.arg{2}
                error('nyh:error','要求modal工况的使用刚度规格化阵型。')%这个条件不是必须条件。但是刚度规格化可以方便地使用模态坐标表示应变能。
            end
            
            %求解模态坐标
            md=ModalDispl(mlc,obj);
            obj.md=md;
        end

        function CheckBC(obj)
            %要求位移边界条件全是0
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                if ln(3)~=0
                    error('matlab:myerror','自振工况不能出现位移不为0的边界条件')
                end
            end
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
            deadf1=obj.f_ext(obj.activeindex);%恒载 有效自由度
            tmp=size(K,1);
            v0=obj.intd.u0(obj.activeindex);
            dv0=zeros(tmp,1);
%             ddv0=zeros(tmp,1);
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
                F(:,it)=-M*R*obj.ei.accn(:,it)+deadf1;%这里记得加上恒载力
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
            u=obj.u_beforesolve;%结构的位移列向量  都是0
            u_t=u;
            u_tt=u;
            %% 循环求解部分
            % len=floor(tend/dt);
            len=length(time);
            v=[ zeros(n,len)];v(:,1)=v0;
            dv=[zeros(n,len)];dv(:,1)=dv0;
            ddv=[zeros(n,len)];ddv0=M^-1*(F(:,1)-C*dv0-K*v0);ddv(:,1)=ddv0;
            %计算-1步的位移速度加速度
            tmp=size(K,1);
            b=[dv0-gamma*dt*ddv0
                v0-beta*dt^2*ddv0
                zeros(tmp,1)];
            A=[zeros(tmp,tmp) eye(tmp) (1-gamma)*dt*eye(tmp)
               eye(tmp)      dt*eye(tmp) (0.5-beta)*dt^2*eye(tmp)
               K               C                 M];
            tmp2=A^-1*b;
            vf1=tmp2(1:tmp);
            dvf1=tmp2(tmp+1:2*tmp);
            ddvf1=tmp2(2*tmp+1:end);
            
            %载入初始位移
            u(obj.activeindex)=v0;
            u_t(obj.activeindex)=dv0;
            u_tt(obj.activeindex)=ddv0;
            %计算增量
            F_inc=F;
            F_inc(:,2:end)=F(:,2:end)-F(:,1:end-1);%荷载增量=目标步值-上步值
            v_inc_last=v(:,1)-vf1;%上一步位移增量
            dv_inc_last=dv(:,1)-dvf1;%上一步速度增量
            ddv_inc_last=ddv(:,1)-ddvf1;%上一步加速度增量
            obj.rst.AddTime(time(1),obj.K*u,u);%写入第一步的结果
            wb=waitbar(0,'时程工况计算','Name','FEM3DFRAME');
            for it=2:len%it是当前要算的 即目标步 已经算到it-1 即上一步

                Fpa_inc=F_inc(:,it)+M*(c0*v_inc_last+c2*dv_inc_last+c3*ddv_inc_last)+C*(c1*v_inc_last+c4*dv_inc_last+c5*ddv_inc_last);%目标步等效荷载增量
                v_inc=Kpali*Fpa_inc;%目标步位移增量
                %计算出位移 速度 加速度值
                v(:,it)=v(:,it-1)+v_inc;%位移
                ddv(:,it)=c0*v_inc-c2*dv(:,it-1)-c3*ddv(:,it-1);%加速度
                dv(:,it)=dv(:,it-1)+c6*ddv(:,it-1)+c7*ddv(:,it);
                
                
                waitbar(it/len,wb,['时程工况计算' num2str(it) '/' num2str(len)]);%更新wb
                
                %将当前步的计算结果保存到fem中
                u(obj.activeindex)=v(:,it);%结构的位移列向量
                u_t(obj.activeindex)=dv(:,it);
                u_tt(obj.activeindex)=ddv(:,it);
                f=obj.K*u;%结构的受力
                obj.rst.AddTime(time(it),f,u,u_t,u_tt);%保存结果
                
                %更新位移速度加速度的 上一步增量
                v_inc_last=v_inc;
                dv_inc_last=dv(:,it)-dv(:,it-1);
                ddv_inc_last=ddv(:,it)-ddv(:,it-1);
            end
            close(wb);

        end
    end
end

