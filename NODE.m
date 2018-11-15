classdef NODE<handle
    %这个类负责管理FEM2D的节点
    
    properties
        f FEM3DFRAME%隶属于哪一个有限元
        nds double%4列 第一列为id

        nds_mapping %节点编号与刚度矩阵的映射 第一列是节点编号 第二列是节点x自由度对应的序号 FEM2D.solve操作
        nds_mapping_r %nds_mapping的反矩阵 第一列是序号 第二列是节点
        maxnum%使用的最大编号
        ndnum%节点个数
    end
    
    methods
        function obj = NODE(f)
            obj.f=f;
            obj.maxnum=0;
            obj.ndnum=0;
            obj.nds_mapping=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nds_mapping_r=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            
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
          xuhao=obj.nds_mapping.Get('id',id);
          if isempty(xuhao)
              error('无此节点');
          end
        end
        function [id,index,label]=GetIdByXuhao(obj,xh)%通过刚度矩阵中的序号获得节点id 
            %先将xh放到ux上 并计算index和label
            yushu=mod(xh,6);
            switch yushu
                case 1
                    label='ux';
                    index=1;
                case 2
                    label='uy';index=2;
                 case 3
                    label='uz';index=3;
                case 4
                    label='rx';index=4;
                case 5
                    label='ry';index=5;
                 case 0
                    label='rz';index=6;
            end
            
            %计算id
            xh=xh-yushu+1;%将序号移动到本节点的ux自由度上
            id=obj.nds_mapping_r.Get('id',xh);
            if isempty(id)
                error('未找到')
            end
        end
        function SetupMapping(obj)%建立节点自由度对刚度矩阵(K)的映射 
            %这个函数执行应在solve中调用
            %此函数执行后 不应再对节点进行操作了
            lastx=-5;
            for it=1:obj.ndnum
                lastx=lastx+6;
                obj.nds_mapping.Append(obj.nds(it,1),lastx);
                obj.nds_mapping_r.Append(lastx,obj.nds(it,1));
            end
            obj.nds_mapping.Check();
            obj.nds_mapping_r.Check();
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

