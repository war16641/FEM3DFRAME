classdef EleResultFrame<handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%单元力 节点对单元的力 局部坐标 第一列是单元id 第二列n*6数值矩阵
        deform VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%单元变形 局部坐标 第一列是单元id
    end
    
    methods
        function obj = EleResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.deform=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Make(obj)
            %u为节点位移 整体坐标
            ele=obj.rf.rst.lc.f.manager_ele;
            for it=1:ele.num
                e=ele.Get('index',it);
                ndnum=length(e.nds);%该单元节点数量
                switch ndnum
                    case 1%单个节点 如质量
                    case 2%两节点 常见
                        %取出节点的位移
                        ui=obj.rf.ndrst.Get('displ',e.nds(1),'all');
                        uj=obj.rf.ndrst.Get('displ',e.nds(2),'all');%特别注意 这里调用了节点结果帧（noderesultframe） 因此要先保证这个对象已经准备好了
                        [force,deform]=e.GetEleResult([ui;uj]);
                        obj.force.Append(e.id,force);
                        obj.deform.Append(e.id,deform);
                    otherwise
                        error('matlab:myerror','没见过这么多节点的单元。')
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
            varargin=Hull(varargin);%去除多余的cell壳 
            switch varargin{1}(1)
                case 'd'%变形
                    eleid=varargin{2};
                    freedom=obj.FreedomInterpreter(varargin{3});
                    tmp=obj.deform.Get('id',eleid);
                    r=tmp(freedom);
                case 'f'%单元力
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
                        error('matlab:myerror','未知类型。')
                    end
                    tmp=obj.force.Get('id',eleid);
                    r=tmp(hang,freedom);                    
                otherwise
                    error('matlab:myerror','未知类型。')
            end
        end
    end
    methods(Static)
        function freedom=FreedomInterpreter(x)%自由度解释器
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
                        error('matlab:myerror','未知自由度')
                end
            elseif isa(x,'double')
                %这里还可以写 保证 数字在1~6之内
                freedom=x;
            else
                error('matlab:myerror','未知自由度')
            end
        end
    end
end

