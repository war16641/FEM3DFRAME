classdef NODE<handle
    %这个类负责管理FEM2D的节点
    
    properties
        f FEM3DFRAME%隶属于哪一个有限元
        nds %由vcm管理 第一列是id 后面三个坐标构成的矩阵

        nds_mapping %节点编号与刚度矩阵的映射 第一列是节点编号 第二列是节点x自由度对应的序号 
        nds_mapping_r %nds_mapping的反矩阵 第一列是序号 第二列是节点
        maxnum%使用的最大编号
        ndnum%节点个数
    end
    
    methods
        function obj = NODE(f)
            obj.f=f;
            obj.maxnum=0;
            obj.ndnum=0;
            obj.nds=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nds_mapping=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nds_mapping_r=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            
        end
        function AddByCartesian(obj,id,x,y,z)
            if 0==id%最大的数加一
                id=obj.maxnum+1;
                obj.nds.Append(id,[x y z]);
                return;
            end
            obj.nds.Add(id,[x y z],1);
            

        end
        function v=get.maxnum(obj)
            if 0==obj.ndnum
                obj.maxnum=0;
                v=obj.maxnum;
                return;
            end
            obj.maxnum=obj.nds.object{end,1};
            v=obj.maxnum;
        end
        function v=get.ndnum(obj)
            obj.ndnum=size(obj.nds.object,1);
            v=obj.ndnum;
        end
        function flag=IsExist(obj,id)
            %判断某个节点是否存在
            i=obj.nds.FindId(id);
            if i==0%没找到
                flag=false;
                return;
            else
                flag=true;
                return;
            end
        end
        function xyz = GetCartesianByID(obj,id)
            xyz=obj.nds.Get('id',id);
            if isempty(xyz)
                error('未找到节点');
            end
            
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
                    label='rz';index=6;yushu=6;
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
            
            %首先检查是否已建立mapping
            if obj.ndnum==obj.nds_mapping.num
                return;%已经建立
            elseif obj.nds_mapping.num==0%未建立
            else%建立了一个不完整的‘
                error('已经建立了不完整的映射')
            end
            
            lastx=-5;
            for it=1:obj.ndnum
                lastx=lastx+6;
                obj.nds_mapping.Append(obj.nds.object{it,1},lastx);
                obj.nds_mapping_r.Append(lastx,obj.nds.object{it,1});
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

