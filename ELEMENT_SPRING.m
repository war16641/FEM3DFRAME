classdef ELEMENT_SPRING<ELEMENT3DFRAME
    %弹簧单元
    
    properties
        xdir
        ydir
        zdir double %3个单位方向向量 均为行向量  x方向是 从i到j  z向在初始化是指定 y向根据xz推出(右手法则)
        const double %此单元的常数 1*6 double 刚度
    end
    
    methods
        function obj = ELEMENT_SPRING(varargin)  
            %f     id      nds     const
            %f     id      nds     const    p
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %取定默认参数
            if nargin==4
                obj.const=varargin{4};
                p=[];
            elseif nargin==5
                obj.const=varargin{4};
                p=varargin{5};
                
            else
                error('未知参数')  
            end
            
            %初始化方向
            ELEMENT_EULERBEAM.InitializeDir(obj,p);
        end
        
        function Kel = GetKel(obj)
            %初始化有效自由度矩阵'
            obj.hitbyele=zeros(2,6);
            
            %生成局部坐标下的单刚
            kx=obj.const(1);
            ky=obj.const(2);
            kz=obj.const(3);
            krx=obj.const(4);
            kry=obj.const(5);
            krz=obj.const(6);
            Kel_=[kx	0	0	0	0	0	-kx	0	0	0	0	0
                0	ky	0	0	0	0	0	-ky	0	0	0	0
                0	0	kz	0	0	0	0	0	-kz	0	0	0
                0	0	0	krx	0	0	0	0	0	-krx	0	0
                0	0	0	0	kry	0	0	0	0	0	-kry	0
                0	0	0	0	0	krz	0	0	0	0	0	-krz
                0	0	0	0	0	0	kx	0	0	0	0	0
                0	0	0	0	0	0	0	ky	0	0	0	0
                0	0	0	0	0	0	0	0	kz	0	0	0
                0	0	0	0	0	0	0	0	0	krx	0	0
                0	0	0	0	0	0	0	0	0	0	kry	0
                0	0	0	0	0	0	0	0	0	0	0	krz
                ];
            Kel_=MakeSymmetricMatrix(Kel_);%对称阵
            obj.Kel_=Kel_;
            
            %计算从局部坐标到总体坐标的转换矩阵C 3*3
            xd=[1 0 0];yd=[0 1 0];zd=[0 0 1];%总体坐标
            C=[dot(obj.xdir,xd)      dot(obj.xdir,yd)      dot(obj.xdir,zd)
               dot(obj.ydir,xd)      dot(obj.ydir,yd)      dot(obj.ydir,zd)
               dot(obj.zdir,xd)      dot(obj.zdir,yd)      dot(obj.zdir,zd)];
           C=[C zeros(3,3);zeros(3,3) C];
           obj.C66=C;%保存单节点的转换矩阵
           C=[C zeros(6,6);zeros(6,6) C];%扩充到12自由度
           
           %得到总体坐标下的单刚
           Kel=C^-1*Kel_*C;
           obj.Kel=Kel;
           
           %计算有效自由度
            dg=diag(Kel);
            tmp=dg(1:6);
            tmp=abs(tmp)>1e-10;
            obj.hitbyele(1,tmp)=obj.hitbyele(1,tmp)+1;
            tmp=dg(7:12);
            tmp=abs(tmp)>1e-10;
            obj.hitbyele(2,tmp)=obj.hitbyele(2,tmp)+1;
            
        end
        function K=FormK(obj,K)
            obj.GetKel();%先计算单刚矩阵 总体坐标
            
            %将Kel拆为6*6的子矩阵送入总刚K
            n=length(obj.nds);
            for it1=1:n
                for it2=1:n
                    x=obj.nds(it1);
                    y=obj.nds(it2);
                    xuhao1=obj.f.node.GetXuhaoByID(x);%得到 节点号对应于刚度矩阵的序号
                    xuhao2=obj.f.node.GetXuhaoByID(y);
                    K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+obj.Kel(6*it1-5:6*it1,6*it2-5:6*it2);
                end
            end
        end
        function [force,deform]=GetEleResult(obj,varargin)
            %根据计算结果（节点位移） 计算单元力 变形
            %varargin 只输入两个节点ij的变形2*6 
            if length(varargin)~=1
                error('matlab:myerror','错误格式')
            end
            ui=varargin{1}(1,:);
            uj=varargin{1}(2,:);%两节点位移 总体坐标
            deform_global=uj-ui;%整体坐标系下的变形
            cli=obj.C66^-1;
            deform=deform_global*cli;
            ui_local=ui*cli;
            uj_local=uj*cli;%两节点位移 局部坐标
            tmp=obj.Kel_*[ui_local uj_local]';
            force=[tmp(1:6)';tmp(7:12)'];%转化为n*6形式
        end
    end
end

