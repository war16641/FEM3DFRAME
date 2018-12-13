classdef ELEMENT_SPRING<ELEMENT3DFRAME
    %弹簧单元
    
    properties
        xdir
        ydir
        zdir double %3个单位方向向量 均为行向量  x方向是 从i到j  z向在初始化是指定 y向根据xz推出(右手法则)
        const double %此单元的常数 1*6 double 刚度
        dir_nl double%非线性属性 列向量 自由度方向（局部坐标）
        prop_nl double%非线性属性  屈前刚度 屈服力 屈后刚度 屈服位移
        nlstate %非线性属状态结构体
%         dv_history_NR cell%牛顿拉普森迭代过程中产生的中间过程量
    end
    
    methods
        function obj = ELEMENT_SPRING(varargin)  
            %f     id      nds     const
            %f     id      nds     const    p
            obj=obj@ELEMENT3DFRAME(varargin{1},varargin{2},varargin{3});
            
            %取定默认参数
            if nargin==4
                obj.const=varargin{4};
                p=[];
            elseif nargin==5
                obj.const=varargin{4};
                p=varargin{5};
                
            else
                error('未知参数')  
            end
            
            %初始化方向
            ELEMENT_EULERBEAM.InitializeDir(obj,p);
        end
        
        function Kel = GetKel(obj)
%             %初始化有效自由度矩阵'
%             obj.hitbyele=zeros(2,6);
            
            %生成局部坐标下的单刚
            kx=obj.const(1);
            ky=obj.const(2);
            kz=obj.const(3);
            krx=obj.const(4);
            kry=obj.const(5);
            krz=obj.const(6);
            Kel_=[kx	0	0	0	0	0	-kx	0	0	0	0	0
                0	ky	0	0	0	0	0	-ky	0	0	0	0
                0	0	kz	0	0	0	0	0	-kz	0	0	0
                0	0	0	krx	0	0	0	0	0	-krx	0	0
                0	0	0	0	kry	0	0	0	0	0	-kry	0
                0	0	0	0	0	krz	0	0	0	0	0	-krz
                0	0	0	0	0	0	kx	0	0	0	0	0
                0	0	0	0	0	0	0	ky	0	0	0	0
                0	0	0	0	0	0	0	0	kz	0	0	0
                0	0	0	0	0	0	0	0	0	krx	0	0
                0	0	0	0	0	0	0	0	0	0	kry	0
                0	0	0	0	0	0	0	0	0	0	0	krz
                ];
            Kel_=MakeSymmetricMatrix(Kel_);%对称阵
            obj.Kel_=Kel_;
            
            %计算从局部坐标到总体坐标的转换矩阵C 3*3
            xd=[1 0 0];yd=[0 1 0];zd=[0 0 1];%总体坐标
            C=[dot(obj.xdir,xd)      dot(obj.xdir,yd)      dot(obj.xdir,zd)
               dot(obj.ydir,xd)      dot(obj.ydir,yd)      dot(obj.ydir,zd)
               dot(obj.zdir,xd)      dot(obj.zdir,yd)      dot(obj.zdir,zd)];
           C=[C zeros(3,3);zeros(3,3) C];
           obj.C66=C;%保存单节点的转换矩阵
           C=[C zeros(6,6);zeros(6,6) C];%扩充到12自由度
           
           %得到总体坐标下的单刚
           Kel=C^-1*Kel_*C;
           obj.Kel=Kel;
           
%            %计算有效自由度
%             dg=diag(Kel);
%             tmp=dg(1:6);
%             tmp=abs(tmp)>1e-10;
%             obj.hitbyele(1,tmp)=1;
%             tmp=dg(7:12);
%             tmp=abs(tmp)>1e-10;
%             obj.hitbyele(2,tmp)=1;
            
        end
        function K=FormK(obj,K)
            obj.GetKel();%先计算单刚矩阵 总体坐标
            K=obj.FormMatrix(K,obj.Kel);
            %将Kel拆为6*6的子矩阵送入总刚K
