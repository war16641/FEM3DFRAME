classdef ELEMENT3DFRAME <handle & matlab.mixin.Heterogeneous
    %3d框架模型的抽象基类
    
    properties
        f FEM3DFRAME%模型指针        
        id double%单元编号
        nds%存储有限元中的节点号 
        ndcoor%存储节点坐标
        Kel double%单刚矩阵 总体坐标下
        Kel_ double%单刚矩阵 局部坐标下
        C66 double %坐标转换矩阵 针对单个节点的
        hitbyele double%自由度是否被单元击中  有些单元的自由度并未激活 如桁架单元 有杆端弯矩释放的梁单元 格式为节点个数*6
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
        [force,deform]=GetEleResult(obj,varargin)%根据结果计算单元的力和变形 force是单元内部力（局部坐标系下,节点对单元的力） deform是单元变形（局部坐标） 
    end
end

