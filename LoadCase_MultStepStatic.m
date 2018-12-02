classdef LoadCase_MultStepStatic<LoadCase_Static
    %�ಽ�農������
    properties
        tn%ʱ���
        scale%ϵ��
    end
    
    methods
        function obj = LoadCase_MultStepStatic(f,name)
            obj=obj@LoadCase_Static(f,name);
        end

        function Set(obj,tn,scale)%���� ϵ��ʱ��
            tn=VectorDirection(tn);
            scale=VectorDirection(scale);
            %��������Ƿ��Ǵ�Сһ��
            if length(tn)~=length(scale)
                error('nyh:error','�������ݳ��Ȳ�һ��')
            end
            %���tn�Ƿ����
            for it=2:length(tn)
                if tn(it)<tn(it-1)
                    error('nyh:error','ʱ�����в��ǵ���')
                end
            end
            obj.tn=tn;
            obj.scale=scale;
            
        end
        function Solve(obj)
            obj.PreSolve();
            obj.CheckBC1();%���ӵı߽��������
            %�жϹ��������ԵĻ��Ƿ����Ե�
            if obj.f.flag_nl==0%���Խṹ
                for stepn=1:length(obj.tn)
                    u1=obj.K1\(obj.f_node1*obj.scale(stepn));
                    %���������������ɶ��ϵ�����λ��
                    u=obj.u_beforesolve;
                    u(obj.activeindex)=u1;
                    f=obj.K*u;
                    %�ѽ�����浽noderst
                    obj.rst.AddTime(obj.tn(stepn),f,u);
                end
                %��ʼ�����ָ��
                obj.rst.SetPointer();
            else%�����Խṹ
                
                for stepn=1:length(obj.tn)
                    obj.f_node1=obj.f_node1*obj.scale(stepn);%�ı������
                    u_all=obj.Script_NR();
                    
                    %���㵯�Բ�����
                    f=obj.K*u_all;
                    %��ӽ��
                    obj.rst.AddTime(obj.tn(stepn),f,u_all);
                    
                end
                %��ʼ�����ָ��
                obj.rst.SetPointer();
            end
        end
    end
end

