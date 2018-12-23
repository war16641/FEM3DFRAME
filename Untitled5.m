dbstop if error
close all


f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,1,0,0);

m=1;

tmp=ELEMENT_MASS(f,0,2,[m m m 0 0 0]);
f.manager_ele.Add(tmp);


k1=9.8696;
tmp=ELEMENT_SPRING(f,0,[1 2],[k1 0 0 0 0 0]);
f.manager_ele.Add(tmp);






lc=LoadCase_Earthquake(f,'eq');
f.manager_lc.Add(lc);
lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0]);


ew=EarthquakWave.MakeConstant(0,20,0.4);
ei=EarthquakeInput(lc,'landers',ew,1,0);
lc.AddEarthquakeInput(ei);
lc.SetAlgorithm('newmark',0.5,0.25);
C1=[0.1*pi];
lc.damp.Set('matrix',C1);

lc.intd.Add([2 1 1]);

lc.Solve();
[u3,tn]=lc.rst.GetTimeHistory(0,40,'node','displ',2,1);
figure
plot(tn,u3)



