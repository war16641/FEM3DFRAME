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
%             if isempty(obj.f.manager_sec.GetByIdentifier(varargin{4}.name))%这里只通过标识符查找 可以改进成根据对象是否完全一致
%                 error('MATLAB:myerror','没有这个截面')
%             end
            if ~obj.f.manager_sec.IsExist(varargin{4})
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
            
            %计算从局部坐标到总体坐标的转换矩阵C 3*3
            xd=[1 0 0];yd=[0 1 0];zd=[0 0 1];%总体坐标
            C=[dot(obj.xdir,xd)      dot(obj.xdir,yd)      dot(obj.xdir,zd)
               dot(obj.ydir,xd)      dot(obj.ydir,yd)      dot(obj.ydir,zd)
               dot(obj.zdir,xd)      dot(obj.zdir,yd)      dot(obj.zdir,zd)];
           C=[C zeros(3,3);zeros(3,3) C];
           C=[C zeros(6,6);zeros(6,6) C];%扩充到12自由度
           
           %得到总体坐标下的单刚
           Kel=C^-1*Kel_*C;
           obj.Kel=Kel;
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
    end

end

