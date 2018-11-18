classdef LoadCase_Modal<LoadCase
    %���񹤿�
    
    properties
        
    end
    
    methods
        function obj = LoadCase_Modal(f,name)
            obj=obj@LoadCase(f,name);
            obj.rst=Result_Modal(obj);%����ԭ�н������ ��Ϊʹ��ģ̬ר�ý������
        end
        function Solve(obj)
            obj.GetK();
            obj.GetM();
            
            %���߽������Ƿ��ظ�
            obj.bc.Check();
            
            %K1Ϊ����߽��������ܸնȾ���
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %�ȴ���λ�Ʊ߽�
            df=zeros(dof,1);
            
            in=[];%�洢����������ɶ� λ�����Ƶ����ɶ�
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                index=obj.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%�õ����
                df=df-obj.K(:,index)*ln(3);
                u(index)=ln(3);%����λ��
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
            K1=obj.K(activeindex,activeindex);%ȥ��һ�������ɶ�
            M1=obj.M(activeindex,activeindex);
            
            %�����㷨�������ֵ
            [w,mode]=LoadCase_Modal.GetInfoForFreeVibration_eig(K1,M1);
            
            %���������������ɶ��ϵ�����λ�� ������
            tic
            for it=1:length(w)%��һ��ѭ���е㻨ʱ��
                w1=w(it);
                mode1=mode(:,it);
                u1=u;
                u1(activeindex)=mode1;
                f1=obj.K*u1;
                obj.rst.Add(it,w1,f1,u1);
            end
            toc

            

            
            
            %��ʼ�����ָ��
            obj.rst.SetPointer();

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
    methods(Static)
        function [w,mode]=GetInfoForFreeVibration_eig(k,m,nummode)
            %���ù�������ֵ KV=BVD���������Ϣ
            %nummode ��ѡ ǰ����Ƶ�ʺ�����
            if nargin==2
                nummode=size(k,1);
            end
            [mode,D]=eigs(k,m,nummode,'sm');%���Ƶ�ʰ���С��������
            w=sqrt(diag(D));
            %�������
            for it=1:nummode
                mn=mode(:,it)'*m*mode(:,it);
                mode(:,it)=mode(:,it)/sqrt(mn);
            end
        end
    end
end

