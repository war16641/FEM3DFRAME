classdef Result_Modal<Result
    %为modal工况准备的类
    
    properties
        periodinfo %存储周期信息 周期频率 等等
    end
    
    methods
        function obj = Result_Modal(lc)
            obj=obj@Result(lc);
            obj.periodinfo=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Add(obj,order,w,vector_f,vectro_u)
            %添加某阶阵型的计算结果 
            %通过圆频率 和 规格化的阵型
            
            obj.periodinfo.Add(order,[2*pi/w w/2/pi w]);%周期 时间频率 圆频率
            obj.AddTime(order,vector_f,vectro_u);

        end
        function SetPointer(obj,order)
            %frametype 可取'time' 'nontime'
            if nargin==1%没指定frametype,framename
                order=1;%设置默认指针 为 时间帧的第一个 即一阶振型
            end
            obj.pointer=obj.timeframe.Get('id',order);

        end

        function [order,pi]=GetPerodInfo(obj)%返回当前的阶数和periodinfo信息
            order=obj.pointer.framename;
            pi=obj.periodinfo.Get('index',order);
        end
    end
end

