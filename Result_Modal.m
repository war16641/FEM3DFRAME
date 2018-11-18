classdef Result_Modal<Result
    %Ϊmodal����׼������
    
    properties
        periodinfo %�洢������Ϣ ����Ƶ�� �ȵ�
    end
    
    methods
        function obj = Result_Modal(lc)
            obj=obj@Result(lc);
            obj.periodinfo=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        
        function Add(obj,order,w,vector_f,vectro_u)
            %���ĳ�����͵ļ����� 
            %ͨ��ԲƵ�� �� ��񻯵�����
            
            obj.periodinfo.Add(order,[2*pi/w w/2/pi w]);%���� ʱ��Ƶ�� ԲƵ��
            obj.AddTime(order,vector_f,vectro_u);

        end
        function SetPointer(obj,order)
            %frametype ��ȡ'time' 'nontime'
            if nargin==1%ûָ��frametype,framename
                order=1;%����Ĭ��ָ�� Ϊ ʱ��֡�ĵ�һ�� ��һ������
            end
            obj.pointer=obj.timeframe.Get('id',order);

        end

        function [order,pi]=GetPerodInfo(obj)%���ص�ǰ�Ľ�����periodinfo��Ϣ
            order=obj.pointer.framename;
            pi=obj.periodinfo.Get('index',order);
        end
    end
end

