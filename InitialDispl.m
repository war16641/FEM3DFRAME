classdef InitialDispl<handle
    %管理初始位移
    properties
        lc LoadCase_Earthquake
        displ
        u0 double %初始位移向量
    end
    
    methods
        function obj = InitialDispl(lc)
            obj.lc=lc;
            obj.displ=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Add(obj,ln,flag_overwrite)%添加初始位移
            %注意添加的初始位移不能和bc中的位移边界重复 此函数对此进行检查
            if nargin==2
                flag_overwrite=1;%默认覆盖
            end
            
            %如果ln是多行拆成单行一行一行输
            if 1~=size(ln,1)
                for it=1:size(ln,1)
                    obj.Add(ln(it,:),flag_overwrite);
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
            
            %检查是否与bc中位移边界重复
            if 0~=obj.lc.bc.displ.FindId(ln(1)+ln(2)*0.1)
                error('nyh:error','初始位移与bc中位移边界重复')
            end
            
            [success,ow]=obj.displ.Add(ln(1)+ln(2)*0.1,ln,flag_overwrite);
            if success==0
                error('matlab:myerror','添加BC错误')
            end
            if ow==1
                disp(['初始位移覆盖'  ' 节点' num2str(ln(1)) ' 方向'  num2str(ln(2))])
            end
        end
        
        
        
        function u0=MakeU0(obj)%生成初始位移向量（引入边界条件前）
            obj.u0=zeros(obj.lc.dof,1);
            for it=1:obj.displ.num
                ln=obj.displ.Get('index',it);
                index=obj.lc.f.node.GetXuhaoByID(ln(1))+ln(2)-1;%得到序号
                obj.u0(index)=ln(3);
            end
            u0=obj.u0;
        end
    end
end