%             n=length(obj.nds);
%             for it1=1:n
%                 for it2=1:n
%                     x=obj.nds(it1);
%                     y=obj.nds(it2);
%                     xuhao1=obj.f.node.GetXuhaoByID(x);%得到 节点号对应于刚度矩阵的序号
%                     xuhao2=obj.f.node.GetXuhaoByID(y);
%                     K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)=K(xuhao1:xuhao1+5,xuhao2:xuhao2+5)+obj.Kel(6*it1-5:6*it1,6*it2-5:6*it2);
%                 end
%             end
        end

        function [force,deform,Eng]=GetEleResult(obj,varargin)
            %根据计算结果（节点位移） 计算单元力 变形
            %varargin 只输入两个节点ij的变形2*6 
            if length(varargin)~=1
                error('matlab:myerror','错误格式')
            end
            ui=varargin{1}(1,:);
            uj=varargin{1}(2,:);%两节点位移 总体坐标
            deform_global=uj-ui;%整体坐标系下的变形
            cli=obj.C66^-1;
            deform=deform_global*cli;
            ui_local=ui*cli;
            uj_local=uj*cli;%两节点位移 局部坐标
            tmp=obj.Kel_*[ui_local uj_local]';
            force=[tmp(1:6)';tmp(7:12)'];%转化为n*6形式
            %加上非线性的部分
            C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66];
            tmp=obj.Fsel'*C^-1;
            force=force+[tmp(1:6) ;tmp(7:12)];
            %能量
            Eng=[0 0 0];%势能动能耗能
            delta=[ui'; uj'];
            Eng(1)=0.5*delta'*obj.Kel*delta;
        end
        function Mel=GetMel(obj)
            
        end
        function M=FormM(obj,M)
            %此单元无质量
        end
        function SetNLProperty(obj,dir,prop)%设置非线性属性
            %prop只需输入前三个 第四个数自动计算算出
            if obj.flag_nl==0%未设置非线性
                obj.flag_nl=1;
            end
            
            obj.dir_nl=[obj.dir_nl ;dir];
            prop=[prop prop(2)/prop(1)];
            obj.prop_nl=[obj.prop_nl;prop];
            obj.const(dir)=0;%需要删除非线性自由度对应的线性刚度
            %初始化非线性状态
            tmp.ela=0;
            tmp.dumax=prop(4);
            tmp.dumin=-prop(4);
            tmp.fs=0;
            tmp.kt=0;
            tmp.dv_NRhistory=[];
            obj.nlstate=[obj.nlstate;tmp];%保存到类中
        end
        function [Fs,KT]=AddNRHistory(obj,varargin)
            %varargin是节点位移向量的增量
            %flag_fail 为1 时代表nr失败
            %Fs是节点对单元的力 只含非线性部分
            %Fs是单元在nr过程中刚度 只含非线性部分
            ui=varargin{1}(1:6);
            uj=varargin{1}(7:12);%两节点位移 总体坐标
            deform_global=uj-ui;%整体坐标系下的变形
            cli=obj.C66^-1;
            deform=deform_global'*cli;%局部变形的增量
            Fs=zeros(12,1);
            KT=zeros(12,12);
            flag_fail=0;
            for it=1:length(obj.dir_nl)
                dir=obj.dir_nl(it);
                dv=deform(dir);%变形增量
                
                %检查不收敛条件
                if isempty(obj.nlstate(it).dv_NRhistory)%第一次nr迭代
                    if obj.nlstate(it).ela==1%受拉塑性
                        delta_f=obj.prop_nl(it,3)*dv;%力增量
                        if delta_f<-2*obj.prop_nl(it,4)*obj.prop_nl(it,3)&&delta_f>2*obj.prop_nl(it,4)*(obj.prop_nl(it,3)-obj.prop_nl(it,1))
                            error('nr迭代：这种情况是nr迭代将在两个状态中来回切换。建议缩小步长')
                        end
                    end
                    if obj.nlstate(it).ela==-1%受压塑性
                        delta_f=obj.prop_nl(it,3)*dv;%力增量
                        if delta_f>2*obj.prop_nl(it,2)*obj.prop_nl(it,3)&&delta_f<-2*obj.prop_nl(it,4)*(obj.prop_nl(it,3)-obj.prop_nl(it,1))
                            error('nr迭代：这种情况是nr迭代将在两个状态中来回切换。建议缩小步长')
                        end
                    end
                end
                
                obj.nlstate(it).dv_NRhistory=[obj.nlstate(it).dv_NRhistory; [dv 0 0 0]];
                %计算fs和kt
                k1=obj.prop_nl(it,1);
                k2=obj.prop_nl(it,3);
                dvhe=sum(obj.nlstate(it).dv_NRhistory(:,1));%所有nr过程变形增量的和
                if dvhe>=obj.nlstate(it).dumax%进入受拉塑性
                    fs=obj.nlstate(it).fs+k1*obj.nlstate(it).dumax+k2*(dvhe-obj.nlstate(it).dumax);
                    kt=k2;
                    ela=1;
                elseif dvhe<=obj.nlstate(it).dumin%进入受拉塑性
                    fs=obj.nlstate(it).fs+k1*obj.nlstate(it).dumin+k2*(dvhe-obj.nlstate(it).dumin);
                    kt=k2;
                    ela=-1;
                else
                    fs=obj.nlstate(it).fs+dvhe*k1;
                    kt=k1;
                    ela=obj.nlstate(it).ela+dvhe/obj.prop_nl(it,4);
                end
                %保存fs kt到nrhistory中
                obj.nlstate(it).dv_NRhistory(end,2)=fs;
                obj.nlstate(it).dv_NRhistory(end,3)=kt;
                obj.nlstate(it).dv_NRhistory(end,4)=ela;
                %输出切线矩阵 只含线性 节点力
                Fs(dir)=-fs;
                Fs(dir+6)=fs;
                KT(dir,dir)=kt;
                KT(dir+6,dir+6)=kt;
                KT(dir+6,dir)=-kt;
                KT(dir,dir+6)=-kt;
                %转换到总体坐标
                C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
                KT=C^-1*KT*C;
                Fs=Fs'*C;
                Fs=Fs';
            end
        end
        function FinishNR(obj)%结束nr过程
