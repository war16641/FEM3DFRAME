classdef ELEMENT_EULERBEAM<ELEMENT3DFRAME
    %欧拉梁
    
    properties
        sec SECTION%截面
        xdir
        ydir
        zdir double %3个单位方向向量 均为行向量  x方向是 从i到j  z向在初始化是指定 y向根据xz推出(右手法则)
        endrelease char%杆端弯矩释放信息
    end
    
    methods
        function obj = ELEMENT_EULERBEAM(varargin)
            %f,id,nds,sec,p,endrelease
            %p向量(可选默认是0,0,1 或0,1,0当x方向是0,0,1时)
            %endrelease杆端弯矩释放信息 可为''不释放
%                                          'i'释放i端
%                                          'j'
%                                          'ij'都释放
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %检查截面是否存在
%             if isempty(obj.f.manager_sec.GetByIdentifier(varargin{4}.name))%这里只通过标识符查找 可以改进成根据对象是否完全一致
%                 error('MATLAB:myerror','没有这个截面')
%             end
            %赋予截面
            if ~obj.f.manager_sec.IsExist(varargin{4})
                error('MATLAB:myerror','没有这个截面')
            end
            obj.sec=varargin{4};
            
            %以下为不定参数的初始化 先将为指定的参数按照默认参数取定
            if nargin==4%未指定zdir和endrelease 
                p=[];
                endrelease='';
            elseif nargin==5%指定zdir的平面（由xdir和p构成的平面）
                p=varargin{5};
                endrelease='';
            elseif nargin==6%指定所有参数
                p=varargin{5};
                endrelease=varargin{6};              
            else
                error('未知参数')  
            end
            
            %根据取定的所有参数进行初始化
            
            %定向
            ELEMENT_EULERBEAM.InitializeDir(obj,p)
            
            %杆端释放信息
            obj.endrelease=endrelease;

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
            
            
            %按杆端释放信息调整刚度矩阵 %有问题
            %注意：两个节点的转角不能同时释放
            switch char(obj.endrelease)
                case ''%不释放
                    index_release=[];%释放的自由度
                    index_reserve=1:12;
                    index_reserve(index_release)=[];%保留的自由度
                case 'i'%释放i端
                    index_release=[4 5 6 ];%释放的自由度
                    index_reserve=1:12;
                    index_reserve(index_release)=[];%保留的自由度
                case 'j'%释放j端
                    index_release=[ 10 11 12];%释放的自由度
                    index_reserve=1:12;
                    index_reserve(index_release)=[];%保留的自由度
                case 'ij'
                    index_release=[4 5 6  11 12];%释放的自由度
%                     index_release=[ 5 6  11 12];%释放的自由度
                    index_reserve=1:12;
                    index_reserve(index_release)=[];%保留的自由度                    
                otherwise
                    error('matlab:myerror','sd')
            end
            if ~isempty(index_release)%有需要释放的自由度
                %静力凝聚后剩下的刚度矩阵
                Kel_reserve=Kel_(index_reserve,index_reserve)-Kel_(index_reserve,index_release)*Kel_(index_release,index_release)^-1*Kel_(index_release,index_reserve);
                %补充0元素至12*12
                Kel_=zeros(12,12);
                Kel_(index_reserve,index_reserve)=Kel_reserve;
            end
            obj.Kel_=Kel_;%保存局部坐标单刚
            
            
            
            
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
           
%            %计算有效自由度
%             dg=diag(Kel);
%             tmp=dg(1:6);
%             tmp=abs(tmp)>1e-10;
%             obj.hitbyele(1,tmp)=obj.hitbyele(1,tmp)+1;
%             tmp=dg(7:12);
%             tmp=abs(tmp)>1e-10;
%             obj.hitbyele(2,tmp)=obj.hitbyele(2,tmp)+1;
            
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
        function [force,deform,eng]=GetEleResult(obj,varargin)
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
            
            %能量
            eng=[0 0 0];
        end
        function Mel=GetMel(obj)%组装质量矩阵
            
            %参数准备
            rou=obj.sec.mat.rou;%密度
            L=obj.f.node.Distance(obj.nds(1),obj.nds(2));%单元长度
            J=obj.sec.J;
            A=obj.sec.A;
            Mel_=A*[rou*L/3	0	0	0	0	0	rou*L/6	0	0	0	0	0
                0	156*rou*L/420	0	0	0	22*rou*L^2/420	0	54*rou*L/420	0	0	0	-13*rou*L^2/420
                0	0	156*rou*L/420	0	22*rou*L^2/420	0	0	0	54*rou*L/420	0	-13*rou*L^2/420	0
                0	0	0	rou*J*L/3	0	0	0	0	0	rou*J*L/6	0	0
                0	0	0	0	4*rou*L^3/420	0	0	0	13*rou*L^2/420	0	-3*rou*L^3/420	0
                0	0	0	0	0	4*rou*L^3/420	0	13*rou*L^2/420	0	0	0	-3*rou*L^3/420
                0	0	0	0	0	0	rou*L/3	0	0	0	0	0
                0	0	0	0	0	0	0	156*rou*L/420	0	0	0	-22*rou*L^2/420
                0	0	0	0	0	0	0	0	156*rou*L/420	0	-22*rou*L^2/420	0
                0	0	0	0	0	0	0	0	0	rou*J*L/3	0	0
                0	0	0	0	0	0	0	0	0	0	4*rou*L^3/420	0
                0	0	0	0	0	0	0	0	0	0	0	4*rou*L^3/420
                ];
            Mel_=MakeSymmetricMatrix(Mel_);%对称阵
            obj.Mel_=Mel_;
            
            %转换至总体坐标系
            C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66];
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
        function InitialKT(obj)%初始化KTel Fsel
            sz=length(obj.nds)*6;
            obj.Fsel=zeros(sz,1);
            obj.KTel=zeros(sz,sz);
        end
        function SetState(obj,varargin)
            SetState@ELEMENT3DFRAME(obj,varargin);
        end
    end
    methods(Static)
        function InitializeDir(obj,p)%初始化xdir ydir zdir三个向量 此函数的作用时给具有方向的单元（梁 连接单元）一个默认的方向
            if isempty(p)%不指定zdir定向向量p
                obj.xdir=obj.f.node.DirBy2Node(obj.nds(1),obj.nds(2));
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
            else
                obj.xdir=obj.f.node.DirBy2Node(obj.nds(1),obj.nds(2));
                p=VectorDirection(p,'row');%转化为行向量
                p=p/norm(p);%单位化
                dot1=dot(p,obj.xdir);
                beta=sqrt(1/(1-dot1^2));
                alpha=-dot1*beta;
                obj.zdir=alpha*obj.xdir+beta*p;
                obj.ydir=cross(obj.zdir,obj.xdir);%叉乘得y向
            end
        end
        function InitializeDir2(obj,xdir,p)%初始化xdir ydir zdir三个向量 指定xdir
            if isempty(p)%不指定zdir定向向量p
                obj.xdir=xdir/norm(xdir);
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
            else
                obj.xdir=xdir/norm(xdir);
                p=VectorDirection(p,'row');%转化为行向量
                p=p/norm(p);%单位化
                dot1=dot(p,obj.xdir);
                beta=sqrt(1/(1-dot1^2));
                alpha=-dot1*beta;
                obj.zdir=alpha*obj.xdir+beta*p;
                obj.ydir=cross(obj.zdir,obj.xdir);%叉乘得y向
            end
        end
    end
end

