classdef Result<handle
    %UNTITLED 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        lc LoadCase
        pointer ResultFrame%当前的指针 get的返回值来源于pointer指向的结果帧
        timeframe
        nontimeframe
    end
    
    methods
        function obj = Result(lc)
            obj.lc=lc;
            obj.timeframe=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nontimeframe=VCM.VALUE_CLASS_MANAGER();
        end
        function SetPointer(obj,frametype,framename)
            %frametype 可取'time' 'nontime'
            if nargin==1%没指定frametype,framename
                if obj.nontimeframe.num~=0
                    obj.pointer=obj.nontimeframe.Get('index',1);%设置默认指针 为 非时间帧的第一个
                elseif obj.timeframe.num~=0
                    obj.pointer=obj.timeframe.Get('index',1);%设置默认指针 为 时间帧的第一个
                else
                    error('没有结果帧')
                end
                return;
            end
            switch frametype(1)
                case 't'%时间
                    obj.pointer=obj.timeframe.Get('id',framename);
                case 'n'%非时间
                    obj.pointer=obj.nontimeframe.Get('id',framename);
                otherwise
                    error('sd')
            end
        end
        function AddNontime(obj,framename,vector_f,vectro_u)
            tmp=ResultFrame(framename,obj,vector_f,vectro_u);
            obj.nontimeframe.Add(framename,tmp);
        end
        function AddTime(obj,idname,varargin)%添加基于数字（时间 自振阶数）的结果帧
            %idname 在时程工况中表示时间 在自振工况中表示阶数
            tmp=ResultFrame(idname,obj,varargin);
            obj.timeframe.Add(idname,tmp);
        end
        function AddByState(obj,framename,type)
            tmp=ResultFrame(framename,obj);
            tmp.LoadFromState();
            switch type
                case 'time'
                    obj.timeframe.Add(framename,tmp,0);
                case 'nontime'
                    obj.nontimeframe.Add(framename,tmp);
                otherwise
                    error('sd')
            end
        end
        function r = Get(obj,varargin)
            %rst_type node 或者 ele
            %rst_type='node'    type='force' 'displ'
             %                             id 节点id
             %                             dir 方向
            r=obj.pointer.Get(varargin);


        end
        function [r,tn]=GetTimeHistory(obj,t1,t2,varargin)%获取时程结果
            if t1<0||isempty(t1)
                t1=0;
            end
            if t2>obj.timeframe.Get('index',obj.timeframe.num)||isempty(t2)
                t2=obj.timeframe.Get('index',obj.timeframe.num);
            end
            [ind1,index1]=obj.timeframe.FindId(t1);
            [ind2,index2]=obj.timeframe.FindId(t2);%查找起始和结束结果序号
            if index1==0
                index1=1;
            end
            index1=max([ind1 index1]);
            index2=max([ind2 index2]);
            numline=index2-index1+1;%结果帧个数
            r=[];
            tn=[];
            for it=index1:index2
                tmp=obj.timeframe.Get('index',it);
                r1=tmp.Get(varargin);
                r=[r;r1];
                tn=[tn;tmp.framename];
            end
        end
    end
end

