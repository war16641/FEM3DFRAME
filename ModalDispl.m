classdef ModalDispl<handle
    %模态坐标
    
    properties
        lc_m%模态工况
        lc_e%地震工况
        timeframe
    end
    
    methods
        function obj = ModalDispl(lc_m,lc_e)
            obj.lc_m=lc_m;
            obj.lc_e=lc_e;
            obj.timeframe=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            %首先验证两者的activeindex是否一致
            if norm(lc_m.activeindex-lc_e.activeindex)~=0
                error('nyh:error','要求modal工况的有效自由度和本工况一致，不一致可能是边界条件不同导致的。')
            end
            %检查modal工况是否用刚度规格化阵型
            if 'k'~=lc_m.arg{2}
                error('nyh:error','要求modal工况的使用刚度规格化阵型。')%这个条件不是必须条件。但是刚度规格化可以方便地使用模态坐标表示应变能。
            end
                        %求解模态坐标
            modeli=lc_m.mode^-1;
            for timeindex=1:lc_e.rst.timeframe.num
                tf=lc_e.rst.timeframe.Get('index',timeindex);
                v=tf.Get('node','displ','all','all');
                v=v(lc_e.activeindex);%去除无效自由度
                v=v';%转化为列向量
                Y=modeli*v;
                obj.timeframe.Add(tf.framename,Y);
            end
        end
        
        function [maxY,YY,eng]=PlotData(obj,order)%做图表示
            %order 参与做图的最大的阶数
            
            %maxY最大的模态坐标
            %YY模态坐标 时间点个数*order double
            %eng    时间点个数*4 最后一列为势能和
            if nargin==1
                order=obj.lc_m.arg{1};%不指定时 取所有阵型阶数
            end
            YY=zeros(obj.timeframe.num,order);
            for timeindex=1:obj.timeframe.num
                tmp=obj.timeframe.Get('index',timeindex);
                YY(timeindex,1:order)=tmp(1:order);
            end
            le=obj.Number2Str(1:order);
            eng=YY.^2;%能量
            tn=obj.timeframe.GetAllId();
            tn=cell2mat(tn);
            figure
            plot(tn,YY);
            xlabel('时间/s');ylabel('模态坐标');
            title(['模态工况' obj.lc_m.name ' 地震工况' obj.lc_e.name])
            legend(le);
            maxY=max(YY);
            figure
            plot(tn',eng);
            t=sum(eng,2);
            eng=[eng t];
            xlabel('时间/s');ylabel('阵型势能');
            title(['模态工况' obj.lc_m.name ' 地震工况' obj.lc_e.name])
            legend(le);
            set(gca,'yscale','log');%改为对数坐标
        end
    end
    methods(Static)
        function c=Number2Str(x)%将数字向量化作字符串细胞
            c=cell(1,length(x));
            for it=1:length(x)
                c{it}=num2str(x(it));
            end
        end
    end
end

