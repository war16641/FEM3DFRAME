classdef ELEMENT_EULERBEAM<ELEMENT3DFRAME
    %ŷ����
    
    properties
        sec SECTION%����
        xdir
        ydir
        zdir double %3����λ�������� ��Ϊ������  x������ ��i��j  z���ڳ�ʼ����ָ�� y�����xz�Ƴ�(���ַ���)
    end
    
    methods
        function obj = ELEMENT_EULERBEAM(varargin)
            %f,id,nds,sec,p����(��ѡĬ����0,0,1 ��0,1,0��x������0,0,1ʱ)
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %�������Ƿ����
            if isempty(obj.f.manager_sec.GetByIdentifier(varargin{4}.name))%����ֻͨ����ʶ������ ���ԸĽ��ɸ��ݶ����Ƿ���ȫһ��
                error('MATLAB:myerror','û���������')
            end
            
            if nargin==4%δָ��zdir                
                obj.sec=varargin{4};
                i=varargin{3}(1);
                j=varargin{3}(2);
                obj.xdir=obj.f.node.DirBy2Node(i,j);
                if isequal([0 0 1],obj.xdir)%x��Ϊ����
                    obj.ydir=[1 0 0];
                    obj.zdir=[0 1 0];%z��Ϊ�����Y��
                else%x��Ϊ����
                    %z��Ϊ����Z���x��ƽ����
                    x1=obj.xdir(1);y1=obj.xdir(2);z1=obj.xdir(3);
                    alpha=-z1*sqrt(1/(1-z1^2));
                    beta=sqrt(1/(1-z1^2));
                    obj.zdir=alpha*obj.xdir+beta*[0 0 1];
                    obj.ydir=cross(obj.zdir,obj.xdir);%��˵�y��
                end
            elseif nargin==5%ָ��zdir��ƽ�棨��xdir��p���ɵ�ƽ�棩
                obj.sec=varargin{4};
                i=varargin{3}(1);
                j=varargin{3}(2);
                obj.xdir=obj.f.node.DirBy2Node(i,j);
                
                p=varargin{5};
                p=VectorDirection(p,'row');%ת��Ϊ������
                p=p/norm(p);%��λ��
                dot1=dot(p,obj.xdir);
                beta=sqrt(1/(1-dot1^2));
                alpha=-dot1*beta;
                obj.zdir=alpha*obj.xdir+beta*p;
                obj.ydir=cross(obj.zdir,obj.xdir);%��˵�y��
            else
                error('δ֪����')
                
                
            end

        end
        
        function Kel = GetKel(obj)
            %һ���ڵ�6���ɶ�
            E=obj.sec.mat.E;
            A=obj.sec.A;
            Iy=obj.sec.Iy;
            Iz=obj.sec.Iz;
            G=obj.sec.mat.G;
            J=obj.sec.J;
            L=obj.f.node.Distance(obj.nds(1),obj.nds(2));%��Ԫ����
            %�ֲ������µĵ���
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
            Kel_=MakeSymmetricMatrix(Kel_);%�Գ���
            Kel=Kel_;
            
        end
        function K=FormK(obj,K)
            K=K+1;
        end
    end

end

