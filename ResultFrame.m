classdef ResultFrame<handle
    %UNTITLED2 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        framename
        rst Result
        ndrst NodeResultFrame
        elerst
    end
    
    methods
        function obj = ResultFrame(framename,rst,arg1,arg2)
            obj.framename=framename;
            obj.rst=rst;
            obj.ndrst=NodeResultFrame(obj);
            obj.ndrst.Make(arg1,arg2);
        end
        function r=Get(obj,rst_type,type,id,dir)
            %rst_type node ���� ele
            %rst_type='node'    type='force' 'displ'
             %                             id �ڵ�id
             %                             dir ����
             switch rst_type(1)
                 case 'n'%node
                     r=obj.ndrst.Get(type,id,dir);
                 case 'e'%ele
                 otherwise
                     error('sd')
             end
        end 
        

    end
end

