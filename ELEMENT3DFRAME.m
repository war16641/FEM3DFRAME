classdef ELEMENT3DFRAME <handle & matlab.mixin.Heterogeneous
    %3d���ģ�͵ĳ������
    
    properties
        f FEM3DFRAME%ģ��ָ��        
        id double%��Ԫ���
        nds%�洢����Ԫ�еĽڵ�� 
        ndcoor%�洢�ڵ�����
        Kel double%���վ��� ����������
        Kel_ double%���վ��� �ֲ�������
        Mel double%��Ԫ��������
        Mel_ double
        KTel%�����Խṹ�նȾ���
        Fsel%�����ԵĻظ���
        C66 double %����ת������ ��Ե����ڵ��
        hitbyele double%���ɶ��Ƿ񱻵�Ԫ����  ��Щ��Ԫ�����ɶȲ�δ���� ����ܵ�Ԫ �и˶�����ͷŵ�����Ԫ ��ʽΪ�ڵ����*6
        flag_nl%��ʶ�����Ԫ�Ƿ��Ƿ�����Ĭ �������Ե�0
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
            obj.flag_nl=0;%Ĭ�������Ե�
            tmp=length(nds);
            obj.KTel=zeros(6*tmp,6*tmp);
            obj.Fsel=zeros(6*tmp,1);
            %��ʼ����Ч���ɶȾ���
            obj.hitbyele=zeros(length(obj.nds),6);

        end
        function set.flag_nl(obj,v)
            obj.flag_nl=v;
            if v==1
            obj.f.flag_nl=v;
            end
        end
        function mat_tar=FormMatrix(obj,mat_tar,mat)%����Ԫ��ĳĳ����mat����mat_tar
            n=length(obj.nds);
            for it1=1:n
                for it2=1:n
                    x=obj.nds(it1);
                    y=obj.nds(it2);
                    xuhao1=obj.f.node.GetXuhaoByID(x);%�õ� �ڵ�Ŷ�Ӧ�ڸնȾ�������
                    xuhao2=obj.f.node.GetXuhaoByID(y);
                    mat_tar(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=mat_tar(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+mat(6*it1-5:6*it1,6*it2-5:6*it2);
                end
            end
        end
        function vec_tar=FormVector(obj,vec_tar,vec)
            n=length(obj.nds);
            for it=1:n
                xh=obj.f.node.GetXuhaoByID(obj.nds(it));%�õ� �ڵ�Ŷ�Ӧ�ڸնȾ�������
                vec_tar(xh:xh+5)=vec_tar(xh:xh+5)+vec(6*it-5:6*it);
            end
        end
        function vec_i=GetMyVec(obj,vec,lc)%������������л�ȡ�Լ�������
            %vec�Ǽ���߽��������
            
            %����vec������߽�����ǰ
            v=zeros(lc.dof,1);
            v(lc.activeindex)=vec;
            n=length(obj.nds);
            vec_i=zeros(n*6,1);
            for it=1:n
                ndid=obj.nds(it);
                xh=obj.f.node.GetXuhaoByID(ndid);%�õ� �ڵ�Ŷ�Ӧ�ڸնȾ�������
                vec_i(6*it-5:6*it)=v(xh:xh+5);
            end
        end
        function CalcHitbyele(obj)%�������ɶ��Ƿ񱻵�Ԫ����
            %���ڼ����˵��ԸնȾ���Kel��KTel������������
            %���⣺���kelû��ĳ�����ɶȵĸնȣ���ktel�ڿ�ʼʱҲû�նȵ��Ǻ��������ն�
            %���ܻᵼ�³����ڿ�ʼ�׶�ֱ����Ϊ�����ɶ�Ϊdead
            
            
            %������Ч���ɶ� Kel
            dg=diag(obj.Kel);
            for it=1:length(obj.nds)
                tmp=dg(6*it-5:6*it);
                tmp=abs(tmp)>1e-10;
                obj.hitbyele(it,tmp)=1;
            end

            
            %KTel
            dg=diag(obj.KTel);
            for it=1:length(obj.nds)
                tmp=dg(6*it-5:6*it);
                tmp=abs(tmp)>1e-10;
                obj.hitbyele(it,tmp)=1;
            end
            
        end
    end
    methods(Abstract)
        Kel = GetKel(obj)%�γ��Լ��ĵ�Ԫ����
        Mel=GetMel(obj);%��װ��Ԫ������
        K=FormK(obj,K)%KΪ�ṹ�ĸնȾ��� ���Լ���Ԫ�ľ�������ṹ
        M=FormM(obj,M)
        InitialKT(obj)%��ʼ��KTel Fsel
        [force,deform]=GetEleResult(obj,varargin)%���ݽ�����㵥Ԫ�����ͱ��� force�ǵ�Ԫ�ڲ������ֲ�����ϵ��,�ڵ�Ե�Ԫ������ deform�ǵ�Ԫ���Σ��ֲ����꣩ 
    end
end

