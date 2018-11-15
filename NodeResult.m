classdef NodeResult<handle
    %UNTITLED4 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        lc LoadCase
        timeframe %管理与时间相关的NodeResultFrame 如动力结果  时间结果 第一列是时间
        nontimeframe %管理与时间无关的NodeResultFrame  如静力 动力的统计结果 非时间结果 第一列是名字
    end
    
    methods
        function obj = NodeResult(lc)
            obj.lc=lc;
            obj.timeframe=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nontimeframe=VCM.VALUE_CLASS_MANAGER();

        end
        function AddNontime(obj,framename,vector_f,vectro_u)%添加一个非时间结果
            tmp=NodeResultFrame(obj,framename);
            tmp.Make(vector_f,vectro_u);
            obj.nontimeframe.Add(framename,tmp);%添加

        end


        function r=Get(obj,nrf_type,nrf_id,type,id,dir)%读取结果
            %nrf_type 指定是时间结果还是非时间结果 ‘time’'nontime'
            %nrf_id 标识符 即framename
            %type force或者displ
            %id 节点编号
            %dir 方向可以是 1~6 或者 ux uy uz rx ry rz 或者 [1 3] 或者 'all' 
            
            %也可以只输入三个参数type,id,dir
            %如果直接是type,id,dir三个参数的话调用第一个非时间结果
            if 4==nargin
                nrf=obj.nontimeframe.Get('index',1);
                r=nrf.Get(nrf_type,nrf_id,type);
                return;
            end
            
            
            switch nrf_type(1)
                case 'n'%非时间结果
                    nrf=obj.nontimeframe.Get('id',nrf_id);
                    r=nrf.Get(type,id,dir);
                case 't'%时间结果
                    nrf=obj.timeframe.Get('id',nrf_id);
                    r=nrf.Get(type,id,dir);
                otherwise
                    error('matlab:myerror','无此类型')
            end

            
        end

    end


end

