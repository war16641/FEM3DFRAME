classdef Result<handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        lc LoadCase
        pointer ResultFrame%当前的指针 get的返回值来源于pointer指向的结果帧
        timeframe
        nontimeframe
    end
    
    methods
        function obj = Result(lc)
            obj.lc=lc;
            obj.timeframe=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nontimeframe=VCM.VALUE_CLASS_MANAGER();
        end
        function SetPointer(obj,frametype,framename)
            %frametype 可取'time' 'nontime'
            if nargin==1%没指定frametype,framename
                obj.pointer=obj.nontimeframe.Get('index',1);%设置默认指针 为 非时间帧的第一个
                return;
            end
            switch frametype(1)
                case 't'%时间
                    obj.pointer=obj.timeframe.Get('id',framename);
                case 'n'%非时间
                    obj.pointer=obj.nontimeframe.Get('id',framename);
                otherwise
                    error('sd')
            end
        end
        function AddNontime(obj,framename,vector_f,vectro_u)
            tmp=ResultFrame(framename,obj,vector_f,vectro_u);
            obj.nontimeframe.Add(framename,tmp);
        end
        function r = Get(obj,varargin)
            r=obj.pointer.Get(varargin);
            %rst_type node 或者 ele
            %rst_type='node'    type='force' 'displ'
             %                             id 节点id
             %                             dir 方向
%             r=obj.pointer.Get(rst_type,type,id,dir);

        end
    end
end

