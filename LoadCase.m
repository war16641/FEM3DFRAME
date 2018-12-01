classdef LoadCase<handle & matlab.mixin.Heterogeneous
    %UNTITLED �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        f FEM3DFRAME
        name char%������
        bc BC
        rst 
        
        dof%���ɶ��� δ����߽�����ǰ
        activeindex%��Ч���ɶ�����
        
        K double%�ṹ�նȾ��� ����߽�����ǰ
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
        function CloneBC(obj,lc)%��������������BC
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

