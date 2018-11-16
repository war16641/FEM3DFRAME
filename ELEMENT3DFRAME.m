classdef ELEMENT3DFRAME <handle & matlab.mixin.Heterogeneous
    %3d���ģ�͵ĳ������
    
    properties
        f FEM3DFRAME%ģ��ָ��        
        id double%��Ԫ���
        nds%�洢����Ԫ�еĽڵ�� 
        ndcoor%�洢�ڵ�����
        Kel double%���վ��� ����������
        Kel_ double%���վ��� �ֲ�������
        C66 double %����ת������ ��Ե����ڵ��
        hitbyele double%���ɶ��Ƿ񱻵�Ԫ����  ��Щ��Ԫ�����ɶȲ�δ���� ����ܵ�Ԫ �и˶�����ͷŵ�����Ԫ ��ʽΪ�ڵ����*6
        arg%�����м���
    end
    
    methods
        function obj = ELEMENT3DFRAME(f,id,nds)
            %���idΪ0 ʹ�������+1
            if 0==id
                id=f.manager_ele.maxnum+1;
            end
            
            %���nds���Ƿ����нڵ����
            for it=nds
                if false==f.node.IsExist(it)
                    error('MATLAB:myerror','�ڵ㲻����');
                end
            end
            
            
            obj.f=f;
            obj.id=id;
            obj.nds=nds;
            obj.ndcoor=[];%�ڿ�ʼ���㵥Ԫ�ն�ʱ��������

        end
    end
    methods(Abstract)
        Kel = GetKel(obj)%�γ��Լ��ĵ�Ԫ����
        K=FormK(obj,K)%KΪ�ṹ�ĸնȾ��� ���Լ���Ԫ�ľ�������ṹ
        [force,deform]=GetEleResult(obj,varargin)%���ݽ�����㵥Ԫ�����ͱ��� force�ǵ�Ԫ�ڲ������ֲ�����ϵ��,�ڵ�Ե�Ԫ������ deform�ǵ�Ԫ���Σ��ֲ����꣩ 
    end
end

