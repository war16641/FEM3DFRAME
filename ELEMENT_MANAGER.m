classdef ELEMENT_MANAGER<HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED
    %��Ԫ��������Ҫʹ���Զ�����ż�1�Ĺ���
    
    properties
        maxnum
    end
    
    methods
        function obj = ELEMENT_MANAGER(classname,identifier)
            obj=obj@HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED(classname,identifier);
            obj.maxnum=0;
        end
        
        function r = get.maxnum(obj)
            %����maxnum��get���� ͬʱ������ڲ�����maxnum
            if obj.num==0%������
                obj.maxnum=0;
                r=0;
                return;
            end
            obj.maxnum=obj.GetIdentifier(obj.objects(end),obj.identifier);
            r=obj.maxnum;
            return;
        end
        function Add(obj,varargin)
            %����ELEMENT3DFRAME�ǳ������ ����ʹ��һ�Ѳ���ʵ�� ֻ����ʵ���õĶ������
            if length(varargin)~=1
                error('MATLAB:myerror','��ʹ��ʵ�����Ķ������')
            end
            Add@HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED(obj,varargin{1});%���ø��෽��
            
                       
        end
    end
end

