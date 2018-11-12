
classdef FEM3DFRAME <handle
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        node NODE
        manager_mat %材料管理器
        manager_sec %截面管理器
        manager_ele %单元管理器
        bc BC%边界条件


        
        
        K double%结构刚度矩阵 
        
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
        function LoadFormANSYS(obj,dbpath)%从ansys db文件中载入
            %dbpath是路径及文件名
            %思路是利用ansys打开这个文件 完成振型计算 输出节点和单元信息 
            %导入ansys
            
            ansysele='F:\ansys\eleinfo.txt';%ansys的节点单元文件默认保存路径
            ansysnd='F:\ansys\nodeinfo.txt';
            %根据模板制作ansys命令流
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
                if lnid==3%改写这一句
                    ln=['resume,' dbpath ',,,0'];
                end
                fprintf(fid1,'%s\r\n',ln);
            end
            fclose('all');
            %调用ansys
            order=['"D:\prosoftware\ansys19\ANSYS Inc\ANSYS Student\v190\ansys\bin\winx64\ANSYS190.exe" -b -i ' mycodepath ' -o f:\ansys\tes.out' ];
            system(order);
            %读取到fem中
            ndmt=ReadTxt(ansysnd,4,0);
            elemt=ReadTxt(ansysele,5,0);
            obj.node.LoadFromMatrix(ndmt(:,1:3));
            %载入单元时看清楚是3节点还是四节点
            if elemt(1,4)==elemt(1,5)%三边
                obj.element.LoadFromMatrix(elemt(:,2:end-1),'triangle',obj.mat.mats);
            else%4边
                obj.element.LoadFromMatrix(elemt(:,2:end),'quadrangle',obj.mat.mats);
            end
            
  
        end

        function K=GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            %形成节点与刚度矩阵的映射
            obj.node.nds_mapping=zeros(obj.node.ndnum,2);
            lastx=-5;
            for it=1:obj.node.ndnum
                obj.node.nds_mapping(it,1)=obj.node.nds(it,1);
                lastx=lastx+6;
                obj.node.nds_mapping(it,2)=lastx;
            end
            
            
            K=zeros(6*obj.node.ndnum,6*obj.node.ndnum);
            f=waitbar(0,'组装刚度矩阵','Name','FEM3DFRAME');
            for it=1:obj.manager_ele.num
                waitbar(it/obj.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.manager_ele.num)]);
                e=obj.manager_ele.objects(it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
        function Solve(obj)%调用此函数前 制定load和setf
            GetK(obj);
            %K1为引入边界条件的总刚度矩阵
            dof=size(obj.K,1);
            u=zeros(dof,1);
            
            %先处理位移边界
            df=zeros(dof,1);
            
            in=[];%存储不激活的自由度 位移限制的自由度
            for it=1:size(obj.bc.displ,1)
%                 index=2*(obj.bc.displ(it,1)-1)+obj.bc.displ(it,2);
                index=obj.node.GetXuhaoByID(obj.bc.displ(it,1))+obj.bc.displ(it,2)-1;%得到序号
                df=df-obj.K(:,index)*obj.bc.displ(it,3);
                u(index)=obj.bc.displ(it,3);%保存位移
                in=[in index];
            end
            activeindex=1:dof;
            activeindex(in)=[];
            
            %处理力边界条件
%             BC中的force是不包含0的力 这里需要对BC中力矩阵进行补充
            ft=zeros(dof,1);
            for it=1:size(obj.bc.force,1)
%                 index=2*(obj.bc.force(it,1)-1)+obj.bc.force(it,2);
                index=obj.node.GetXuhaoByID(obj.bc.force(it,1))+obj.bc.force(it,2)-1;
                ft(index)=ft(index)+obj.bc.force(it,3);
            end

            f1=ft+df;%
            
            %求解
            K1=obj.K(activeindex,activeindex);%简化方程组 去除一部分自由度
            u1=K1\f1(activeindex);
            
            %处理求解后所有自由度上的力和位移
            
            u(activeindex)=u1;
            f=obj.K*u;
            %把结果保存到node中
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

