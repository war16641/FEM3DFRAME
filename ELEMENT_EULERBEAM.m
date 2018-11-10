classdef ELEMENT_EULERBEAM<ELEMENT3DFRAME
    %欧拉梁
    
    properties
        sec SECTION%截面
        xdir
        ydir
        zdir double %3个单位方向向量 均为行向量  x方向是 从i到j  z向在初始化是指定 y向根据xz推出(右手法则)
    end
    
    methods
        function obj = ELEMENT_EULERBEAM(varargin)
            %f,id,nds,sec,p向量(可选默认是0,0,1 或0,1,0当x方向是0,0,1时)
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %检查截面是否存在
            if isempty(obj.f.manager_sec.GetByIdentifier(varargin{4}.name))%这里只通过标识符查找 可以改进成根据对象是否完全一致
                error('MATLAB:myerror','没有这个截面')
            end
            
            if nargin==4%未指定zdir                
                obj.sec=varargin{4};
                i=varargin{3}(1);
                j=varargin{3}(2);
                obj.xdir=obj.f.node.DirBy2Node(i,j);
                if isequal([0 0 1],obj.xdir)%x向为竖向
                    obj.ydir=[1 0 0];
                    obj.zdir=[0 1 0];%z向为整体的Y向
                else%x向不为竖向
                    %z向为整体Z向和x向平面内
                    x1=obj.xdir(1);y1=obj.xdir(2);z1=obj.xdir(3);
                    alpha=-z1*sqrt(1/(1-z1^2));
                    beta=sqrt(1/(1-z1^2));
                    obj.zdir=alpha*obj.xdir+beta*[0 0 1];
                    obj.ydir=cross(obj.zdir,obj.xdir);%叉乘得y向
                end
            elseif nargin==5%指定zdir的平面（由xdir和p构成的平面）
                obj.sec=varargin{4};
                i=varargin{3}(1);
                j=varargin{3}(2);
                obj.xdir=obj.f.node.DirBy2Node(i,j);
                
                p=varargin{5};
                p=VectorDirection(p,'row');%转化为行向量
                p=p/norm(p);%单位化
                dot1=dot(p,obj.xdir);
                beta=sqrt(1/(1-dot1^2));
                alpha=-dot1*beta;
                obj.zdir=alpha*obj.xdir+beta*p;
                obj.ydir=cross(obj.zdir,obj.xdir);%叉乘得y向
            else
                error('未知参数')
                
                
            end

        end
        
        function Kel = GetKel(obj)
            %一个节点6自由度
            E=obj.sec.mat.E;
            A=obj.sec.A;
            Iy=obj.sec.Iy;
            Iz=obj.sec.Iz;
            G=obj.sec.mat.G;
            J=obj.sec.J;
            L=obj.f.node.Distance(obj.nds(1),obj.nds(2));%单元长度
            %局部坐标下的单刚
            %   ux1    |   uy1    |    uz1   |    rx1   |    ry1   |   rz1    |   ux2    |   uy2    |    uz2   |    rx2   |    ry2   |   rz2    |
            Kel_=[   E*A/L      0         0             0          0        0          -E*A/L      0            0         0            0        0
                0      12*E*Iz/L^3    0           0          0     6*E*Iz/L^2     0      -12*E*Iz/L^3   0         0          0       6*E*Iz/L^2
                0         0      12*E*Iy/L^3     0      -6*E*Iy/L^2  0           0           0      -12*E*Iy/L^3  0        -6*E*Iy/L^2   0
                0         0           0      G*J/L         0           0         0            0         0          -G*J/L     0          0
                0         0           0          0        4*E*Iy/L    0          0           0          6*E*Iy/L^2   0      2*E*Iy/L      0
                0         0           0          0          0         4*E*Iz/L   0       -6*E*Iz/L^2   0         0             0       2*E*Iz/L
                0         0           0          0          0         0          E*A/L   0             0             0          0           0
                0         0           0          0          0         0          0        12*E*Iz/L^3    0         0          0        -6*E*Iz/L^2
                0         0           0          0          0         0          0           0          12*E*Iy/L^3   0    6*E*Iy/L^2       0
                0         0           0           0         0          0          0          0          0        G*J/L       0              0
                0         0           0          0          0         0           0          0          0           0      4*E*Iy/L       0
                0         0           0          0          0         0           0          0          0           0        0           4*E*Iz/L];
            Kel_=MakeSymmetricMatrix(Kel_);%对称阵
            Kel=Kel_;
            
        end
        function K=FormK(obj,K)
            K=K+1;
        end
    end

end

