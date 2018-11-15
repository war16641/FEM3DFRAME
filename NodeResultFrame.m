classdef NodeResultFrame<handle

    
properties
        rf ResultFrame
        force VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%�ڵ���(���Խڵ����) solve���� ��һ���ǽڵ��� �ڶ�����6*1 double
        displ VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED%�ڵ�λ�� 
    end
    
    methods
        function obj = NodeResultFrame(rf)
            obj.rf=rf;
            obj.force=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
            obj.displ=VCM.VALUE_CLASS_MANAGER_UNIQUE_SORTED();
        end
        function Make(obj,vector_f,vectro_u)%�ӽڵ����ͽڵ�λ������������������force��displ
            obj.Reset();
            node=obj.rf.rst.lc.f.node;
            for it=1:node.ndnum
                [~,id]=node.nds.Get('index',it);
                xuhao=node.GetXuhaoByID(id);
                obj.displ.Append(id,vectro_u(xuhao:xuhao+5)');
                obj.force.Append(id,vector_f(xuhao:xuhao+5)');%��Ϊ֪���ڵ����������� ����ֱ��append����add
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
            
            %����
            switch type(1)
                case 'f'
                    tmp=obj.force.Get('id',id);
                    r=tmp(dir);
                case 'd'
                    tmp=obj.displ.Get('id',id);
                    r=tmp(dir);
                otherwise
                    error('matlab:myerror','δ֪���ɶ�')
            end
            
        end
%         function disp(obj)
%             disp(['�ڵ���֡' obj.framename])
%             disp(['���ڹ���' obj.nc.lc.name])
%             disp('��ӡ����Ϣ>>>>>>>>>>')
%             disp([sprintf('%10s','�ڵ�') sprintf('%10s%10s%10s%10s%10s%10s','fx','fy','fz','mx','my','mz')]);
%             for it=1:obj.force.num
%                 [ln,id]=obj.force.Get('index',it);
%                 disp([sprintf('%10d% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e',id,ln(1),ln(2),ln(3),ln(4),ln(5),ln(6))]);
%             end
%             disp('��ӡλ����Ϣ>>>>>>>>>>')
%             disp([sprintf('%10s','�ڵ�') sprintf('%10s%10s%10s%10s%10s%10s','ux','uy','uz','rx','ry','rz')]);
%             for it=1:obj.force.num
%                 [ln,id]=obj.displ.Get('index',it);
%                 disp([sprintf('%10d% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e% 10.2e',id,ln(1),ln(2),ln(3),ln(4),ln(5),ln(6))]);
%             end
%         end

    end
    methods(Access=private)
        function Reset(obj)%��ʼ��force��displ ����ô�С
            if obj.force.num~=0||obj.displ.num~=0
                warning('��ʼ���ڵ���ʱ�����нڵ���,��ȷ���Ƿ��쳣��')
            end
            
        end
    end

end
