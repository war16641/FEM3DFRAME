classdef SECTION<handle
    %UNTITLED12 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        name
        mat MATERIAL
        A
        Iy 
        Iz
        J
    end
    
    methods
        function obj = SECTION(varargin)
            %name
            %mat
            %A
            %Iy
            %Iz
            %J 可选
            if length(varargin)==5
                obj.name=varargin{1};
                obj.mat=varargin{2};
                obj.A=varargin{3};
                obj.Iy=varargin{4};
                obj.Iz=varargin{5};
                obj.J=obj.Iy+obj.Iz;%没有指定扭转常数时 使用 抗弯惯距的和
            elseif length(varargin)==6
                obj.name=varargin{1};
                obj.mat=varargin{2};
                obj.A=varargin{3};
                obj.Iy=varargin{4};
                obj.Iz=varargin{5};
                obj.J=varargin{6};
            else
                error('未知的构造参数')
            end
        end
        function disp(obj)
            disp([sprintf('%10s','name') sprintf('%10s','mat_name') sprintf('%10s%10s%10s','A','Iy','Iz')]);
            for it=1:length(obj)
                disp([sprintf('%10s',obj(it).name) sprintf('%10s',obj(it).mat.name) sprintf('% 10.2e% 10.2e% 10.2e',obj(it).A,obj(it).Iy,obj(it).Iz)]);
            end
            
        end
%         function obj = SECTION(A,Iy,Iz,name)
%             
%             obj.A=A;
%             obj.Iy=Iy;
%             obj.Iz=Iz;
%             obj.name=name;
%       
%         end

    end
end

