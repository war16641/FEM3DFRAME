classdef NodeResultFrame<handle

    
properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点力(外界对节点的力) solve操作 第一列是节点编号 第二列是6*1 double
        displ VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点位移 
    end
    
    methods
        function obj = NodeResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.displ=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        function Make(obj,vector_f,vectro_u)%从节点力和节点位移向量中载入数据至force和displ
            if obj.force.num~=0||obj.displ.num~=0
                error('matlab:myerror','计算节点结果时，已有节点结果。')
            end
            node=obj.rf.rst.lc.f.node;
            for it=1:node.ndnum
                [~,id]=node.nds.Get('index',it);
                xuhao=node.GetXuhaoByID(id);
                obj.displ.Append(id,vectro_u(xuhao:xuhao+5)');
                obj.force.Append(id,vector_f(xuhao:xuhao+5)');%因为知道节点矩阵是升序的 这里直接append不用add
            end
            obj.displ.Check();
            obj.force.Check();
        end


        function r=Get(obj,varargin)%读取结果
            %type force或者displ
            %id 节点编号
            %dir 方向可以是 1~6 或者 ux uy uz rx ry rz 或者 [1 3] 或者 'all' 
            varargin=Hull(varargin);%去除多余的cell壳 
            type=varargin{1};
            id=varargin{2};
            dir=varargin{3};
            %把dir化作数字
            dir=EleResultFrame.FreedomInterpreter(dir);
            
            
            %计算
            switch type(1)
                case 'f'
                    tmp=obj.force.Get('id',id);
                    r=tmp(dir);
                case 'd'
                    tmp=obj.displ.Get('id',id);
                    r=tmp(dir);
                otherwise
                    error('matlab:myerror','未知自由度')
            end
            
        end
%         function disp(obj)
%             disp(['节点结果帧' obj.framename])
%             disp(['属于工况' obj.nc.lc.name])
%             disp('打印力信息>>>>>>>>>>')
%             disp([sprintf('%10s','节点') sprintf('%10s%10s%10s%10s%10s%10s','fx','fy','fz','mx','my','mz')]);
%             for it=1:obj.force.num
%                 [ln,id]=obj.force.Get('index',it);
%                 disp([sprintf('%10d% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e',id,ln(1),ln(2),ln(3),ln(4),ln(5),ln(6))]);
%             end
%             disp('打印位移信息>>>>>>>>>>')
%             disp([sprintf('%10s','节点') sprintf('%10s%10s%10s%10s%10s%10s','ux','uy','uz','rx','ry','rz')]);
%             for it=1:obj.force.num
%                 [ln,id]=obj.displ.Get('index',it);
%                 disp([sprintf('%10d% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e',id,ln(1),ln(2),ln(3),ln(4),ln(5),ln(6))]);
%             end
%         end

    end
    methods(Access=private)

    end

end
