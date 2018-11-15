classdef LoadCase_Static<LoadCase
    %UNTITLED3 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        
    end
    
    methods
        function obj = LoadCase_Static(f,name)
            obj=obj@LoadCase(f,name);
        end
        function Solve(obj)
            obj.GetK();
            
            %���߽������Ƿ��ظ�
            obj.bc.Check();
            
            %K1Ϊ����߽��������ܸնȾ���
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %�ȴ���λ�Ʊ߽�
            df=zeros(dof,1);
            
            in=[];%�洢����������ɶ� λ�����Ƶ����ɶ�
            for it=1:size(obj.bc.displ,1)
%                 index=2*(obj.bc.displ(it,1)-1)+obj.bc.displ(it,2);
                index=obj.f.node.GetXuhaoByID(obj.bc.displ(it,1))+obj.bc.displ(it,2)-1;%�õ����
                df=df-obj.K(:,index)*obj.bc.displ(it,3);
                u(index)=obj.bc.displ(it,3);%����λ��
                in=[in index];
            end
            activeindex=1:dof;
            
            %����δ����Ԫ�������ɶ�
            hit=zeros(dof,1);%���ɶȱ����д���
            
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.objects(it);
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
            for it=1:size(obj.bc.force,1)
                index=obj.f.node.GetXuhaoByID(obj.bc.force(it,1))+obj.bc.force(it,2)-1;
                ft(index)=ft(index)+obj.bc.force(it,3);
                index_force=[index_force index];
            end
            f1=ft+df;
            
            %������Ƿ������δ����Ԫ��������ɶ���
            [~,ia,~]=unique([index_force deadindex]);
            if length(index_force)+length(deadindex)>length(ia)
                error('matlab:myerror','��������δ����Ԫ��������ɶ���')
            end
            
            %���
            K1=obj.K(activeindex,activeindex);%�򻯷����� ȥ��һ�������ɶ�
            u1=K1\f1(activeindex);
            
            %���������������ɶ��ϵ�����λ��
            
            u(activeindex)=u1;
            f=obj.K*u;
            %�ѽ�����浽noderst
            obj.noderst.Reset();
            
            for it=1:obj.f.node.ndnum
                [~,id]=obj.f.node.nds.Get('index',it);
                xuhao=obj.f.node.GetXuhaoByID(id);
                obj.noderst.SetLine('displ',it,id,u(xuhao:xuhao+5)');
            end
            for it=1:obj.f.node.ndnum
                [~,id]=obj.f.node.nds.Get('index',it);
                xuhao=obj.f.node.GetXuhaoByID(id);
                obj.noderst.SetLine('force',it,id,f(xuhao:xuhao+5)');
            end
        end
        function GetK(obj)
            %K���ܸնȾ���(�߽���������ǰ) ����Ϊ6*�ڵ����
            
            %�γɽڵ���նȾ����ӳ��
            obj.f.node.SetupMapping();

            
            
            K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'��װ�նȾ���','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['��װ�նȾ���' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.objects(it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
    end
end

