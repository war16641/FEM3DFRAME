classdef ELEMENT3DFRAME <handle & matlab.mixin.Heterogeneous
    %3d框架模型的抽象基类
    
    properties
        f FEM3DFRAME%模型指针        
        id double%单元编号
        nds%存储有限元中的节点号 
        ndcoor%存储节点坐标
        Kel double%单刚矩阵 总体坐标下
        Kel_ double%单刚矩阵 局部坐标下
        Mel double%单元质量矩阵
        Mel_ double
        KTel%非线性结构刚度矩阵
        Fsel%非线性的回复力
        C66 double %坐标转换矩阵 针对单个节点的
        hitbyele double%自由度是否被单元击中  有些单元的自由度并未激活 如桁架单元 有杆端弯矩释放的梁单元 格式为节点个数*6
        flag_nl%标识这个单元是否是非线性默 认是线性的0
        arg%计算中间量
    end
    
    methods
        function obj = ELEMENT3DFRAME(f,id,nds)
            %如果id为0 使用最大编号+1
            if 0==id
                id=f.manager_ele.maxnum+1;
            end
            
            %检查nds中是否所有节点存在
            for it=nds
                if false==f.node.IsExist(it)
                    error('MATLAB:myerror','节点不存在');
                end
            end
            
            
            obj.f=f;
            obj.id=id;
            obj.nds=nds;
            obj.ndcoor=[];%在开始计算单元刚度时载入坐标
            obj.flag_nl=0;%默认是线性的
            tmp=length(nds);
            obj.KTel=zeros(6*tmp,6*tmp);
            obj.Fsel=zeros(6*tmp,1);
            %初始化有效自由度矩阵
            obj.hitbyele=zeros(length(obj.nds),6);

        end
        function set.flag_nl(obj,v)
            obj.flag_nl=v;
            if v==1
            obj.f.flag_nl=v;
            end
        end
        function mat_tar=FormMatrix(obj,mat_tar,mat)%将单元的某某矩阵mat送入mat_tar
            n=length(obj.nds);
            for it1=1:n
                for it2=1:n
                    x=obj.nds(it1);
                    y=obj.nds(it2);
                    xuhao1=obj.f.node.GetXuhaoByID(x);%得到 节点号对应于刚度矩阵的序号
                    xuhao2=obj.f.node.GetXuhaoByID(y);
                    mat_tar(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=mat_tar(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+mat(6*it1-5:6*it1,6*it2-5:6*it2);
                end
            end
        end
        function vec_tar=FormVector(obj,vec_tar,vec)
            n=length(obj.nds);
            for it=1:n
                xh=obj.f.node.GetXuhaoByID(obj.nds(it));%得到 节点号对应于刚度矩阵的序号
                vec_tar(xh:xh+5)=vec_tar(xh:xh+5)+vec(6*it-5:6*it);
            end
        end
        function vec_i=GetMyVec(obj,vec,lc)%从总体的向量中获取自己的向量
            %vec是加入边界条件后的
            
            %补充vec至引入边界条件前
            v=zeros(lc.dof,1);
            v(lc.activeindex)=vec;
            n=length(obj.nds);
            vec_i=zeros(n*6,1);
            for it=1:n
                ndid=obj.nds(it);
                xh=obj.f.node.GetXuhaoByID(ndid);%得到 节点号对应于刚度矩阵的序号
                vec_i(6*it-5:6*it)=v(xh:xh+5);
            end
        end
        function CalcHitbyele(obj)%计算自由度是否被单元击中
            %请在计算了弹性刚度矩阵Kel和KTel后调用这个函数
            %问题：如果kel没有某个自由度的刚度，而ktel在开始时也没刚度但是后面会产生刚度
            %可能会导致程序在开始阶段直接认为此自由度为dead
            
            
            %计算有效自由度 Kel
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
        Kel = GetKel(obj)%形成自己的单元矩阵
        Mel=GetMel(obj);%组装单元质量阵
        K=FormK(obj,K)%K为结构的刚度矩阵 将自己单元的矩阵送入结构
        M=FormM(obj,M)
        InitialKT(obj)%初始化KTel Fsel
        [force,deform]=GetEleResult(obj,varargin)%根据结果计算单元的力和变形 force是单元内部力（局部坐标系下,节点对单元的力） deform是单元变形（局部坐标） 
    end
end

