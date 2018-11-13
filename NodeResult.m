classdef NodeResult<handle
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        lc LoadCase
        force double%节点力(外界对节点的力) FEM.solve操作 第一列是节点编号
        displ double%节点位移 FEM.solve操作 第一列是节点编号 2~7是位移
    end
    
    methods
        function obj = NodeResult(lc)
            obj.lc=lc;
            obj.force=[];
            obj.displ=[];
        end
        function Reset(obj)%初始化force和displ 分配好大小
            if ~isempty(obj.force)||~isempty(obj.displ)
                warning('初始化节点结果时，已有节点结果,请确认是否异常。')
            end
            obj.force=zeros(obj.lc.f.node.ndnum,7);
            obj.displ=zeros(obj.lc.f.node.ndnum,7);
        end
        function SetLine(obj,type,row,id,d)%填充信息
            %type f 力     d位移
            %row行号
            %id节点编号
            %d 1*6的节点位移
            
            switch type(1)%只拿第一个字符来判断  %按道理应该要检查要写入的地方是否有值 这里为了速度就不了
                case 'f'
                    obj.force(row,1)=id;
                    obj.force(row,2:7)=d;
                case 'd'
                    obj.displ(row,1)=id;
                    obj.displ(row,2:7)=d;
                otherwise
                    error('sd');
            end
            
        end
        function r=Get(obj,type,id,dir)%读取结果
            %type force或者displ
            %id 节点编号
            %dir 方向可以是 1~6 或者 ux uy uz rx ry rz 或者 [1 3] 或者 'all' 
            
            %把dir化作数字
            if isa(dir,'char')
                switch dir
                    case 'ux'
                        dir=1;
                    case 'uy'
                        dir=2;
                    case 'uz'
                        dir=3;
                    case 'rx'
                        dir=4;
                    case 'ry'
                        dir=5;
                    case 'rz'
                        dir=6;
                    case 'all'
                        dir=1:6;
                    otherwise
                        error('matlab:myerror','未知自由度')
                end
            elseif isa(dir,'double')
            else
                error('matlab:myerror','未知自由度')
            end
            
            %调用内部函数计算
            switch type(1)
                case 'f'
                    r=obj.GetForce(id,dir);
                case 'd'
                    r=obj.GetDispl(id,dir);
                otherwise
                    error('matlab:myerror','未知自由度')
            end
            
        end

    end
    methods(Access=private)
        function r=GetForce(obj,id,dir)%返回力
            for it=1:size(obj.force,1)%算法有待改进
                if id==obj.force(it,1)
                    r=obj.force(it,dir+1);
                    return;
                end
            end
            error('matlab:myerror','未找到')
        end
        function r=GetDispl(obj,id,dir)%返回位移
            for it=1:size(obj.displ,1)%算法有待改进
                if id==obj.displ(it,1)
                    r=obj.displ(it,dir+1);
                    return;
                end
            end
            error('matlab:myerror','未找到')
        end
    end
end

