mv.out.detect = function(SR, PC){
  require(mvoutlier)
  require(doBy)
  
  rm.out = function(q.in, PC){
    PC1 = PC[q.in,]
    pc.outlier = aq.plot(PC1[,2:5])
    mv.out = pc.outlier$outliers
    q.in = names(mv.out)[which(mv.out==F)]
    q.out = names(mv.out)[which(mv.out==T)]
    n.out = length(q.out)
    return(list(q.in=q.in,n.out=n.out))
  }
  
  ID.REF = rownames(PC)[which(PC$SR==SR)]
  ID.GRP = rownames(PC)
  
  
  for(j in 1:4){
    qlim = range(PC[ID.REF,1+j])
    IDj = rownames(PC)[which(PC[,1+j] >= qlim[1] & PC[,1+j] <= qlim[2] )]
    ID.GRP = intersect(ID.GRP, IDj)
  }
  
  x = rm.out(ID.GRP,PC)
  n.out = x$n.out
  q.in = x$q.in
  
  while(n.out > 0){
    xj = rm.out(q.in,PC)
    n.out = xj$n.out
    q.in = xj$q.in
    print(n.out)
  }
  
  print(summaryBy(PC1~SR,PC[q.in,],FUN=length))
  
  return(q.in)
}

