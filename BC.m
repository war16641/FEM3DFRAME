classdef BC<handle
    %有限元的边界条件包含力和位移
    
    properties
        displ 
        force %约定：force未描述且displ未描述的节点力为0
        lc LoadCase
    end
    
    methods
        function obj = BC(lc)
            obj.lc=lc;
            obj.displ=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Add(obj,type,ln,flag_overwrite)
            %ln=ndid,dir,value         dir=1~6
            %flag_overwrite指示是否覆盖 默认覆盖1
            if nargin==3
                flag_overwrite=1;
            end
            
            %如果ln是多行拆成单行一行一行输
            if 1~=size(ln,1)
                for it=1:size(ln,1)
                    obj.Add(type,ln(it,:),flag_overwrite);
                end
                return;
            end
            
            %输入检查
            if false==obj.lc.f.node.IsExist(ln(1))
                error('MATLAB:myerror','节点不存在');
            end
            if ~IsIn(ln(2),1:6)
                error('MATLAB:myerror','无此自由度方向');
            end
            
            
            
            switch type
                case 'displ'
                    [success,ow]=obj.displ.Add(ln(1)+ln(2)*0.1,ln,flag_overwrite);
                    if success==0
                        error('matlab:myerror','添加BC错误')
                    end
                    if ow==1
                        disp(['位移荷载覆盖'  ' 节点' num2str(ln(1)) ' 方向'  num2str(ln(2))])
                    end
                case 'force'
                    [success,ow]=obj.force.Add(ln(1)+ln(2)*0.1,ln,flag_overwrite);
                    if success==0
                        error('matlab:myerror','添加BC错误')
                    end
                    if ow==1
                        disp(['力荷载覆盖'  ' 节点' num2str(ln(1)) ' 方向'  num2str(ln(2))])
                    end
                otherwise
                    error('adf')
            end

        end
        function Overwrite(obj,type,ln)%覆盖
            %输入检查
            if false==obj.lc.f.node.IsExist(ln(1))
                error('MATLAB:myerror','节点不存在');
            end
            if ~IsIn(ln(2),1:6)
                error('MATLAB:myerror','无此自由度方向');
            end
            
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
            obj.force.Check();
            obj.displ.Check();
            %检查位移 力是否同时加载在同一自由度上
            if obj.force.num>0&&obj.displ.num>0
                tmp1=[obj.force.object{:,1}];
                tmp2=[obj.displ.object{:,1}];
                tmp=[tmp1 tmp2];
                [~,ia,~]=unique(tmp);
                if length(ia)~=obj.force.num+obj.displ.num
                    error('nyh:error','位移 力是否同时加载在同一自由度上')
                end
            end


%             len1=size(obj.displ,1);
%             len2=size(obj.force,1);
%             tmp=[];
%             if len1~=0
%                 tmp=obj.displ(:,[1 2]);
%             end
%             if len2~=0
%                 tmp=[tmp ;obj.force(:,[1 2])];
%             end
%             [~,ia,~]=unique(tmp,'rows');
%             if len1+len2~=length(ia)
%                 error('matlab:myerror','边界条件出现重复项')
%             end
        end
    end
end

