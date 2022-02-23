function caxisauto(P)
alpha = 2;
minC = prctile(P(:),alpha);
maxC = prctile(P(:),100-alpha);
caxis([minC maxC]);