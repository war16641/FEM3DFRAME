classdef BC<handle
    %����Ԫ�ı߽�������������λ��
    
    properties
        displ double
        force double%Լ����forceδ������displδ�����Ľڵ���Ϊ0
        f FEM3DFRAME
    end
    
    methods
        function obj = BC(f)
            obj.f=f;
            obj.displ=[];
            obj.force=[];
        end
        
        function Add(obj,type,ln)%ln=ndid,dir,value         dir=1~6
            switch type
                case 'displ'
                    obj.displ=[obj.displ;ln];%δ����ظ�
                case 'force'
                    obj.force=[obj.force;ln];%δ����ظ�
                otherwise
                    error('adf')
            end

        end
        function Overwrite(obj,type,ln)%����
            switch type
                case 'displ'
                    for it=1:size(obj.displ,1)
                        if ln(1)==obj.displ(it,1) && ln(2)==obj.displ(it,2)%�ڵ�źͷ���һ��
                            obj.displ(it,:)=ln; 
                            return;
                        end
                    end
                    error('matlab:myerror','δ�ҵ�')
                case 'force'
                    for it=1:size(obj.force,1)
                        if ln(1)==obj.force(it,1) && ln(2)==obj.force(it,2)%�ڵ�źͷ���һ��
                            obj.force(it,:)=ln; 
                            return;
                        end
                    end
                    error('matlab:myerror','δ�ҵ�')
                otherwise
                    error('adf')
            end
        end
        function Check(obj)%���߽������Ƿ�����
            %Ҫ��force��displ�����ظ�
            [~,ia,~]=unique(obj.displ(:,[1 2]),'rows');
            if length(ia)~=size(obj.displ,1)
                error('matlab:myerror','λ�Ʊ߽����������ظ���')
            end
            [~,ia,~]=unique(obj.force(:,[1 2]),'rows');
            if length(ia)~=size(obj.force,1)
                error('matlab:myerror','���߽����������ظ���')
            end
            
            %Ҫ������λ�Ʊ߽����������ظ�ָ��ͬһ�����ɶ�
            len1=size(obj.displ,1);
            len2=size(obj.force,1);
            [~,ia,~]=unique([obj.displ(:,[1 2]);obj.force(:,[1 2])],'rows');
            if len1+len2~=length(ia)
                error('matlab:myerror','�� λ�Ʊ߽���������')
            end
        end
    end
end

