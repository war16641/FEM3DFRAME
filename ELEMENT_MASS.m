classdef ELEMENT_MASS<ELEMENT3DFRAME
    %质量单元
    
    properties
        xdir
        ydir
        zdir double %3个单位方向向量 均为行向量  x方向是 从i到j  z向在初始化是指定 y向根据xz推出(右手法则)
        const double%质量6*1
    end
    
    methods
        function obj = ELEMENT_MASS(varargin)
            %f     id      nds     const
            %f     id      nds     const    p
            
            %p向量 2*3 double 第一行是xdir 第二行是梁的p
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            %取定默认参数
            if nargin==4
                obj.const=varargin{4};
                xdir=[1 0 0];
                p=[0 0 1];%如若不指定方向 取总体坐标
            elseif nargin==5
                obj.const=varargin{4};
                xdir=varargin{5}(1,:);
                p=varargin{5}(2,:);
            else
                error('未知参数')  
            end
            
            %初始化方向
            ELEMENT_EULERBEAM.InitializeDir2(obj,xdir,p);
            
        end
        
        function Kel = GetKel(obj)
            %质量单元无刚度矩阵
            obj.Kel_=zeros(6,6);
            obj.Kel=zeros(6,6);
            Kel=obj.Kel;
            %计算从局部坐标到总体坐标的转换矩阵C 3*3
            xd=[1 0 0];yd=[0 1 0];zd=[0 0 1];%总体坐标
            C=[dot(obj.xdir,xd)      dot(obj.xdir,yd)      dot(obj.xdir,zd)
               dot(obj.ydir,xd)      dot(obj.ydir,yd)      dot(obj.ydir,zd)
               dot(obj.zdir,xd)      dot(obj.zdir,yd)      dot(obj.zdir,zd)];
           C=[C zeros(3,3);zeros(3,3) C];
           obj.C66=C;%保存单节点的转换矩阵
           
%            %计算有效自由度
%             obj.hitbyele=zeros(1,6);

        end
        function K=FormK(obj,K)
            obj.GetKel();
            %质量单元无刚度矩阵
        end
        function Mel=GetMel(obj)
            Mel_=diag([obj.const]);
            obj.Mel_=Mel_;
            
            %转换至总体坐标系
            C=obj.C66;
            Mel=C^-1*Mel_*C;
            obj.Mel=Mel;
        end
        function M=FormM(obj,M)
            obj.GetMel();%先计算单刚矩阵 总体坐标
            
            %将Kel拆为6*6的子矩阵送入总刚K
            n=length(obj.nds);
            for it1=1:n
                for it2=1:n
                    x=obj.nds(it1);
                    y=obj.nds(it2);
                    xuhao1=obj.f.node.GetXuhaoByID(x);%得到 节点号对应于刚度矩阵的序号
                    xuhao2=obj.f.node.GetXuhaoByID(y);
                    M(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=M(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+obj.Mel(6*it1-5:6*it1,6*it2-5:6*it2);
                end
            end
        end
        function [force,deform,eng]=GetEleResult(obj,varargin)%根据计算结果（节点位移） 计算单元力 变形
            varargin=Hull(varargin);
            force=zeros(1,6);
            deform=force;%质量节点没有力和变形 
            eng=[0 0 0];%势能动能耗能
            v=varargin{2};%寻找速度
            eng(2)=0.5*v*obj.Mel*v';
            
        end
        function InitialKT(obj)%初始化KTel Fsel
            
            sz=length(obj.nds)*6;
            obj.Fsel=zeros(sz,1);
            obj.KTel=zeros(sz,sz);
            
        end
        function SetState(obj,varargin)
            SetState@ELEMENT3DFRAME(obj,varargin);
        end
    end
end

