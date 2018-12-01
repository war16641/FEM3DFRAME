
classdef FEM3DFRAME <handle
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        node NODE
        manager_mat %材料管理器
        manager_sec %截面管理器
        manager_ele %单元管理器
        manager_lc %工况管理器

        flag_nl%标识这个工况是否是非线性默 认是线性的0
        
        
        K double%结构刚度矩阵 
        
    end
    
    methods
        function obj = FEM3DFRAME()
            obj.node=NODE(obj);
            obj.manager_mat=HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED('MATERIAL','name');
            obj.manager_sec=HCM.HANDLE_CLASS_MANAGER_UNIQUE_SORTED('SECTION','name');
            obj.manager_ele=ELEMENT_MANAGER();
            obj.manager_lc=HCM.HANDLE_CLASS_MANAGER_UNIQUE('LoadCase','name');
            obj.flag_nl=0;
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


                
    end
end

