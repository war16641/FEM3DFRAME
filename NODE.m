classdef NODE<handle
    %这个类负责管理FEM2D的节点
    
    properties
        f FEM3DFRAME%隶属于哪一个有限元
        nds double%4列 第一列为id
        nds_force double%节点力(外界对节点的力) FEM.solve操作 第一列是节点编号
        nds_displ double%节点位移 FEM.solve操作 第一列是节点编号 2~7是位移
        nds_mapping double%节点编号与刚度矩阵的映射 第一列是节点编号 第二列是节点x自由度对应的序号 FEM2D.solve操作
        maxnum%使用的最大编号
        ndnum%节点个数
    end
    
    methods
        function obj = NODE(f)
            obj.f=f;
            obj.maxnum=0;
            obj.ndnum=0;
            
            
        end
        function AddByCartesian(obj,id,x,y,z)
            %nds始终按照第一列递增
            if id==0%最大编号加1
                obj.nds=[obj.nds;obj.maxnum+1 x y z];
                obj.maxnum=obj.maxnum+1;
                obj.ndnum=obj.ndnum+1;
                return;
            else%指定id
                if id>obj.maxnum%指定的编号大于最大编号
                    obj.nds=[obj.nds;id x y z];
                    obj.maxnum=id;
                    obj.ndnum=obj.ndnum+1;
                    return;
                end
                %指定的编号不大于最大编号
                %需要插入到表中 插入的算法还可以改进
                for it=1:obj.ndnum
                    if id<obj.nds(it,1)
                        obj.nds=[obj.nds(1:it-1,:);id x y z;obj.nds(it:end,:)];
                        obj.ndnum=obj.ndnum+1;
                        return;
                    elseif obj.nds(it,1)==id
                        warning(['覆盖节点' num2str(id)]);
                        obj.nds(it,:)=[id x y z];
                        return;
                    end
                end
                error('添加节点错误')
            end
        end
        function flag=IsExist(obj,id)
            %判断某个节点是否存在
            %% 如果id直接大于了节点数量倒着搜索
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds(it,1)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            end
            
            
            %% 首先返回id处的坐标 如果符合的话
            if obj.nds(id,1)==id
                flag=true;
                return;
            end
            %% 不符合
            if obj.nds(id,1)>id%如果这里比目标大 向前搜索
                for it=id-1:-1:1
                    if obj.nds(it)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            elseif  obj.nds(id,1)>id%如果这里比目标小 向后搜索
                for it=id+1:obj.ndnum
                    if obj.nds(it,1)==id
                        flag=true;
                        return;
                    end
                end
                flag=false;
                return;
            end
            %% 1
            flag=false;
            return;
        end
        function xyz = GetCartesianByID(obj,id)
            %% 如果id直接大于了节点数量倒着搜索
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds(it,1)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('未找到节点');
            end
            
            
            %% 首先返回id处的坐标 如果符合的话
            if obj.nds(id,1)==id
                xyz=obj.nds(id,[2 3 4]);
                return;
            end
            %% 不符合
            if obj.nds(id,1)>id%如果这里比目标大 向前搜索
                for it=id-1:-1:1
                    if obj.nds(it)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('未找到节点');
            elseif  obj.nds(id,1)>id%如果这里比目标小 向后搜索
                for it=id+1:obj.ndnum
                    if obj.nds(it,1)==id
                        xyz=obj.nds(it,[2 3 4]);
                        return;
                    end
                end
                error('未找到节点');
            end
            %% 1
            error('未找到节点');
        end
        function xuhao=GetXuhaoByID(obj,id)%通过id获得刚度矩阵中的序号 该节点ux对于的序号
            %% 如果id直接大于了节点数量倒着搜索
            if id>obj.ndnum
                for it=obj.ndnum:-1:1
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds_mapping(it,2);
                        return;
                    end
                end
                error('未找到节点');
            end
            
            
            %% 首先返回id处的坐标 如果符合的话
            if obj.nds_mapping(id,1)==id
                xuhao=obj.nds_mapping(id,2);
                return;
            end
            %% 不符合
            if obj.nds_mapping(id,1)>id%如果这里比目标大 向前搜索
                for it=id-1:-1:1
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds_mapping(it,2);
                        return;
                    end
                end
                error('未找到节点');
            elseif  obj.nds_mapping(id,1)>id%如果这里比目标小 向后搜索
                for it=id+1:obj.ndnum
                    if obj.nds_mapping(it,1)==id
                        xuhao=obj.nds(it,2);
                        return;
                    end
                end
                error('未找到节点');
            end
            %% 1
            error('未找到节点');
        end
        function LoadFromMatrix(obj,mt)%从矩阵中载入 第一列是id 二三是xy %需要更改
            for it=1:size(mt,1)
                AddByCartesian(obj,mt(it,1),mt(it,2),mt(it,3));
            end
        end
        function r=DirBy2Node(obj,i,j)
            %返回从i到j的单位向量
            xyz1=obj.GetCartesianByID(i);
            xyz2=obj.GetCartesianByID(j);
            r=xyz2-xyz1;
            r=r/norm(r);%单位化
        end
        function d=Distance(obj,i,j)%返回两个节点的距离
            xyz1=obj.GetCartesianByID(i);
            xyz2=obj.GetCartesianByID(j);
            r=xyz2-xyz1;
            d=sqrt(sum(r.^2));
        end
    end
    methods(Static)
        
    end
end

