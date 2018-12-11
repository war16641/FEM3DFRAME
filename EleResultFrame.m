classdef EleResultFrame<handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%单元力 节点对单元的力 局部坐标 第一列是单元id 第二列n*6数值矩阵
        %方向是是节点对单元的力
        deform VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%单元变形 局部坐标 第一列是单元id
        eng VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%单元能量
    end
    
    methods
        function obj = EleResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.deform=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.eng=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Make(obj)
            %u为节点位移 整体坐标
            ele=obj.rf.rst.lc.f.manager_ele;
            eng_summation=[0 0 0];%结构总体能量
            for it=1:ele.num
                e=ele.Get('index',it);
                ndnum=length(e.nds);%该单元节点数量
                switch ndnum
                    case 1%单个节点 如质量
                        u_t=obj.rf.ndrst.Get('displ',e.nds(1),'all','vel');%提取速度
                        [force,deform,eng]=e.GetEleResult({[],u_t,[]});
                        obj.force.Append(e.id,force);
                        obj.deform.Append(e.id,deform);
                        obj.eng.Append(e.id,eng);
                        eng_summation=eng_summation+eng;
                    case 2%两节点 常见
                        %取出节点的位移
                        ui=obj.rf.ndrst.Get('displ',e.nds(1),'all');
                        uj=obj.rf.ndrst.Get('displ',e.nds(2),'all');%特别注意 这里调用了节点结果帧（noderesultframe） 因此要先保证这个对象已经准备好了
                        [force,deform,eng]=e.GetEleResult([ui;uj]);
                        obj.force.Append(e.id,force);
                        obj.deform.Append(e.id,deform);
                        obj.eng.Append(e.id,eng);
                        eng_summation=eng_summation+eng;
                    otherwise
                        error('matlab:myerror','没见过这么多节点的单元。')
                end
            end
            obj.rf.engrst=eng_summation;%将结构的能量写入rf中
            obj.force.Check();
            obj.deform.Check();
        end
        function r=Get(obj,varargin)
            % 'deform' eleid    freedom
            % 'force'  eleid    'i'        freedom
            %                   'j'
            %                   'ij'
            %'eng' eleid
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
                case 'e'%能量
                    eleid=varargin{2};
                    r=obj.eng.Get('id',eleid);
                otherwise
                    error('matlab:myerror','未知类型。')
            end
        end
        function LoadFromState(obj)
            lc=obj.rf.rst.lc;
            for it=1:lc.f.manager_ele.num
                [e,eleid]=lc.f.manager_ele.Get('index',it);%获取单元id
                obj.force.Add(eleid,e.state.force_);
                obj.deform.Add(eleid,e.state.deform_);
                obj.eng.Add(eleid,e.state.eng);
                obj.rf.engrst=obj.rf.engrst+e.state.eng;%更新结构的总能量
%                 if length(e.nds)==1%单节点单元
%                     obj.force.Add(eleid,zeros(6,1));
%                     obj.deform.Add(eleid,zeros(6,1));
%                     obj.eng.Add(eleid,e.state.eng);
%                 elseif length(e.nds)==2%双节点单元
%                     obj.force.Add(eleid,e.state.force_);
%                     obj.deform.Add(eleid,e.state.deform_);
%                     obj.eng.Add(eleid,e.state.eng);
%                 else
%                     error('sd');
%                 end
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

