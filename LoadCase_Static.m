classdef LoadCase_Static<LoadCase
    %UNTITLED3 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        
    end
    
    methods
        function obj = LoadCase_Static(f,name)
            obj=obj@LoadCase(f,name);
        end
        function Solve(obj)

            obj.PreSolve();
            %判断工况是线性的还是非线性的
            if obj.f.flag_nl==0%线性结构
                %求解
                u1=obj.K1\obj.f_node1;
                
                %处理求解后所有自由度上的力和位移
                obj.SetState(u1);
                
                %把结果保存到noderst
                %static工况只有一个名为static的非时间结果
                obj.rst.AddByState('static','nontime');

                
                %初始化结果指针
                obj.rst.SetPointer();
            else%非线性结构
                %检查是否存在位移边界条件
                obj.CheckBC1();
                u_all=obj.Script_NR(obj,obj.f_node1);
                
                %保存到lc中
                obj.SetState(u_all(obj.activeindex));
                
                %保存结果
                obj.rst.AddByState('static','nontime');
                
%                 obj.u=u_all;
%                 %计算弹性部分力
%                 f=obj.K*obj.u;
%                 %把结果保存到rst
%                 %static工况只有一个名为static的非时间结果
%                 obj.rst.AddNontime('static',f,obj.u);
                
                %初始化结果指针
                obj.rst.SetPointer();

            end


        end
        

        function GetK(obj)
            %K是总刚度矩阵(边界条件处理前) 阶数为6*节点个数
            
            

            
            
            K=zeros(6*obj.f.node.ndnum,6*obj.f.node.ndnum);
            f=waitbar(0,'组装刚度矩阵','Name','FEM3DFRAME');
            for it=1:obj.f.manager_ele.num
                waitbar(it/obj.f.manager_ele.num,f,['组装刚度矩阵' num2str(it) '/' num2str(obj.f.manager_ele.num)]);
                e=obj.f.manager_ele.Get('index',it);
                obj.K=e.FormK(K);
                K=obj.K;
                
            end
            close(f);
        end
        function CheckBC(obj)
            %静力工况对bc无额外要求
            return;
        end
        function CheckBC1(obj)%非线性工况需要这个bc条件
            %要求位移边界条件全是0
            for it=1:obj.bc.displ.num
                ln=obj.bc.displ.Get('index',it);
                if ln(3)~=0
                    error('nyh:error','非弹性工况不能出现位移不为0的边界条件')
                end
            end
        end
        function GetM(obj)
            %静力工况不需要M
            obj.M=zeros(obj.dof,obj.dof);
        end
    end
    methods(Static)
        %带输出的
