
classdef FEM3DFRAME <handle
    %UNTITLED3 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        node NODE
        manager_mat %���Ϲ�����
        manager_sec %���������
        manager_ele %��Ԫ������
        bc BC%�߽�����


        
        
        K double%�ṹ�նȾ��� 
        
    end
    
    methods
        function obj = FEM3DFRAME()
            obj.node=NODE(obj);
            obj.manager_mat=HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED('MATERIAL','name');
            obj.manager_sec=HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED('SECTION','name');
            obj.manager_ele=ELEMENT_MANAGER('ELEMENT3DFRAME','id');
            obj.bc=BC(obj);
        end
        

        function LoadFromMatrix(obj,nodeinfo,eleinfo,et)
            for it=1:size(nodeinfo,1)
                obj.AddNode(nodeinfo(it,2),nodeinfo(it,3));
            end
            for it=1:size(eleinfo,1)
                obj.AddEle(et,[eleinfo(it,2) eleinfo(it,3) eleinfo(it,4) ]);
            end
        end
        function LoadFormANSYS(obj,dbpath)%��ansys db�ļ�������
            %dbpath��·�����ļ���
            %˼·������ansys������ļ� ������ͼ��� ����ڵ�͵�Ԫ��Ϣ 
            %����ansys
            
            ansysele='F:\ansys\eleinfo.txt';%ansys�Ľڵ㵥Ԫ�ļ�Ĭ�ϱ���·��
            ansysnd='F:\ansys\nodeinfo.txt';
            %����ģ������ansys������
            fid=fopen('template.txt','r');
            mycodepath='F:\ansys\ansyscodebyFEM2D.txt';
            fid1=fopen(mycodepath,'w');
            lnid=0;
            while(1)
                ln=fgetl(fid);
                lnid=lnid+1;
                if isempty(ln)
                    continue;
                end
                if ln==-1
                    break;
                end
                if lnid==3%��д��һ��
                    ln=['resume,' dbpath ',,,0'];
                end
                fprintf(fid1,'%s\r\n',ln);
            end
            fclose('all');
            %����ansys
            order=['"D:\prosoftware\ansys19\ANSYS Inc\ANSYS Student\v190\ansys\bin\winx64\ANSYS190.exe" -b -i ' mycodepath ' -o f:\ansys\tes.out' ];
            system(order);
            %��ȡ��fem��
            ndmt=ReadTxt(ansysnd,4,0);
            elemt=ReadTxt(ansysele,5,0);
            obj.node.LoadFromMatrix(ndmt(:,1:3));
            %���뵥Ԫʱ�������3�ڵ㻹���Ľڵ�
            if elemt(1,4)==elemt(1,5)%����
                obj.element.LoadFromMatrix(elemt(:,2:end-1),'triangle',obj.mat.mats);
            else%4��
                obj.element.LoadFromMatrix(elemt(:,2:end),'quadrangle',obj.mat.mats);
            end
            
  
        end

        function K=GetK(obj)
            %K���ܸնȾ���(�߽���������ǰ) ����Ϊ6*�ڵ����
            
            %�γɽڵ���նȾ����ӳ��
            obj.node.nds_mapping=zeros(obj.node.ndnum,2);
            lastx=-5;
            for it=1:obj.node.ndnum
                obj.node.nds_mapping(it,1)=obj.node.nds(it,1);
                lastx=lastx+6;
                obj.node.nds_mapping(it,2)=lastx;
            end
            
            
            K=zeros(6*obj.node.ndnum,6*obj.node.ndnum);
            f=waitbar(0,'��װ�նȾ���','Name','FEM3DFRAME');
            for it=1:obj.manager_ele.num
                waitbar(it/obj.manager_ele.num,f,['��װ�նȾ���' num2str(it) '/' num2str(obj.manager_ele.num)]);
                e=obj.manager_ele.objects(it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
        function Solve(obj)%���ô˺���ǰ �ƶ�load��setf
            GetK(obj);
            %K1Ϊ����߽��������ܸնȾ���
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %�ȴ���λ�Ʊ߽�
            df=zeros(dof,1);
            
            in=[];%�洢����������ɶ� λ�����Ƶ����ɶ�
            for it=1:size(obj.bc.displ,1)
%                 index=2*(obj.bc.displ(it,1)-1)+obj.bc.displ(it,2);
                index=obj.node.GetXuhaoByID(obj.bc.displ(it,1))+obj.bc.displ(it,2)-1;%�õ����
                df=df-obj.K(:,index)*obj.bc.displ(it,3);
                u(index)=obj.bc.displ(it,3);%����λ��
                in=[in index];
            end
            activeindex=1:dof;
            activeindex(in)=[];
            
            %�������߽�����
%             BC�е�force�ǲ�����0���� ������Ҫ��BC����������в���
            ft=zeros(dof,1);
            for it=1:size(obj.bc.force,1)
%                 index=2*(obj.bc.force(it,1)-1)+obj.bc.force(it,2);
                index=obj.node.GetXuhaoByID(obj.bc.force(it,1))+obj.bc.force(it,2)-1;
                ft(index)=ft(index)+obj.bc.force(it,3);
            end

            f1=ft+df;%
            
            %���
            K1=obj.K(activeindex,activeindex);%�򻯷����� ȥ��һ�������ɶ�
            u1=K1\f1(activeindex);
            
            %���������������ɶ��ϵ�����λ��
            
            u(activeindex)=u1;
            f=obj.K*u;
            %�ѽ�����浽node��
            obj.node.nds_displ=zeros(obj.node.ndnum,7);
            for it=1:obj.node.ndnum
                id=obj.node.nds(it,1);
                xuhao=obj.node.GetXuhaoByID(id);
                obj.node.nds_displ(it,1)=id;
                obj.node.nds_displ(it,2:7)=[u(xuhao:xuhao+5)]';
            end
            
            obj.node.nds_force=zeros(obj.node.ndnum,7);
            for it=1:obj.node.ndnum
                id=obj.node.nds(it,1);
                xuhao=obj.node.GetXuhaoByID(id);
                obj.node.nds_force(it,1)=id;
                obj.node.nds_force(it,2:7)=[f(xuhao:xuhao+5)]';
            end
        end


                
    end
end

