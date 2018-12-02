dbstop if error
close all

f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,0,0);

m=1;

tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
f.manager_ele.Add(tmp);


k=1;
tmp=ELEMENT_SPRING(f,0,[1 2],[k 0 0 0 0 0]);
f.manager_ele.Add(tmp);


lc1=LoadCase_Modal(f,'modal');
f.manager_lc.Add(lc1);
lc1.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);
lc1.Solve();
[~,pri]=lc1.rst.GetPeriodInfo();
w1=pri(3);

lcd=LoadCase_Static(f,'eq');
f.manager_lc.Add(lcd);
lcd.CloneBC(lc1);
lcd.AddBC('force',[2 1 1]);
lcd.Solve();


lc=LoadCase_Earthquake(f,'eq');
f.manager_lc.Add(lc);
lc.CloneBC(lcd);

 lc.intd.Add([2 1 1])



ew=EarthquakWave.MakeConstant(0,20,0.01);
ei=EarthquakeInput(lc,'const',ew,1,0);
lc.AddEarthquakeInput(ei);
lc.SetAlgorithm('newmark',0.5,0.25);
[a, b]=DAMPING.RayleighDamping(w1,5,0.005,0.005);

lc.damp.Set('rayleigh',a,b);
lc.Solve();
[vn,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
figure
plot(tn,vn)

%解析解
[v]=dsolve('D2y+0.01*Dy+y=1','Dy(0)=0','y(0)=1');
syms t
v_v=subs(v,t,[0:0.01:20]);
v_v=double(v_v);
hold on
plot(0:0.01:20,v_v,'o','markersize',2);
legend('fem','解析解')
er=norm(vn-v_v');

testcase.verifyTrue(er/2001<0.002,'验证错误');