%             Fs=zeros(12,1);
%             KT=zeros(12,12);
            for it=1:length(obj.dir_nl)
%                 dir=obj.dir_nl(it);
                %清除nrhistory信息
                obj.nlstate(it).dv_NRhistory=[];
%                 %将nr过程中最后一步载入到nlstate中
%                 if ~isempty(obj.nlstate(it).dv_NRhistory)
%                     obj.nlstate(it).fs=obj.nlstate(it).dv_NRhistory(end,2);
%                     obj.nlstate(it).kt=obj.nlstate(it).dv_NRhistory(end,3);
%                     obj.nlstate(it).ela=obj.nlstate(it).dv_NRhistory(end,4);
%                     %清除nrhistory信息
%                     obj.nlstate(it).dv_NRhistory=[];
%                 else%如果nrhistory为空 说明 这一步的荷载和上一步一样 什么都不用动
%                 end
%                 
%                 obj.nlstate(it).dumax=(1-obj.nlstate(it).ela)*obj.prop_nl(it,4);
%                 obj.nlstate(it).dumin=(-1-obj.nlstate(it).ela)*obj.prop_nl(it,4);
%                 
%                 %输出切线矩阵 只含线性 节点力
%                 fs=obj.nlstate(it).fs;
%                 kt=obj.nlstate(it).kt;
%                 Fs(dir)=-fs;
%                 Fs(dir+6)=fs;
%                 KT(dir,dir)=kt;
%                 KT(dir+6,dir+6)=kt;
%                 KT(dir+6,dir)=-kt;
%                 KT(dir,dir+6)=-kt;
%                 %转换到总体坐标
%                 C=[obj.C66 zeros(6,6); zeros(6,6) obj.C66];
%                 KT=C^-1*KT*C;
%                 Fs=Fs'*C;
%                 Fs=Fs';
            end
            %写入KTel Fsel
%             obj.Fsel=Fs;
%             obj.KTel=KT;
        end
        function [KTel,Fsel]=GetKT(obj)%计算非线性部分的的刚度矩阵
            KTel=obj.KTel;
            Fsel=obj.Fsel;
%             kt=zeros(12,12);
%             for it=1:length(obj.dir_nl)
%                 dir=obj.dir_nl(it);%自由度
%                 if obj.nlstate(it).ela==-1 || obj.nlstate(it).ela==1%屈服
%                     k=obj.prop_nl(it,3);%屈后刚度
%                 else
%                     k=obj.prop_nl(it,1);%屈前刚度
%                 end
%                 
%                 kt(dir,dir)=k;
%                 kt(dir+6,dir+6)=k;
%                 kt(dir,dir+6)=-k;
%                 kt(dir,dit+6)=-k;
%             end
%             %坐标转化
%             C=[obj.C66 zeros(6,6);obj.C66 zeros(6,6)];
%             KT=C^-1*kt*C;
        end
        function InitialKT(obj)%初始化KTel Fsel nlstate
            sz=length(obj.nds)*6;
            obj.Fsel=zeros(sz,1);%初始化的fsel为0
            kt=zeros(12,12);
            for it=1:length(obj.dir_nl)
                dir=obj.dir_nl(it);%自由度
                k=obj.prop_nl(it,1);
                kt(dir,dir)=k;
                kt(dir+6,dir+6)=k;
                kt(dir,dir+6)=-k;
                kt(dir+6,dir)=-k;
                %初始化nlstate
                obj.nlstate(it).ela=0;
                obj.nlstate(it).dumax=obj.prop_nl(it,4);
                obj.nlstate(it).dumin=-obj.prop_nl(it,4);
                obj.nlstate(it).fs=0;
                obj.nlstate(it).kt=obj.prop_nl(it,1);
                obj.nlstate(it).dv_NRhistory=[];
            end
            %坐标转化
            C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
            obj.KTel=C^-1*kt*C;
            
            
        end
        function SetState(obj,varargin)%更新单元状态
            %lc
            
            lc=varargin{1};
            [v,dv,ddv]=obj.GetMyNodeState(lc);
            ui=v(1:6);
            uj=v(7:12);%两节点位移 总体坐标
            deform_global=uj-ui;%整体坐标系下的变形
            cli=obj.C66^-1;
            C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
            tmp=deform_global'*cli;
            delta=tmp-obj.state.deform_;%变形的增量
            SetState@ELEMENT3DFRAME(obj,varargin);%先计算弹性的部分 
            
