classdef LoadCase_Earthquake<LoadCase
    %����ʱ�̹���
    
    properties
        ei%����
        algorithm%�㷨��
        func%�㷨���
        arg%����
        damp DAMPING
        
        R%����Ӱ�������� �μ����������� P72
        K1%�߽�������������������
        M1
        C1 %��damp��make����������
        R1 %����Ӱ�������� ����߽�������

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
        
        function SetAlgorithm(obj,varargin)%�����㷨
            switch varargin{1}
                case 'newmark'
                    obj.algorithm='newmark';
                    if length(varargin)~=3
                        error('matlab:myerror','newmark��2����')
                    end
                    obj.func=@obj.Newmark;
                    obj.arg=varargin(2:end);
                otherwise
                    error('matlab:myerror','δ֪�㷨')
            end
        end
        function AddEarthquakeInput(obj,ei)%��ʱֻ����һ����
            obj.ei=ei;
        end
        function Solve(obj)
            obj.GetK();
            obj.GetM();
            dof=size(obj.K,1);
            %����R
            obj.R=zeros(dof,3);
            tmp=1:6:6*dof;
            obj.R(tmp,1)=1;%ux uy uz������Ӱ��Ϊ1
            obj.R(tmp+1,2)=1;
            obj.R(tmp+2,3)=1;
            
            %���߽������Ƿ��ظ�
            obj.bc.Check();
            
            %K1Ϊ����߽��������ܸնȾ���
            
            u=zeros(dof,1);
            
            %�ȴ���λ�Ʊ߽�
            df=zeros(dof,1);
            
            in=[];%�洢����������ɶ� λ�����Ƶ����ɶ�
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%�õ����
                df=df-obj.K(:,index)*ln(3);
                u(index)=ln(3);%����λ��
                if ln(3)~=0
                    error('matlab:myerror','���񹤿����ܳ���λ�Ʋ�Ϊ0�ı߽�����')
                end
                in=[in index];
            end
            activeindex=1:dof;
            
            %����δ����Ԫ�������ɶ�
            hit=zeros(dof,1);%���ɶȱ����д���
            
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                for it1=1:length(e.nds)
                    xh=obj.f.node.GetXuhaoByID(e.nds(it1));
                    hit(xh:xh+5)=hit(xh:xh+5)+e.hitbyele(it1,:)';%hit��1
                end
            end
            %�ռ�δ����Ԫ��������ɶ�
            tmp=1:dof;
            deadindex=tmp(hit==0);
            %���δ����Ԫ��������ɶ���Ϣ
            if ~isempty(deadindex)
                disp('����δ����Ԫ��������ɶ�')
            end
            for it=1:length(deadindex)
                [id,~,label]=obj.f.node.GetIdByXuhao(deadindex(it));
                disp(['�ڵ�' num2str(id) ' ' label]);
            end
            
            %λ�ƺ��ض�Ӧ�����ɶ���δ����Ԫ��������ɶ��Ƿ��ص� �����ɶ�ȱ�ٵĵ�Ԫ�ڱ߽紦ʱ ������������
            [~,ia,~]=unique([in deadindex]);
            if ia<length(in)+length(deadindex)
                warning('λ�ƺ��ض�Ӧ�����ɶ���δ����Ԫ��������ɶ��ص����������ɶ�ȱ�ٵĵ�Ԫ�ڱ߽紦ʱ�����������������������ģ��������쳣�ġ�')
            end
            %ɾ����������δ��������ɶ�
            activeindex([in deadindex])=[];
            
            %�������߽�����
            index_force=[];%������ ���е����ɶ����
            ft=zeros(dof,1);
            for it=1:obj.bc.force.num
                ln=obj.bc.force.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;
                if ln(3)~=0
                    error('matlab:myerror','���񹤿����ܳ�������Ϊ0�ı߽�����')
                end
                ft(index)=ft(index)+ln(3);
                index_force=[index_force index];
            end
            f1=ft+df;
            
            %������Ƿ������δ����Ԫ��������ɶ���
            [~,ia,~]=unique([index_force deadindex]);
            if length(index_force)+length(deadindex)>length(ia)
                error('matlab:myerror','��������δ����Ԫ��������ɶ���')
            end
            
            %�γɸն� ���� ���� ����߽�������
            obj.K1=obj.K(activeindex,activeindex);%ȥ��һ�������ɶ�
            obj.M1=obj.M(activeindex,activeindex);
            obj.R1=obj.R(activeindex,:);
            
            %��������
            obj.damp.Make();%ע�⣺�ڼ���ն� �������������
            
            %�����㷨�����𹤿�
            [v, dv, ddv ]=obj.func();
            
            %���������������ɶ��ϵ�����λ�� ������
            for it=1:obj.ei.ew.numofpoint
                u(activeindex)=v(:,it);
                f=obj.K*u;
                obj.rst.AddTime(obj.ei.tn(it),f,u);
            end
            
            %ͳ�ƽ��
            

            
            
            %��ʼ�����ָ��
            obj.rst.SetPointer('time',1);

        end
        function GetK(obj)
            %K���ܸնȾ���(�߽���������ǰ) ����Ϊ6*�ڵ����
            
            %�γɽڵ���նȾ����ӳ��
            obj.f.node.SetupMapping();

            
            
            obj.K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'��װ�նȾ���','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['��װ�նȾ���' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.K=e.FormK(obj.K);
                
            end
            close(f);
        end
        function GetM(obj)%��װ�������󣨱߽���������֮ǰ) ����ȵ���GetM�γ�ӳ��
            %M������������(�߽���������ǰ) ����Ϊ6*�ڵ����
            
            
            
            
            obj.M=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'��װ��������','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['��װ�նȾ���' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.M=e.FormM(obj.M);
                
            end
            close(f);
        end
    end
    methods(Access=private)
        function [v, dv, ddv ]=Newmark(obj)
            %newmark-�·��������ɶȶ�����Ӧ �ڵ���������
            %Ҫ��ṹ������ K���󲻱�
            %�㷨�μ������޵�Ԫ������ P480
            %K,M,C��������
            %v0�������� ÿ�����ɶ��ϵĳ�ʼλ�� dv0 ddv0��ʼ�ٶȺͼ��ٶ�
            %F�Ǿ��� ����ÿ�����ɶ��ϵ��� һ�д���ĳһʱ�̽ṹ���ܵ����� ע�� F�������� time��������� F��k�ж�Ӧ��t=��k-1)*dtʱ���� F�ĵ�һ��(0ʱ��)����Ҫ
            %gamma beta�������� 0.5,0.25�����ٶ�
            %time ʱ������ �� F ��Ӧ �Ȳ�����
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
            
            
            
            
            n=size(K,1);%���ɶȸ���
            dt=time(2)-time(1);
            
            %% ���gamma��beta�Ĳ����Ƿ�����Ҫ��
            if gamma<0.5||beta<0.25*(0.5+gamma)^2
                %     error('����gamma��beta������Ҫ��');
            end
            %% ��������ٶ�ת��Ϊ��Ч�ڵ����
            timelen=length(time);
            F=zeros(n,timelen);
            for it=1:timelen
                F(:,it)=-M*R*obj.ei.accn(:,it);
            end
            %% �����ļ���
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
            %% ѭ����ⲿ��
            % len=floor(tend/dt);
            len=length(time);
            v=[ zeros(n,len)];v(:,1)=v0;
            dv=[zeros(n,len)];dv(:,1)=dv0;
            ddv=[zeros(n,len)];ddv(:,1)=ddv0;
            f=waitbar(0,'ʱ�̹�������','Name','FEM3DFRAME');
            for it=2:len%it�ǵ�ǰҪ��� �Ѿ��㵽it-1
                Fnowpa=F(:,it)+M*(c0*v(:,it-1)+c2*dv(:,it-1)+c3*ddv(:,it-1))+C*(c1*v(:,it-1)+c4*dv(:,it-1)+c5*ddv(:,it-1));
                v(:,it)=Kpali*Fnowpa;
                ddv(:,it)=c0*(v(:,it)-v(:,it-1))-c2*dv(:,it-1)-c3*ddv(:,it-1);
                dv(:,it)=dv(:,it-1)+c6*ddv(:,it-1)+c7*ddv(:,it);
                waitbar(it/len,f,['ʱ�̹�������' num2str(it) '/' num2str(len)]);
            end
            close(f);
            %% ���� ����λ��ʱ��ͼ

            %plot(time,v);
        end
    end
end

