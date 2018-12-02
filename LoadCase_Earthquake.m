classdef LoadCase_Earthquake<LoadCase
    %����ʱ�̹���
    
    properties
        ei%����
        algorithm%�㷨��
        func%�㷨���
        arg%����
        damp DAMPING
        intd InitialDispl%��ʼλ��
        
        R%����Ӱ�������� �μ����������� P72
        R1 %����Ӱ�������� ����߽�������

 
        md%ģ̬���� ��ʱ���õ�

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
            obj.PreSolve();
            %����R
            obj.R=zeros(obj.dof,3);
            tmp=1:6:6*obj.dof;
            obj.R(tmp,1)=1;%ux uy uz������Ӱ��Ϊ1
            obj.R(tmp+1,2)=1;
            obj.R(tmp+2,3)=1;
            
            %�γɸն� ���� ���� ����߽�������
            obj.R1=obj.R(obj.activeindex,:);

            %��������
            obj.damp.Make();%ע�⣺�ڼ���ն� �������������
            
            %�����ʼλ������
            obj.intd.MakeU0();

            %�����㷨�����𹤿�
            [v, dv, ddv ]=obj.func();
            
            %��ʼ�����ָ��
            obj.rst.SetPointer('time',1);
            
            


        end
        function GetK(obj)
            %K���ܸնȾ���(�߽���������ǰ) ����Ϊ6*�ڵ����
            
            

            
            
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
        function md=MakeModalDispl(obj,mlc)%����ģ̬����
            %������֤���ߵ�activeindex�Ƿ�һ��
            if norm(obj.activeindex-mlc.activeindex)~=0
                error('nyh:error','Ҫ��modal��������Ч���ɶȺͱ�����һ�£���һ�¿����Ǳ߽�������ͬ���µġ�')
            end
            
            %���modal�����Ƿ��øնȹ������
            if 'k'~=mlc.arg{2}
                error('nyh:error','Ҫ��modal������ʹ�øնȹ�����͡�')%����������Ǳ������������Ǹնȹ�񻯿��Է����ʹ��ģ̬�����ʾӦ���ܡ�
            end
            
            %���ģ̬����
            md=ModalDispl(mlc,obj);
            obj.md=md;
        end

        function CheckBC(obj)
            %Ҫ��λ�Ʊ߽�����ȫ��0
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                if ln(3)~=0
                    error('matlab:myerror','���񹤿����ܳ���λ�Ʋ�Ϊ0�ı߽�����')
                end
            end
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
            deadf1=obj.f_ext(obj.activeindex);%���� ��Ч���ɶ�
            tmp=size(K,1);
            v0=obj.intd.u0(obj.activeindex);
            dv0=zeros(tmp,1);
%             ddv0=zeros(tmp,1);
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
                F(:,it)=-M*R*obj.ei.accn(:,it)+deadf1;%����ǵü��Ϻ�����
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
            u=obj.u_beforesolve;%�ṹ��λ��������  ����0
            u_t=u;
            u_tt=u;
            %% ѭ����ⲿ��
            % len=floor(tend/dt);
            len=length(time);
            v=[ zeros(n,len)];v(:,1)=v0;
            dv=[zeros(n,len)];dv(:,1)=dv0;
            ddv=[zeros(n,len)];ddv0=M^-1*(F(:,1)-C*dv0-K*v0);ddv(:,1)=ddv0;
            %����-1����λ���ٶȼ��ٶ�
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
            
            %�����ʼλ��
            u(obj.activeindex)=v0;
            u_t(obj.activeindex)=dv0;
            u_tt(obj.activeindex)=ddv0;
            %��������
            F_inc=F;
            F_inc(:,2:end)=F(:,2:end)-F(:,1:end-1);%��������=Ŀ�경ֵ-�ϲ�ֵ
            v_inc_last=v(:,1)-vf1;%��һ��λ������
            dv_inc_last=dv(:,1)-dvf1;%��һ���ٶ�����
            ddv_inc_last=ddv(:,1)-ddvf1;%��һ�����ٶ�����
            obj.rst.AddTime(time(1),obj.K*u,u);%д���һ���Ľ��
            wb=waitbar(0,'ʱ�̹�������','Name','FEM3DFRAME');
            for it=2:len%it�ǵ�ǰҪ��� ��Ŀ�경 �Ѿ��㵽it-1 ����һ��

                Fpa_inc=F_inc(:,it)+M*(c0*v_inc_last+c2*dv_inc_last+c3*ddv_inc_last)+C*(c1*v_inc_last+c4*dv_inc_last+c5*ddv_inc_last);%Ŀ�경��Ч��������
                v_inc=Kpali*Fpa_inc;%Ŀ�경λ������
                %�����λ�� �ٶ� ���ٶ�ֵ
                v(:,it)=v(:,it-1)+v_inc;%λ��
                ddv(:,it)=c0*v_inc-c2*dv(:,it-1)-c3*ddv(:,it-1);%���ٶ�
                dv(:,it)=dv(:,it-1)+c6*ddv(:,it-1)+c7*ddv(:,it);
                
                
                waitbar(it/len,wb,['ʱ�̹�������' num2str(it) '/' num2str(len)]);%����wb
                
                %����ǰ���ļ��������浽fem��
                u(obj.activeindex)=v(:,it);%�ṹ��λ��������
                u_t(obj.activeindex)=dv(:,it);
                u_tt(obj.activeindex)=ddv(:,it);
                f=obj.K*u;%�ṹ������
                obj.rst.AddTime(time(it),f,u,u_t,u_tt);%������
                
                %����λ���ٶȼ��ٶȵ� ��һ������
                v_inc_last=v_inc;
                dv_inc_last=dv(:,it)-dv(:,it-1);
                ddv_inc_last=ddv(:,it)-ddv(:,it-1);
            end
            close(wb);

        end
    end
end
