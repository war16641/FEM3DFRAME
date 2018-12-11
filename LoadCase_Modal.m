classdef LoadCase_Modal<LoadCase
    %自振工况
    
    properties
        arg cell%求解参数:阶数 规格化形式
        
        mode%阵型矩阵
        w%周期信息
        

    end
    
    methods
        function obj = LoadCase_Modal(f,name)
            obj=obj@LoadCase(f,name);
            obj.rst=Result_Modal(obj);%覆盖原有结果对象 改为使用模态专用结果对象
            obj.arg={[],'k'};
        end
        function Solve(obj)
            obj.PreSolve();
            %调用算法求解特征值
            [obj.w,obj.mode]=LoadCase_Modal.GetInfoForFreeVibration_eig(obj.K1,obj.M1,obj.arg{1},obj.arg{2});
            if isempty(obj.arg{1})
                obj.arg{1}=size(obj.K1,1);
            end
            %处理求解后所有自由度上的力和位移 保存结果
            tic
            u1=obj.u_beforesolve;
            for it=1:length(obj.w)%这一块循环有点花时间
                w1=obj.w(it);
                mode1=obj.mode(:,it);
                obj.SetState(mode1);
%                 u1(obj.activeindex)=mode1;
%                 f1=obj.K*u1;
                obj.rst.Add(it,w1,[],[]);
            end
            toc

            

            
            
            %初始化结果指针
            obj.rst.SetPointer();
            
            
            
            
            


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
    methods(Static)
        function [w,mode]=GetInfoForFreeVibration_eig(k,m,nummode,fmt)
            %利用广义特征值 KV=BVD求解自振信息
            %nummode 可选 前几阶频率和振型
            if nargin==2
                nummode=size(k,1);
                fmt='m';%默认按质量阵归一化
            elseif nargin==3
                fmt='m';
            elseif nargin==4
                if isempty(nummode)
                    nummode=size(k,1);
                end
            else
                error('未知参数')
            end
            if length(k)==1%单自由度
                [mode,D]=eigs(m^-1*k,nummode,'sm');%输出频率按从小到大排列
            else%多自由度
                [mode,D]=eigs(k,m,nummode,'sm');%输出频率按从小到大排列
            end
            
            w=sqrt(diag(D));
            %规格化振型
            switch fmt
                case 'm'
                    for it=1:nummode
                        mn=mode(:,it)'*m*mode(:,it);
                        mode(:,it)=mode(:,it)/sqrt(mn);
                    end
                case 'k'%按弹性势能为1规格化
                    for it=1:nummode
                        mn=0.5*mode(:,it)'*k*mode(:,it);
                        mode(:,it)=mode(:,it)/sqrt(mn);
                    end
                otherwise
                    error('sd')
            end

        end
    end
end

