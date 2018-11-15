classdef NodeResult<handle
    %UNTITLED4 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        lc LoadCase
        timeframe %������ʱ����ص�NodeResultFrame �綯�����  ʱ���� ��һ����ʱ��
        nontimeframe %������ʱ���޹ص�NodeResultFrame  �羲�� ������ͳ�ƽ�� ��ʱ���� ��һ��������
    end
    
    methods
        function obj = NodeResult(lc)
            obj.lc=lc;
            obj.timeframe=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.nontimeframe=VCM.VALUE_CLASS_MANAGER();

        end
        function AddNontime(obj,framename,vector_f,vectro_u)%���һ����ʱ����
            tmp=NodeResultFrame(obj,framename);
            tmp.Make(vector_f,vectro_u);
            obj.nontimeframe.Add(framename,tmp);%���

        end


        function r=Get(obj,nrf_type,nrf_id,type,id,dir)%��ȡ���
            %nrf_type ָ����ʱ�������Ƿ�ʱ���� ��time��'nontime'
            %nrf_id ��ʶ�� ��framename
            %type force����displ
            %id �ڵ���
            %dir ��������� 1~6 ���� ux uy uz rx ry rz ���� [1 3] ���� 'all' 
            
            %Ҳ����ֻ������������type,id,dir
            %���ֱ����type,id,dir���������Ļ����õ�һ����ʱ����
            if 4==nargin
                nrf=obj.nontimeframe.Get('index',1);
                r=nrf.Get(nrf_type,nrf_id,type);
                return;
            end
            
            
            switch nrf_type(1)
                case 'n'%��ʱ����
                    nrf=obj.nontimeframe.Get('id',nrf_id);
                    r=nrf.Get(type,id,dir);
                case 't'%ʱ����
                    nrf=obj.timeframe.Get('id',nrf_id);
                    r=nrf.Get(type,id,dir);
                otherwise
                    error('matlab:myerror','�޴�����')
            end

            
        end

    end


end

