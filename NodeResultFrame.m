classdef NodeResultFrame<handle

    
properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点力(外界对节点的力) solve操作 第一列是节点编号 第二列是6*1 double
        displ VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点位移
        displ_t VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点速度
        displ_tt VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%节点加速度
    end
    
    methods
        function obj = NodeResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.displ=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.displ_t=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.displ_tt=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        function Make(obj,varargin)%从节点力和节点位移向量中载入数据至force和displ
            if obj.force.num~=0||obj.displ.num~=0
                error('matlab:myerror','计算节点结果时，已有节点结果。')
            end
            %预处理
            varargin=Hull(varargin);
            if length(varargin)==2
                vector_f=varargin{1};
                vectro_u=varargin{2};
                t=length(vector_f);%不指定速度和加速度时 这些数据设为0
                vector_u_t=zeros(t,1);
                vector_u_tt=zeros(t,1);
            elseif length(varargin)==4
                vector_f=varargin{1};
                vectro_u=varargin{2};
                vector_u_t=varargin{3};
                vector_u_tt=varargin{4};
            else
                error('未知参数')
            end
            node=obj.rf.rst.lc.f.node;
            for it=1:node.ndnum
                [~,id]=node.nds.Get('index',it);
                xuhao=node.GetXuhaoByID(id);
                obj.displ.Append(id,vectro_u(xuhao:xuhao+5)');
                obj.force.Append(id,vector_f(xuhao:xuhao+5)');%因为知道节点矩阵是升序的 这里直接append不用add
                obj.displ_t.Append(id,vector_u_t(xuhao:xuhao+5)');
                obj.displ_tt.Append(id,vector_u_tt(xuhao:xuhao+5)');
            end
            obj.displ.Check();
            obj.force.Check();
        end


        function r=Get(obj,varargin)%读取结果
            %type force或者displ
            %id 节点编号 'all'
            %dir 方向可以是 1~6 或者 ux uy uz rx ry rz 或者 [1 3] 或者 'all'
            %最后一个参数指定 位移 速度 加速度 '' 'vel' 'acc'
            varargin=Hull(varargin);%去除多余的cell壳 
            type=varargin{1};
            id=varargin{2};
            dir=varargin{3};
            %把dir化作数字
            dir=EleResultFrame.FreedomInterpreter(dir);
            if length(varargin)==3%没有指定最后一个参数
                tar=obj.displ;%默认位移
            elseif length(varargin)==4
                switch varargin{4}
                    case ''
                        tar=obj.displ;
                    case 'vel'
                        tar=obj.displ_t;
                    case 'acc'
                        tar=obj.displ_tt;
                    otherwise
                        error('sd');
                end
            else
                error('未知参数')
            end
            
            %计算
            switch type(1)
                case 'f'
                    if ~isequal(id,'all')
                        tmp=obj.force.Get('id',id);
                        r=tmp(dir);
                    else
                        r=zeros(1,obj.displ.num*length(dir));
                        for it=1:obj.force.num
                            tmp=obj.force.Get('id',it);
                            r((it-1)*length(dir)+1:it*length(dir))=tmp(dir);
                        end
                    end
                    
                case 'd'
                    if ~isequal(id,'all')
                        tmp=tar.Get('id',id);
                        r=tmp(dir);
                    else%提取所有节点
                        r=zeros(1,obj.displ.num*length(dir));
                        for it=1:obj.displ.num
                            tmp=tar.Get('id',it);
                            r((it-1)*length(dir)+1:it*length(dir))=tmp(dir);
                        end
                    end
                    
                    
                    
                otherwise
                    error('matlab:myerror','未知自由度')
            end
            
        end
        function LoadFromState(obj)
            lc=obj.rf.rst.lc;
            
            for it=1:lc.f.node.nds.num
                [~,ndid]=lc.f.node.nds.Get('index',it);%获取节点编号
                xh=lc.f.node.GetXuhaoByID(ndid);%获取节点对应的矩阵序号
                
                %写入位移结果
                tmp=lc.u(xh:xh+5);
                tmp=tmp';
                obj.displ.Add(ndid,tmp);
                %写入力结果
                tmp=lc.f_ele(xh:xh+5);
                tmp=tmp';
                obj.force.Add(ndid,tmp);
                %写入速度
                tmp=lc.du(xh:xh+5);
                tmp=tmp';
                obj.displ_t.Add(ndid,tmp);
                %写入加速度
                tmp=lc.ddu(xh:xh+5);
                tmp=tmp';
                obj.displ_tt.Add(ndid,tmp);
            end
        end

    end
    methods(Access=private)

    end

end
