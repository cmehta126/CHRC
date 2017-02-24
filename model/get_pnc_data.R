# Data
base_dir = "~/research/data/"
setwd(base_dir)
fn_pnc = "phs000607.v2.pht003445.v2.p2.c1.Neurodevelopmental_Genomics_Subject_Phenotypes.GRU-NPU.txt"
fn_gen_pca = "merged_PNC_imputed_snps_prune_01.eigenvec"
fn_roi = "PNC_roi_master.txt"

# Load pnc_data
pnc0 = read.table(fn_pnc,header = T,skip = 10,sep="\t")
pnc0$sid = as.character(pnc0$SUBJID)

# Load gen_pca
gen_pca = read.table(fn_gen_pca,header = F, col.names = c("fid","sid",paste("PC",1:20,sep="")))

# ROI
pnc_roi = read.table(fn_roi, header = T)




# Load variables from pnc0 ------------------------------------------------
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

# master id ---------------------------------------------------------------
id_master = unique(as.character(pnc0$sid))
pnc1 = data.frame(row.names = id_master)

# Load variables from pnc0 ------------------------------------------------
pnc1 = load_pnc_variables(pnc1, pnc0, "age_at_cnb", "age")
pnc1 = load_pnc_variables(pnc1, pnc0, "Sex", "sex",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Race", "sr_race",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Med_Rating", nname = "med_rating",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Med_birth_year", nname = "birth_year",make_factor = F)
pnc1 = load_pnc_variables(pnc1, pnc0, "TAP_HAND", nname = "birth_year",make_factor = F)



pnc1 = load_pnc_variables(pnc1, pnc0, "Mother_Education",make_factor = F)
pnc1 = load_pnc_variables(pnc1, pnc0, "Father_Education",make_factor = F)
pnc1$PE = apply(pnc1[,c("Father_Education","Mother_Education")],1,get_highest_education)


# Load variables from gen_pca ------------------------------------------------
pnc1 = load_pnc_variables(pnc1, gen_pca, vname = colnames(gen_pca)[grep("PC", colnames(gen_pca))])

# Load variables from roi ------------------------------------------------
v = c("total_area", "EstimatedTotalIntraCranialVol", "TotalGrayVol")
pnc1 = load_pnc_variables(pnc1, pnc_roi, vname = v)



# Model SES vs area -------------------------------------------------------
q = pnc1;

q$sexF = (q$sex == "F")*1
q$med_rating_q = as.numeric(q$med_rating)

#q = q[which(q$PC1 > 0.004 & q$PC2 < 0.01),]

mod.total_area = total_area ~ PE + age + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6
sfit = summary(fit <- lm(mod.total_area, q))
sfit$coefficients["PE",]; sum(sfit$df[1:2])

mod.TotalGrayVol = TotalGrayVol ~ PE + age + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6
sfit = summary(fit <- lm(mod.TotalGrayVol, q))
sfit$coefficients["PE",]; sum(sfit$df[1:2])

mod = TotalGrayVol ~ age + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6
sfit = summary(fit <- lm(mod, q, na.action = "na.exclude"))
cor.test(resid(fit), q$PE, use = "com")



