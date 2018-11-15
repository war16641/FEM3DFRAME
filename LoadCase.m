classdef LoadCase<handle & matlab.mixin.Heterogeneous
    %UNTITLED �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        f FEM3DFRAME
        name char%������
        bc BC
        rst Result
        
        K double%�ṹ�նȾ��� ����߽�����ǰ
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

