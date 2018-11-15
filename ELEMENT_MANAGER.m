classdef ELEMENT_MANAGER<VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED
    %单元管理器需要使用自动最大编号加1的功能
    
    properties
        maxnum
    end
    
    methods
        function obj = ELEMENT_MANAGER()
            obj=obj@VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.maxnum=0;
        end
        
        function r = get.maxnum(obj)
            %定义maxnum的get方法 同时在这个内部更新maxnum
            if obj.num==0%无数据
                obj.maxnum=0;
                r=0;
                return;
            end
            obj.maxnum=obj.object{end,1};
            r=obj.maxnum;
            return;
        end
        function Add(obj,varargin)
            %由于ELEMENT3DFRAME是抽象基类 不能使用一堆参数实例 只能是实例好的对象加入
            
            if length(varargin)~=1
                error('MATLAB:myerror','请使用实例化的对象添加')
            end
            newobj=varargin{1};
            success=obj.Add@VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED(newobj.id,newobj);
            if 0==success
                error('matlab:myerror','此单元id已存在')
            end
                       
        end
    end
end

