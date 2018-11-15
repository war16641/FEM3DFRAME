classdef NODE<handle
    %����ฺ�����FEM2D�Ľڵ�
    
    properties
        f FEM3DFRAME%��������һ������Ԫ
        nds double%4�� ��һ��Ϊid

        nds_mapping %�ڵ�����նȾ����ӳ�� ��һ���ǽڵ��� �ڶ����ǽڵ�x���ɶȶ�Ӧ����� FEM2D.solve����
        nds_mapping_r %nds_mapping�ķ����� ��һ������� �ڶ����ǽڵ�
        maxnum%ʹ�õ������
        ndnum%�ڵ����
    end
    
    methods
        function obj = NODE(f)
            obj.f=f;
            obj.maxnum=0;
            obj.ndnum=0;
            obj.nds_mapping=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nds_mapping_r=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            
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
          xuhao=obj.nds_mapping.Get('id',id);
          if isempty(xuhao)
              error('�޴˽ڵ�');
          end
        end
        function [id,index,label]=GetIdByXuhao(obj,xh)%ͨ���նȾ����е���Ż�ýڵ�id 
            %�Ƚ�xh�ŵ�ux�� ������index��label
            yushu=mod(xh,6);
            switch yushu
                case 1
                    label='ux';
                    index=1;
                case 2
                    label='uy';index=2;
                 case 3
                    label='uz';index=3;
                case 4
                    label='rx';index=4;
                case 5
                    label='ry';index=5;
                 case 0
                    label='rz';index=6;
            end
            
            %����id
            xh=xh-yushu+1;%������ƶ������ڵ��ux���ɶ���
            id=obj.nds_mapping_r.Get('id',xh);
            if isempty(id)
                error('δ�ҵ�')
            end
        end
        function SetupMapping(obj)%�����ڵ����ɶȶԸնȾ���(K)��ӳ�� 
            %�������ִ��Ӧ��solve�е���
            %�˺���ִ�к� ��Ӧ�ٶԽڵ���в�����
            lastx=-5;
            for it=1:obj.ndnum
                lastx=lastx+6;
                obj.nds_mapping.Append(obj.nds(it,1),lastx);
                obj.nds_mapping_r.Append(lastx,obj.nds(it,1));
            end
            obj.nds_mapping.Check();
            obj.nds_mapping_r.Check();
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

