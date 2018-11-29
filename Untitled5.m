dbstop if error
close all
order=2;
f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,0,0);
f.node.AddByCartesian(3,2,0,0);
f.node.AddByCartesian(4,3,0,0);
m=267e3;

tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
f.manager_ele.Add(tmp);
tmp=ELEMENT_MASS(f,0,3,[m m m 0 0 0]);
f.manager_ele.Add(tmp);
tmp=ELEMENT_MASS(f,0,4,[m m m 0 0 0]);
f.manager_ele.Add(tmp);

k=1.75e9;
tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
f.manager_ele.Add(tmp);
tmp=ELEMENT_SPRING(f,0,[2 3],[k 0 0 0 0 0]);
f.manager_ele.Add(tmp);
tmp=ELEMENT_SPRING(f,0,[3 4],[k 0 0 0 0 0]);
f.manager_ele.Add(tmp);

lc1=LoadCase_Modal(f,'modal');
f.manager_lc.Add(lc1);
lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
lc1.Solve();
[~,pri]=lc1.rst.GetPeriodInfo();
w1=pri(3);
lc1.rst.SetPointer(order);
[~,pri]=lc1.rst.GetPeriodInfo();
w2=pri(3);



lc=LoadCase_Earthquake(f,'eq');
f.manager_lc.Add(lc);
lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);

% ew=EarthquakWave();
% ew.LoadFromFile('landers','g','F:\TOB\地震波\Landers.txt','time&acc',0);


ew=EarthquakWave.MakeConstant(0,5,0.002);
ei=EarthquakeInput(lc,'landers',ew,1,0);
lc.AddEarthquakeInput(ei);
lc.SetAlgorithm('newmark',0.5,0.25);
[a, b]=DAMPING.RayleighDamping(w1,w2,0.05,0.05);
lc.damp.Set('rayleigh',0,0);
%初位移
u1=lc1.rst.Get('node','displ',2,1);
u2=lc1.rst.Get('node','displ',3,1);
u3=lc1.rst.Get('node','displ',4,1);
lc.intd.Add([2 1 u1; 3 1 u2;4 1 u3]);
lc.Solve();
[vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
figure
plot(tn,vn)
[vn,tn]=lc.rst.GetTimeHistory(0,40,'eng');
t=sum(vn,2);
vn=[vn t];
figure
plot(tn,vn);
title('能量')
legend('势能','动能','耗能','总能量')
%计算模态坐标
md=lc.MakeModalDispl(lc1);
[t,YY,eng]=md.PlotData();
% testcase.verifyTrue(t(order)/sum(t)>0.99,'验证错误');
% testcase.verifyTrue(norm(vn(:,1)'-eng(end,:))<0.0001,'验证错误');
