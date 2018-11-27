classdef EarthquakeInput<handle
    %地震波的输入
    
    properties
        lc
        name
        ew%地震波
        scale%放大系数
        theta%地震输入角度 绕z轴 以x为0度
        
        tn%1*n
        accn%3*n 一列代表某时刻的三个方向的加速度
    end
    
    methods
        function obj = EarthquakeInput(lc,name,ew,scale,theta)%暂未支持竖向输入
            obj.lc=lc;
            obj.name=name;
            obj.ew=ew;
            obj.theta=theta;
            obj.scale=scale;
            obj.MakeData();
        end
        
        function MakeData(obj)%生成tn accn 
            obj.ew.SwitchUnit();%转换单位
            obj.tn=obj.ew.tn';
            obj.accn=zeros(3,obj.ew.numofpoint);
            obj.accn(1,:)=[obj.ew.accn*cos(obj.theta)]'*obj.scale;
            obj.accn(2,:)=[obj.ew.accn*sin(obj.theta)]'*obj.scale;
        end
    end
end

