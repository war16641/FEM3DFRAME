classdef LoadCase_MultStepStatic<LoadCase_Static
    %多步骤静力工况
    properties
        tn%时间点
        scale%系数
    end
    
    methods
        function obj = LoadCase_MultStepStatic(f,name)
            obj=obj@LoadCase_Static(f,name);
        end

        function Set(obj,tn,scale)%设置 系数时程
            tn=VectorDirection(tn);
            scale=VectorDirection(scale);
            %检查两者是否是大小一致
            if length(tn)~=length(scale)
                error('nyh:error','两列数据长度不一致')
            end
            %检查tn是否递增
            for it=2:length(tn)
                if tn(it)<tn(it-1)
                    error('nyh:error','时间序列不是递增')
                end
            end
            obj.tn=tn;
            obj.scale=scale;
            
        end
        function Solve(obj)
            obj.PreSolve();
            obj.CheckBC1();%附加的边界条件检查
            %判断工况是线性的还是非线性的
            if obj.f.flag_nl==0%线性结构
                for stepn=1:length(obj.tn)
                    u1=obj.K1\(obj.f_node1*obj.scale(stepn));
                    %处理求解后所有自由度上的力和位移
                    obj.SetState(u1);
                    %把结果保存到noderst
                    obj.rst.AddByState(obj.tn(stepn),'time');
                end
                %初始化结果指针
                obj.rst.SetPointer();
            else%非线性结构
                
                f_node_origin=obj.f_node1;
                for stepn=1:length(obj.tn)
                    obj.f_node1=f_node_origin*obj.scale(stepn);%改变外荷载
                    u_all=obj.Script_NR(obj,obj.f_node1);        
                    obj.SetState(u_all(obj.activeindex));
                    %添加结果
                    obj.rst.AddByState(obj.tn(stepn),'time');
                    
                end
                %初始化结果指针
                obj.rst.SetPointer();
            end
        end
    end
end

