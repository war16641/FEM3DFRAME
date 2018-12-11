classdef ResultFrame<handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        framename
        rst Result
        ndrst NodeResultFrame
        elerst EleResultFrame
        engrst%结构的能量
    end
    
    methods
        function obj = ResultFrame(framename,rst,varargin)
            obj.framename=framename;
            obj.rst=rst;
            obj.engrst=[0 0 0];
            obj.ndrst=NodeResultFrame(obj);
            obj.elerst=EleResultFrame(obj);
%             obj.ndrst.Make(varargin);
%             obj.elerst.Make();
            
        end
        function r=Get(obj,varargin)

             % 'node'   'force'    nodeid   freedom
             % 'node'     'displ'   nodeid   freedom  ''
             %                                        'vel'
             %                                         'acc'
             %'ele'      'defrom'   eleid    freedom
             %           'force'    eleid    'i'        freedom
             %                               'j'
             %                               'ij'
             %'eng'
             varargin=Hull(varargin);%去除多余的cell壳 
             rst_type=varargin{1};
             switch rst_type(1:2)
                 case 'no'%node
                     r=obj.ndrst.Get(varargin(2:end));%向内层传递
                 case 'el'%ele
                     r=obj.elerst.Get(varargin(2:end));%向内层传递
                 case 'en'%能量
                     r=obj.engrst;
                 otherwise
                     error('sd')
             end
        end 
        function LoadFromState(obj)%从lc中载入
            obj.ndrst.LoadFromState();
            obj.elerst.LoadFromState();
        end
        

    end
end

