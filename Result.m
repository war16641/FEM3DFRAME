classdef Result<handle
    %UNTITLED �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        lc LoadCase
        pointer ResultFrame%��ǰ��ָ�� get�ķ���ֵ��Դ��pointerָ��Ľ��֡
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
            %frametype ��ȡ'time' 'nontime'
            if nargin==1%ûָ��frametype,framename
                obj.pointer=obj.nontimeframe.Get('index',1);%����Ĭ��ָ�� Ϊ ��ʱ��֡�ĵ�һ��
                return;
            end
            switch frametype(1)
                case 't'%ʱ��
                    obj.pointer=obj.timeframe.Get('id',framename);
                case 'n'%��ʱ��
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
            %rst_type node ���� ele
            %rst_type='node'    type='force' 'displ'
             %                             id �ڵ�id
             %                             dir ����
%             r=obj.pointer.Get(rst_type,type,id,dir);

        end
    end
end

