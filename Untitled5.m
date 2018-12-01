dbstop if error
close all

f=FEM3DFRAME();
f.node.AddByCartesian(1,0,0,0);
f.node.AddByCartesian(2,0,0,1.2);
tmp=ELEMENT_SPRING(f,0,[1 2],[1.15 0.8 0 0 0 0]);
tmp.SetNLProperty(1,[1 1 0.1]);
f.manager_ele.Add(tmp);

lc=LoadCase_Static(f,'dead');
f.manager_lc.Add(lc);


lc.AddBC('displ',[1 1 0;1 2 0;1 3 0;1 4 0;1 5 0;1 6 0;]);
lc.AddBC('force',[2 3 1.5]);

lc.Solve();
lc.rst.Get('node','displ',2,3)
lc.rst.Get('ele','force',1,'i','all')
