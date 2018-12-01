classdef LoadCase<handle & matlab.mixin.Heterogeneous
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        f FEM3DFRAME
        name char%工况名
        bc BC
        rst 
        
        dof%自由度数 未引入边界条件前
        activeindex%有效自由度索引
        
        K double%结构刚度矩阵 处理边界条件前
        M double
        C double
    end
    
    methods
        function obj = LoadCase(f,name)
            obj.f=f;
            obj.name=name;
            obj.bc=BC(obj);
            obj.rst=Result(obj);
           

        end
        
        function AddBC(obj,type,ln)%ln=ndid,dir,value         dir=1~6
            obj.bc.Add(type,ln);
        end
        function CloneBC(obj,lc)%从其他工况复制BC
            for it=1:lc.bc.displ.num
                ln=lc.bc.displ.Get('index',it);
                obj.AddBC('displ',ln);
            end
            for it=1:lc.bc.force.num
                ln=lc.bc.force.Get('index',it);
                obj.AddBC('force',ln);
            end
        end
    end
    methods(Abstract)
        Solve(obj)
        GetK(obj)
    end
end

