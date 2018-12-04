classdef DAMPING<handle
    %UNTITLED5 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        lc 
        typename char
        arg cell
        
    end
    
    methods
        function obj = DAMPING(lc)
            obj.lc=lc;
            obj.typename='';
            obj.arg={};
        end
        
        function Set(obj,varargin)
            varargin=Hull(varargin);
            switch varargin{1}
                case 'rayleigh'%瑞利阻尼 依次是质量矩阵乘子 刚度矩阵乘子
                    obj.typename='rayleigh';
                    if 3~=length(varargin)
                        error('matlab:myerror','瑞利阻尼梁参数')
                    end
                    obj.arg=varargin(2:end);
                case 'matrix'%直接指定C1
                    obj.typename='matrix';
                    obj.arg=varargin(2);
                otherwise
                    error('matlab:myerror','未知阻尼类型')
            end
        end
        function Make(obj)%生成lc阻尼矩阵 需要调用lc的M1 K1
            %注意:调用此函数前 确保质量和刚度矩阵已经计算完毕 
            switch obj.typename
                case 'rayleigh'%瑞利阻尼
                    obj.lc.C1=obj.arg{1}*obj.lc.M1+obj.arg{2}*obj.lc.K1;
                case 'matrix'%直接指定C1
                    obj.lc.C1=obj.arg{1};
                otherwise
                    error('matlab:myerror','未知阻尼类型')
            end
        end
    end
    methods(Static)
        function [alpha,beta,c]=RayleighDamping(w1,w2,xi1,xi2,k,m)
            %瑞利阻尼 w xi是圆频率和阻尼比
            %alpha是质量乘子
            if nargin==4
                t=2*w1*w2/(w2^2-w1^2)*[w2 -w1;-1/w2 1/w1]*[xi1 ;xi2];
                alpha=t(1);beta=t(2);
            elseif nargin==6
                t=2*w1*w2/(w2^2-w1^2)*[w2 -w1;-1/w2 1/w1]*[xi1 ;xi2];
                alpha=t(1);beta=t(2);
                c=alpha*m+beta*k;
            end
        end
    end
end

