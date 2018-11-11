classdef BC<handle
    %有限元的边界条件包含力和位移
    
    properties
        displ double
        force double%约定：force未描述且displ未描述的节点力为0
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
                    obj.displ=[obj.displ;ln];%未检查重复
                case 'force'
                    obj.force=[obj.force;ln];%未检查重复
                otherwise
                    error('adf')
            end

        end
        function Overwrite(obj,type,ln)%覆盖
            switch type
                case 'displ'
                    for it=1:size(obj.displ,1)
                        if ln(1)==obj.displ(it,1) && ln(2)==obj.displ(it,2)%节点号和方向一致
                            obj.displ(it,:)=ln; 
                            return;
                        end
                    end
                    error('matlab:myerror','未找到')
                case 'force'
                    for it=1:size(obj.force,1)
                        if ln(1)==obj.force(it,1) && ln(2)==obj.force(it,2)%节点号和方向一致
                            obj.force(it,:)=ln; 
                            return;
                        end
                    end
                    error('matlab:myerror','未找到')
                otherwise
                    error('adf')
            end
        end
        function Check(obj)%检查边界数据是否正常
            %要求force和displ不能重复
            [~,ia,~]=unique(obj.displ(:,[1 2]),'rows');
            if length(ia)~=size(obj.displ,1)
                error('matlab:myerror','位移边界条件出现重复项')
            end
            [~,ia,~]=unique(obj.force(:,[1 2]),'rows');
            if length(ia)~=size(obj.force,1)
                error('matlab:myerror','力边界条件出现重复项')
            end
            
            %要求力和位移边界条件不能重复指定同一个自由度
            len1=size(obj.displ,1);
            len2=size(obj.force,1);
            [~,ia,~]=unique([obj.displ(:,[1 2]);obj.force(:,[1 2])],'rows');
            if len1+len2~=length(ia)
                error('matlab:myerror','力 位移边界条件干涉')
            end
        end
    end
end

