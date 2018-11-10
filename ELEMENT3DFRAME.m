classdef ELEMENT3DFRAME <handle & matlab.mixin.Heterogeneous
    %3d框架模型的抽象基类
    
    properties
        f FEM3DFRAME%模型指针        
        id double%单元编号
        nds%存储有限元中的节点号 
        ndcoor%存储节点坐标
        
        arg%计算中间量
    end
    
    methods
        function obj = ELEMENT3DFRAME(f,id,nds)
            %如果id为0 使用最大编号+1
            if 0==id
                id=f.manager_ele.maxnum+1;
            end
            
            %检查nds中是否所有节点存在
            for it=nds
                if false==f.node.IsExist(it)
                    error('MATLAB:myerror','节点不存在');
                end
            end
            
            
            obj.f=f;
            obj.id=id;
            obj.nds=nds;
            obj.ndcoor=[];%在开始计算单元刚度时载入坐标
        end
    end
    methods(Abstract)
        Kel = GetKel(obj)%形成自己的单元矩阵
        K=FormK(obj,K)%K为结构的刚度矩阵 将自己单元的矩阵送入结构
    end
end

