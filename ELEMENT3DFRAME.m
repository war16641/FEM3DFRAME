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
        KTel_
        Fsel%非线性的回复力
        Fsel_
        Fs_elastic%弹性回复力
        Fs_elastic_
        C66 double %坐标转换矩阵 针对单个节点的
        hitbyele double%自由度是否被单元击中  有些单元的自由度并未激活 如桁架单元 有杆端弯矩释放的梁单元 格式为节点个数*6
        flag_nl%标识这个单元是否是非线性默 认是线性的0
        arg%计算中间量
        
        state%单元状态 （变形 节点力 能量） 由loadcase的setstate操作 可用于后处理
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
            obj.Mel=zeros(6*length(nds),6*length(nds));%默认质量矩阵为零
            %初始化单元状态
            obj.state.deform_=zeros(1,6);%局部坐标变形
            obj.state.force_=zeros(length(obj.nds)*6,1);%节点对单元的力 局部坐标
            obj.state.eng=[0 0 0];%势能 动能 滞回耗能
            
            obj.Fs_elastic=zeros(length(obj.nds)*6,1);
            obj.Fs_elastic_=zeros(length(obj.nds)*6,1);

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
        function [v,dv,ddv]=GetMyNodeState(obj,lc)%从lc的节点状态中获取单元的节点位移 速度 加速度向量 总体坐标
            v=zeros(6*length(obj.nds),1);
            dv=v;
            ddv=v;
            for it=1:length(obj.nds)
                ndid=obj.nds(it);
                xh=obj.f.node.GetXuhaoByID(ndid);%得到 节点号对应于刚度矩阵的序号
                v(6*it-5:6*it)=lc.u(xh:xh+5);
                dv(6*it-5:6*it)=lc.du(xh:xh+5);
                ddv(6*it-5:6*it)=lc.ddu(xh:xh+5);
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
        function SetState(obj,varargin)%设置单元的状态
            %lc
            
            varargin=Hull(varargin);
            lc=varargin{1};
            [v,dv,ddv]=obj.GetMyNodeState(lc);
            if length(obj.nds)==1%单节点单元
                obj.state.deform_=[0 0 0 0 0 0];%无变形
                obj.state.force_=[0 0 0 0 0 0];%无节点对单元的力
                obj.state.eng([1 3])=0;
                obj.state.eng(2)=0.5*dv'*obj.Mel*dv;%有动能
            elseif length(obj.nds)==2%两节点单元
                %计算变形
                ui=v(1:6);
                uj=v(7:12);%两节点位移 总体坐标
                deform_global=uj-ui;%整体坐标系下的变形
                cli=obj.C66^-1;
                C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
                Cli=C^-1;
                tmp=deform_global'*cli;
%                 delta=obj.state.deform_-tmp;%变形的增量
                obj.state.deform_=tmp;%局部坐标下的变形
                
                %计算弹性力
                tmp=obj.Kel*v;%整体坐标下的力
                obj.Fs_elastic=tmp;
                tmp=tmp'*Cli;
                obj.Fs_elastic_=tmp';
                obj.state.force_=[tmp(1:6);tmp(7:12)];
                
                %计算能量
                obj.state.eng(1)=0.5*v'*obj.Kel*v;
                obj.state.eng(2)=0.5*dv'*obj.Mel*dv;%有动能
                obj.state.eng(3)=0;
            else
                error('sd')
            end
        end
        function SetState_VelAcc(obj,lc)%由lc的SetState_VelAcc调用
            [~,dv,~]=obj.GetMyNodeState(lc);
            if length(obj.nds)==1%单节点单元
                obj.state.eng([1 3])=0;
                obj.state.eng(2)=0.5*dv'*obj.Mel*dv;%有动能
            elseif length(obj.nds)==2%两节点单元
                obj.state.eng(2)=0.5*dv'*obj.Mel*dv;%有动能
                obj.state.eng(3)=0;
            else
                error('sd')
            end
        end
        function InitialState(obj)%初始化单元状态 非线性状态也会初始化
            obj.state.deform_=zeros(1,6);%局部坐标变形
            obj.state.force_=zeros(length(obj.nds)*6,1);%节点对单元的力 局部坐标
            obj.state.eng=[0 0 0];%势能 动能 滞回耗能
            obj.Fs_elastic=zeros(length(obj.nds)*6,1);
            obj.Fs_elastic_=zeros(length(obj.nds)*6,1);
            obj.Fsel=zeros(length(obj.nds)*6,1);
            obj.Fsel_=zeros(length(obj.nds)*6,1);
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

