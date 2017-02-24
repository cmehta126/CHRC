
load_pnc_variables = function(x1, x0, vname, nname = vname, make_factor = F){
  z0 = x0[,c("sid", vname)]
  
  if(length(vname) == 1){
    z1 = z0[which(!is.na(z0[,vname])),]
    z1 = z1[which(!duplicated(z1[,"sid"])),]
  }else{
    z1 = na.omit(z0[,c("sid", vname)])
    z1 = z1[which(!duplicated(z1[,"sid"])),]
  }
  
  
  rownames(z1) = z1$sid
  id1 = intersect(rownames(x1), rownames(z1))
  x1[,nname] = NA
  
  if(make_factor){
    x1[id1,nname] = as.character(z1[id1, vname])
    x1[,nname] = as.factor(x1[,nname])
  }else{
    x1[id1,nname] = z1[id1, vname]
  }
  
  rm(x0, vname, nname, z0, z1)
  return(x1)
}

get_highest_education = function(s){
  if(sum(is.na(s))==length(s)){
    out = NA
  }else{
    out = max(s,na.rm=T)
  }
  return(out)
}

run_model = function(mod,Q,test_var){
  require(car)
  sfit = summary(fit <- lm(mod, Q, na.action = "na.exclude")); 
  v = names(fit$coefficients)[grep(test_var, names(fit$coefficients))];
  a = c(sfit$coefficients[v,c(1,4)])
  names(a)[1:length(v)] = paste("estimate",v,sep=".")
  names(a)[1:length(v)+length(v)] = paste("pvalue",v,sep=".")
  lh = linearHypothesis(fit, v)$Pr[2]
  out = c(n=sum(sfit$df[1:2]),a, pvalue.joint=lh)
  return(out)
}