%             %计算变形
%             lc=varargin{1};
%             [v,dv,ddv]=obj.GetMyNodeState(lc);
%             ui=v(1:6);
%             uj=v(7:12);%两节点位移 总体坐标
%             deform_global=uj-ui;%整体坐标系下的变形
%             cli=obj.C66^-1;
%             C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
%             Cli=C^-1;
%             tmp=deform_global'*cli;
%             delta=tmp-obj.state.deform_;%变形的增量
%             obj.state.deform_=tmp;%局部坐标下的变形
%             
%             %计算弹性力
%             tmp=obj.Kel*v;%整体坐标下的力
%             obj.Fs_elastic=tmp;
%             tmp=tmp'*Cli;
%             fs_e=tmp';%局部坐标下
            
            %计算非线弹性的回复力

            Fs=zeros(12,1);
            KT=zeros(12,12);
            for it=1:length(obj.dir_nl)
                dir=obj.dir_nl(it);%自由度方向
                delta_v=delta(dir);%这个自由度方向上变形的增量
                k1=obj.prop_nl(it,1);
                k2=obj.prop_nl(it,3);
                if delta_v>=obj.nlstate(it).dumax%进入受拉塑性
                    fs=obj.nlstate(it).fs+k1*obj.nlstate(it).dumax+k2*(delta_v-obj.nlstate(it).dumax);
                    kt=k2;
                    ela=1;
                elseif delta_v<=obj.nlstate(it).dumin%进入受拉塑性
                    fs=obj.nlstate(it).fs+k1*obj.nlstate(it).dumin+k2*(delta_v-obj.nlstate(it).dumin);
                    kt=k2;
                    ela=-1;
                else
                    fs=obj.nlstate(it).fs+delta_v*k1;
                    kt=k1;
                    ela=obj.nlstate(it).ela+delta_v/obj.prop_nl(it,4);
                end
                %输出切线矩阵 只含线性 节点力
                Fs(dir)=-fs;
                Fs(dir+6)=fs;
                KT(dir,dir)=kt;
                KT(dir+6,dir+6)=kt;
                KT(dir+6,dir)=-kt;
                KT(dir,dir+6)=-kt;
                %更新nlstate
                obj.nlstate(it).ela=ela;
                obj.nlstate(it).dumax=(1-obj.nlstate(it).ela)*obj.prop_nl(it,4);
                obj.nlstate(it).dumin=(-1-obj.nlstate(it).ela)*obj.prop_nl(it,4);
                obj.nlstate(it).fs=fs;
                obj.nlstate(it).kt=kt;
            end
            %保存 非线弹性力和刚度
            obj.KTel_=KT;
            obj.Fsel_=Fs;
            
            obj.KTel=C^-1*KT*C;
            tmp=Fs'*C;
            obj.Fsel=tmp';
            
            %合并两个力
            tmp=obj.Fs_elastic_+obj.Fsel_;
            obj.state.force_=[tmp(1:6)';tmp(7:12)'];
            
%             %计算能量
%             obj.state.eng(1)=0.5*v'*obj.Kel*v;
%             obj.state.eng(2)=0;
%             obj.state.eng(3)=0;
            
        end
        function InitialState(obj)
            InitialState@ELEMENT3DFRAME(obj);
            
            %处理自己非线性的部分 非线性刚度矩阵
            obj.KTel=zeros(12,12); 
            for it=1:length(obj.dir_nl)
                dir=obj.dir_nl(it);%自由度
                k=obj.prop_nl(it,1);
                obj.KTel(dir,dir)=k;
                obj.KTel(dir+6,dir+6)=k;
                obj.KTel(dir,dir+6)=-k;
                obj.KTel(dir+6,dir)=-k;
                %初始化nlstate
                obj.nlstate(it).ela=0;
                obj.nlstate(it).dumax=obj.prop_nl(it,4);
                obj.nlstate(it).dumin=-obj.prop_nl(it,4);
                obj.nlstate(it).fs=0;
                obj.nlstate(it).kt=obj.prop_nl(it,1);
                obj.nlstate(it).dv_NRhistory=[];
            end
            %坐标转化
            C=[obj.C66 zeros(6,6);zeros(6,6) obj.C66 ];
            obj.KTel=C^-1*obj.KTel*C;
        end
    end
end

