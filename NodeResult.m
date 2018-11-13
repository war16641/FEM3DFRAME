classdef NodeResult<handle
    %UNTITLED4 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        lc LoadCase
        force double%�ڵ���(���Խڵ����) FEM.solve���� ��һ���ǽڵ���
        displ double%�ڵ�λ�� FEM.solve���� ��һ���ǽڵ��� 2~7��λ��
    end
    
    methods
        function obj = NodeResult(lc)
            obj.lc=lc;
            obj.force=[];
            obj.displ=[];
        end
        function Reset(obj)%��ʼ��force��displ ����ô�С
            if ~isempty(obj.force)||~isempty(obj.displ)
                warning('��ʼ���ڵ���ʱ�����нڵ���,��ȷ���Ƿ��쳣��')
            end
            obj.force=zeros(obj.lc.f.node.ndnum,7);
            obj.displ=zeros(obj.lc.f.node.ndnum,7);
        end
        function SetLine(obj,type,row,id,d)%�����Ϣ
            %type f ��     dλ��
            %row�к�
            %id�ڵ���
            %d 1*6�Ľڵ�λ��
            
            switch type(1)%ֻ�õ�һ���ַ����ж�  %������Ӧ��Ҫ���Ҫд��ĵط��Ƿ���ֵ ����Ϊ���ٶȾͲ���
                case 'f'
                    obj.force(row,1)=id;
                    obj.force(row,2:7)=d;
                case 'd'
                    obj.displ(row,1)=id;
                    obj.displ(row,2:7)=d;
                otherwise
                    error('sd');
            end
            
        end
        function r=Get(obj,type,id,dir)%��ȡ���
            %type force����displ
            %id �ڵ���
            %dir ��������� 1~6 ���� ux uy uz rx ry rz ���� [1 3] ���� 'all' 
            
            %��dir��������
            if isa(dir,'char')
                switch dir
                    case 'ux'
                        dir=1;
                    case 'uy'
                        dir=2;
                    case 'uz'
                        dir=3;
                    case 'rx'
                        dir=4;
                    case 'ry'
                        dir=5;
                    case 'rz'
                        dir=6;
                    case 'all'
                        dir=1:6;
                    otherwise
                        error('matlab:myerror','δ֪���ɶ�')
                end
            elseif isa(dir,'double')
            else
                error('matlab:myerror','δ֪���ɶ�')
            end
            
            %�����ڲ���������
            switch type(1)
                case 'f'
                    r=obj.GetForce(id,dir);
                case 'd'
                    r=obj.GetDispl(id,dir);
                otherwise
                    error('matlab:myerror','δ֪���ɶ�')
            end
            
        end

    end
    methods(Access=private)
        function r=GetForce(obj,id,dir)%������
            for it=1:size(obj.force,1)%�㷨�д��Ľ�
                if id==obj.force(it,1)
                    r=obj.force(it,dir+1);
                    return;
                end
            end
            error('matlab:myerror','δ�ҵ�')
        end
        function r=GetDispl(obj,id,dir)%����λ��
            for it=1:size(obj.displ,1)%�㷨�д��Ľ�
                if id==obj.displ(it,1)
                    r=obj.displ(it,dir+1);
                    return;
                end
            end
            error('matlab:myerror','δ�ҵ�')
        end
    end
end

