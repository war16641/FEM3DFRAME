classdef ELEMENT_SPRING<ELEMENT3DFRAME
    %���ɵ�Ԫ
    
    properties
        xdir
        ydir
        zdir double %3����λ�������� ��Ϊ������  x������ ��i��j  z���ڳ�ʼ����ָ�� y�����xz�Ƴ�(���ַ���)
        const double %�˵�Ԫ�ĳ��� 1*6 double �ն�
    end
    
    methods
        function obj = ELEMENT_SPRING(varargin)  
            %f     id      nds     const
            %f     id      nds     const    p
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %ȡ��Ĭ�ϲ���
            if nargin==4
                obj.const=varargin{4};
                p=[];
            elseif nargin==5
                obj.const=varargin{4};
                p=varargin{5};
                
            else
                error('δ֪����')  
            end
            
            %��ʼ������
            ELEMENT_EULERBEAM.InitializeDir(obj,p);
        end
        
        function Kel = GetKel(obj)
            %��ʼ����Ч���ɶȾ���'
            obj.hitbyele=zeros(2,6);
            
            %���ɾֲ������µĵ���
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
            Kel_=MakeSymmetricMatrix(Kel_);%�Գ���
            obj.Kel_=Kel_;
            
            %����Ӿֲ����굽���������ת������C 3*3
            xd=[1 0 0];yd=[0 1 0];zd=[0 0 1];%��������
            C=[dot(obj.xdir,xd)      dot(obj.xdir,yd)      dot(obj.xdir,zd)
               dot(obj.ydir,xd)      dot(obj.ydir,yd)      dot(obj.ydir,zd)
               dot(obj.zdir,xd)      dot(obj.zdir,yd)      dot(obj.zdir,zd)];
           C=[C zeros(3,3);zeros(3,3) C];
           obj.C66=C;%���浥�ڵ��ת������
           C=[C zeros(6,6);zeros(6,6) C];%���䵽12���ɶ�
           
           %�õ����������µĵ���
           Kel=C^-1*Kel_*C;
           obj.Kel=Kel;
           
           %������Ч���ɶ�
            dg=diag(Kel);
            tmp=dg(1:6);
            tmp=abs(tmp)>1e-10;
            obj.hitbyele(1,tmp)=obj.hitbyele(1,tmp)+1;
            tmp=dg(7:12);
            tmp=abs(tmp)>1e-10;
            obj.hitbyele(2,tmp)=obj.hitbyele(2,tmp)+1;
            
        end
        function K=FormK(obj,K)
            obj.GetKel();%�ȼ��㵥�վ��� ��������
            
            %��Kel��Ϊ6*6���Ӿ��������ܸ�K
            n=length(obj.nds);
            for it1=1:n
                for it2=1:n
                    x=obj.nds(it1);
                    y=obj.nds(it2);
                    xuhao1=obj.f.node.GetXuhaoByID(x);%�õ� �ڵ�Ŷ�Ӧ�ڸնȾ�������
                    xuhao2=obj.f.node.GetXuhaoByID(y);
                    K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+obj.Kel(6*it1-5:6*it1,6*it2-5:6*it2);
                end
            end
        end
        function [force,deform]=GetEleResult(obj,varargin)
            %���ݼ��������ڵ�λ�ƣ� ���㵥Ԫ�� ����
            %varargin ֻ���������ڵ�ij�ı���2*6 
            if length(varargin)~=1
                error('matlab:myerror','�����ʽ')
            end
            ui=varargin{1}(1,:);
            uj=varargin{1}(2,:);%���ڵ�λ�� ��������
            deform_global=uj-ui;%��������ϵ�µı���
            cli=obj.C66^-1;
            deform=deform_global*cli;
            ui_local=ui*cli;
            uj_local=uj*cli;%���ڵ�λ�� �ֲ�����
            tmp=obj.Kel_*[ui_local uj_local]';
            force=[tmp(1:6)';tmp(7:12)'];%ת��Ϊn*6��ʽ
        end
    end
end

