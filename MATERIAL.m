classdef MATERIAL<handle
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        E%弹模
        v%泊松比
        rou%密度
        name
        D
        G%剪切模量
    end
    
    methods
        function obj = MATERIAL(e,v,rou,n)


            obj.E=e;
            obj.v=v;
            obj.rou=rou;
            obj.name=n;
            obj.G=e/(1+v)/2;
            %计算弹性矩阵
            obj.D=e/(1-v^2)*[1 v 0
                v  1 0
                0  0  (1-v)/2];
        end
        function disp(obj)%重写显示函数
            disp([sprintf('%10s','name') sprintf('%10s%10s%10s','E','v','rou')]);
            for it=1:length(obj)
                disp([sprintf('%10s',obj(it).name) sprintf('% 10.2e% 10.2e% 10.2e',obj(it).E,obj(it).v,obj(it).rou) ]);
            end            
        end
        
    end
end

