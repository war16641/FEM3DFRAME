classdef EleResultFrame<handle
    %UNTITLED �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%��Ԫ�� �ڵ�Ե�Ԫ���� �ֲ����� ��һ���ǵ�Ԫid �ڶ���n*6��ֵ����
        deform VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%��Ԫ���� �ֲ����� ��һ���ǵ�Ԫid
    end
    
    methods
        function obj = EleResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.deform=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Make(obj)
            %uΪ�ڵ�λ�� ��������
            ele=obj.rf.rst.lc.f.manager_ele;
            for it=1:ele.num
                e=ele.Get('index',it);
                ndnum=length(e.nds);%�õ�Ԫ�ڵ�����
                switch ndnum
                    case 1%�����ڵ� ������
                    case 2%���ڵ� ����
                        %ȡ���ڵ��λ��
                        ui=obj.rf.ndrst.Get('displ',e.nds(1),'all');
                        uj=obj.rf.ndrst.Get('displ',e.nds(2),'all');%�ر�ע�� ��������˽ڵ���֡��noderesultframe�� ���Ҫ�ȱ�֤��������Ѿ�׼������
                        [force,deform]=e.GetEleResult([ui;uj]);
                        obj.force.Append(e.id,force);
                        obj.deform.Append(e.id,deform);
                    otherwise
                        error('matlab:myerror','û������ô��ڵ�ĵ�Ԫ��')
                end
            end
            obj.force.Check();
            obj.deform.Check();
        end
        function r=Get(obj,varargin)
            % 'deform' eleid    freedom
            % 'force'  eleid    'i'        freedom
            %                   'j'
            %                   'ij'
            varargin=Hull(varargin);%ȥ�������cell�� 
            switch varargin{1}(1)
                case 'd'%����
                    eleid=varargin{2};
                    freedom=obj.FreedomInterpreter(varargin{3});
                    tmp=obj.deform.Get('id',eleid);
                    r=tmp(freedom);
                case 'f'%��Ԫ��
                    eleid=varargin{2};
                    freedom=obj.FreedomInterpreter(varargin{4});
                    eleend=varargin{3};
                    if strcmp(eleend,'i')
                        hang=1;
                    elseif strcmp(eleend,'j')
                        hang=2;
                    elseif strcmp(eleend,'ij')
                        hang=[1 2];
                    else
                        error('matlab:myerror','δ֪���͡�')
                    end
                    tmp=obj.force.Get('id',eleid);
                    r=tmp(hang,freedom);                    
                otherwise
                    error('matlab:myerror','δ֪���͡�')
            end
        end
    end
    methods(Static)
        function freedom=FreedomInterpreter(x)%���ɶȽ�����
            if isa(x,'char')
                switch x
                    case 'ux'
                        freedom=1;
                    case 'uy'
                        freedom=2;
                    case 'uz'
                        freedom=3;
                    case 'rx'
                        freedom=4;
                    case 'ry'
                        freedom=5;
                    case 'rz'
                        freedom=6;
                    case 'all'
                        freedom=1:6;
                    otherwise
                        error('matlab:myerror','δ֪���ɶ�')
                end
            elseif isa(x,'double')
                %���ﻹ����д ��֤ ������1~6֮��
                freedom=x;
            else
                error('matlab:myerror','δ֪���ɶ�')
            end
        end
    end
end
