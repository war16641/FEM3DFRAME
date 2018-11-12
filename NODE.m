classdef NODE<handle
    %����ฺ�����FEM2D�Ľڵ�
    
    properties
        f FEM3DFRAME%��������һ������Ԫ
        nds double%4�� ��һ��Ϊid
        nds_force double%�ڵ���(���Խڵ����) FEM.solve���� ��һ���ǽڵ���
        nds_displ double%�ڵ�λ�� FEM.solve���� ��һ���ǽڵ��� 2~7��λ��
        nds_mapping double%�ڵ�����նȾ����ӳ�� ��һ���ǽڵ��� �ڶ����ǽڵ�x���ɶȶ�Ӧ����� FEM2D.solve����
        maxnum%ʹ�õ������
        ndnum%�ڵ����
    end
    
    methods
        function obj = NODE(f)
            obj.f=f;
            obj.maxnum=0;
            obj.ndnum=0;
            
            
        end
        function AddByCartesian(obj,id,x,y,z)
            %ndsʼ�հ��յ�һ�е���
            if id==0%����ż�1
                obj.nds=[obj.nds;obj.maxnum+1 x y z];
                obj.maxnum=obj.maxnum+1;
                obj.ndnum=obj.ndnum+1;
                return;
            else%ָ��id
                if id>obj.maxnum%ָ���ı�Ŵ��������
                    obj.nds=[obj.nds;id x y z];
                    obj.maxnum=id;
                    obj.ndnum=obj.ndnum+1;
                    return;
                end
                %ָ���ı�Ų����������
                %��Ҫ���뵽���� ������㷨�����ԸĽ�
                for it=1:obj.ndnum
                    if id<obj.nds(it,1)
                        obj.nds=[obj.nds(1:it-1,:);id x y z;obj.nds(it:end,:)];
                        obj.ndnum=obj.ndnum+1;
                        return;
                    elseif obj.nds(it,1)==id
                        warning(['���ǽڵ�' num2str(id)]);
                        obj.nds(it,:)=[id x y z];
                        return;
                    end
                end
                error('��ӽڵ����')
            end
        end
        function flag=IsExist(obj,id)
            %�ж�ĳ���ڵ��Ƿ����
            %% ���idֱ�Ӵ����˽ڵ�������������
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds(it,1)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            end
            
            
            %% ���ȷ���id�������� ������ϵĻ�
            if obj.nds(id,1)==id
                flag=true;
                return;
            end
            %% ������
            if obj.nds(id,1)>id%��������Ŀ��� ��ǰ����
                for it=id-1:-1:1
                    if obj.nds(it)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            elseif  obj.nds(id,1)>id%��������Ŀ��С �������
                for it=id+1:obj.ndnum
                    if obj.nds(it,1)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            end
            %% 1
            flag=false;
            return;
        end
        function xyz = GetCartesianByID(obj,id)
            %% ���idֱ�Ӵ����˽ڵ�������������
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds(it,1)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            end
            
            
            %% ���ȷ���id�������� ������ϵĻ�
            if obj.nds(id,1)==id
                xyz=obj.nds(id,[2 3 4]);
                return;
            end
            %% ������
            if obj.nds(id,1)>id%��������Ŀ��� ��ǰ����
                for it=id-1:-1:1
                    if obj.nds(it)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            elseif  obj.nds(id,1)>id%��������Ŀ��С �������
                for it=id+1:obj.ndnum
                    if obj.nds(it,1)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            end
            %% 1
            error('δ�ҵ��ڵ�');
        end
        function xuhao=GetXuhaoByID(obj,id)%ͨ��id��øնȾ����е���� �ýڵ�ux���ڵ����
            %% ���idֱ�Ӵ����˽ڵ�������������
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds_mapping(it,2);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            end
            
            
            %% ���ȷ���id�������� ������ϵĻ�
            if obj.nds_mapping(id,1)==id
                xuhao=obj.nds_mapping(id,2);
                return;
            end
            %% ������
            if obj.nds_mapping(id,1)>id%��������Ŀ��� ��ǰ����
                for it=id-1:-1:1
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds_mapping(it,2);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            elseif  obj.nds_mapping(id,1)>id%��������Ŀ��С �������
                for it=id+1:obj.ndnum
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds(it,2);
                        return;
                    end
                end
                error('δ�ҵ��ڵ�');
            end
            %% 1
            error('δ�ҵ��ڵ�');
        end
        function LoadFromMatrix(obj,mt)%�Ӿ��������� ��һ����id ������xy %��Ҫ����
            for it=1:size(mt,1)
                AddByCartesian(obj,mt(it,1),mt(it,2),mt(it,3));
            end
        end
        function r=DirBy2Node(obj,i,j)
            %���ش�i��j�ĵ�λ����
            xyz1=obj.GetCartesianByID(i);
            xyz2=obj.GetCartesianByID(j);
            r=xyz2-xyz1;
            r=r/norm(r);%��λ��
        end
        function d=Distance(obj,i,j)%���������ڵ�ľ���
            xyz1=obj.GetCartesianByID(i);
            xyz2=obj.GetCartesianByID(j);
            r=xyz2-xyz1;
            d=sqrt(sum(r.^2));
        end
    end
    methods(Static)
        
    end
end

