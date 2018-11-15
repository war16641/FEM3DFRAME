classdef LoadCase<handle & matlab.mixin.Heterogeneous
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        f FEM3DFRAME
        name char%工况名
        bc BC
        rst Result
        
        K double%结构刚度矩阵 处理边界条件前
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
    end
    methods(Abstract)
        Solve(obj)
        GetK(obj)
    end
end