%         function [u_all]=Script_NR(obj,fn1,Kadd)%NR迭代过程
%             %fn1指定外荷载 有效自由度
%             %Kadd附加矩阵
%             if nargin==2
%                 Kadd=zeros(length(obj.activeindex),length(obj.activeindex));%不指定时 取0
%             end
%             %u是位移向量 全自由度
%             j=1;%迭代次数
%             maxj=500;%最大迭代次数
%             u=obj.u(obj.activeindex);
%             tol=1e-4;
%             Fs_n=zeros(obj.dof,1);
%             KT=zeros(obj.dof,obj.dof);
% 
% %             norm_f1=norm(obj.f_node1);%f1范数
%             norm_f1=norm(fn1);%f1范数
%             if norm_f1<tol%当荷载为0时
%                 norm_f1=tol;%为了能计算相对误差norm(f_unbalance)/norm_f1 取荷载为一个较小数
%             end
%             %求起始Fs_n和KT
%             for it=1:obj.f.manager_ele.num
%                 e=obj.f.manager_ele.Get('index',it);
%                 if e.flag_nl==0%线性单元
%                     continue;
%                 end
%                 KT=e.FormMatrix(KT,e.KTel);
%                 Fs_n=e.FormVector(Fs_n,e.Fsel);
%             end
%             
%             Fs_n1=Fs_n(obj.activeindex);%有效ziyoudu
%             fig=figure;
%             
%             plot(u(1),Fs_n1(1),'+')
%             hold on;
%             xlast=u;
%             ylast=Fs_n1;
%             while 1
%                 disp('____________________________________________________________')
%                 disp([num2str(j) '次迭代开始'])
%                 KT1=KT(obj.activeindex,obj.activeindex);
%                 Fs_n1=Fs_n(obj.activeindex);%有效ziyoudu
%                 disp('切向刚度')
%                 KT1
%                 disp('非线性回复力')
%                 Fs_n1
%                 f_unbalance=fn1-(obj.K1+Kadd)*u-Fs_n1;%不平衡力
%                 plot([xlast(1) u(1)],[ylast(1) Fs_n1(1)],'r-o');
%                 xlast=u;
%                 ylast=Fs_n1;
%                 disp('不平衡力');
%                 f_unbalance
%                 
%                 
%                 %检查是否满足误差条件
%                 if norm(f_unbalance)/norm_f1<tol%收敛
%                     %结束nr状态
%                     for it=1:obj.f.manager_ele.num
%                         e=obj.f.manager_ele.Get('index',it);
%                         if e.flag_nl==0%线性单元
%                             continue;
%                         end
%                         e.FinishNR();
%                         
%                     end
%                     close(fig)
%                     %输出节点位移
%                     u_all=obj.u_beforesolve;
%                     u_all(obj.activeindex)=u;
%                     
%                     break;
%                 end
%                 %检查是否已经达到最大迭代次数
%                 if j>=maxj
%                     error('nyh:error','已经达到最大NR次数')
%                 end
%                 %不收敛
%                 du=(obj.K1+Kadd+KT1)^-1*f_unbalance;%增量
%                 disp('位移增量')
%                 du
%                 u=u+du;
%                 disp('假设位移')
%                 u
%                 %重置
%                 Fs_n=zeros(obj.dof,1);
%                 KT=zeros(obj.dof,obj.dof);
%                 
%                 %将增量写入到各个非线性单元中
%                 for it=1:obj.f.manager_ele.num
%                     e=obj.f.manager_ele.Get('index',it);
%                     if e.flag_nl==0%线性单元
%                         continue;
%                     end
%                     
%                     duel=e.GetMyVec(du,obj);
%                     [Fsel,KTel]=e.AddNRHistory(duel);
% 
%                     Fs_n=e.FormVector(Fs_n,Fsel);
%                     KT=e.FormMatrix(KT,KTel);
%                     
%                 end
%                 j=j+1;%迭代次数加1
%                 
%                 
%             end
%         end
        function [u_all]=Script_NR(obj,fn1,Kadd)%NR迭代过程
            %fn1指定外荷载 有效自由度
            %Kadd附加矩阵
            if nargin==2
                Kadd=zeros(length(obj.activeindex),length(obj.activeindex));%不指定时 取0
            end
            %u是位移向量 全自由度
            j=1;%迭代次数
            maxj=500;%最大迭代次数
            u=obj.u(obj.activeindex);
            tol=1e-4;
            Fs_n=zeros(obj.dof,1);
            KT=zeros(obj.dof,obj.dof);
            norm_f1=norm(fn1);%f1范数
            if norm_f1<tol%当荷载为0时
                norm_f1=tol;%为了能计算相对误差norm(f_unbalance)/norm_f1 取荷载为一个较小数
            end
            %求起始Fs_n和KT
            for it=1:obj.f.manager_ele.num
                e=obj.f.manager_ele.Get('index',it);
                if e.flag_nl==0%线性单元
                    continue;
                end
                KT=e.FormMatrix(KT,e.KTel);
                Fs_n=e.FormVector(Fs_n,e.Fsel);
            end
            
            Fs_n1=Fs_n(obj.activeindex);%有效ziyoudu
%             fig=figure;
            
%             plot(u(1),Fs_n1(1),'+')
%             hold on;
%             xlast=u;
%             ylast=Fs_n1;
            while 1
%                 disp('____________________________________________________________')
%                 disp([num2str(j) '次迭代开始'])
                KT1=KT(obj.activeindex,obj.activeindex);
                Fs_n1=Fs_n(obj.activeindex);%有效ziyoudu
%                 disp('切向刚度')
%                 KT1
%                 disp('非线性回复力')
%                 Fs_n1
                f_unbalance=fn1-(obj.K1+Kadd)*u-Fs_n1;%不平衡力
%                 plot([xlast(1) u(1)],[ylast(1) Fs_n1(1)],'r-o');
%                 xlast=u;
%                 ylast=Fs_n1;
%                 disp('不平衡力');
%                 f_unbalance
                
                
                %检查是否满足误差条件
                if norm(f_unbalance)/norm_f1<tol%收敛
                    %结束nr状态
                    for it=1:obj.f.manager_ele.num
                        e=obj.f.manager_ele.Get('index',it);
                        if e.flag_nl==0%线性单元
                            continue;
                        end
                        e.FinishNR();
                        
                    end
%                     close(fig)
                    %输出节点位移
                    u_all=obj.u_beforesolve;
                    u_all(obj.activeindex)=u;
                    
                    break;
                end
                %检查是否已经达到最大迭代次数
                if j>=maxj
                    error('nyh:error','已经达到最大NR次数')
                end
                %不收敛
                du=(obj.K1+Kadd+KT1)^-1*f_unbalance;%增量
%                 disp('位移增量')
%                 du
                u=u+du;
%                 disp('假设位移')
%                 u
                %重置
                Fs_n=zeros(obj.dof,1);
                KT=zeros(obj.dof,obj.dof);
                
                %将增量写入到各个非线性单元中
                for it=1:obj.f.manager_ele.num
                    e=obj.f.manager_ele.Get('index',it);
                    if e.flag_nl==0%线性单元
                        continue;
                    end
                    
                    duel=e.GetMyVec(du,obj);
                    [Fsel,KTel]=e.AddNRHistory(duel);

                    Fs_n=e.FormVector(Fs_n,Fsel);
                    KT=e.FormMatrix(KT,KTel);
                    
                end
                j=j+1;%迭代次数加1
                
                
            end
        end
    end
end

