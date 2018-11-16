classdef ResultFrame<handle
    %UNTITLED2 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        framename
        rst Result
        ndrst NodeResultFrame
        elerst EleResultFrame
    end
    
    methods
        function obj = ResultFrame(framename,rst,arg1,arg2)
            obj.framename=framename;
            obj.rst=rst;
            obj.ndrst=NodeResultFrame(obj);
            obj.elerst=EleResultFrame(obj);
            obj.ndrst.Make(arg1,arg2);
            obj.elerst.Make();
        end
        function r=Get(obj,varargin)

             % 'node'   'force'    nodeid   freedom
             %           'displ'
             
             %'ele'      'defrom'   eleid    freedom
             %           'force'    eleid    'i'        freedom
             %                               'j'
             %                               'ij'
             varargin=Hull(varargin);%ȥ�������cell�� 
             rst_type=varargin{1};
             switch rst_type(1)
                 case 'n'%node
                     r=obj.ndrst.Get(varargin(2:end));%���ڲ㴫��
                 case 'e'%ele
                     r=obj.elerst.Get(varargin(2:end));%���ڲ㴫��
                 otherwise
                     error('sd')
             end
        end 
        

    end
end

