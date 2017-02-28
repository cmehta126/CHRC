require(car)

# Data
fn_functions = "~/research/chrc/model/functions.R"
base_dir = "~/research/data/"
fn_pnc = "phs000607.v2.pht003445.v2.p2.c1.Neurodevelopmental_Genomics_Subject_Phenotypes.GRU-NPU.txt"
fn_gen_pca = "merged_PNC_imputed_snps_prune_01.eigenvec"
fn_roi = "PNC_roi_master.txt"


source(fn_functions)
setwd(base_dir)

# Load pnc_data
pnc0 = read.table(fn_pnc,header = T,skip = 10,sep="\t")
pnc0$sid = as.character(pnc0$SUBJID)

# Load gen_pca
gen_pca = read.table(fn_gen_pca,header = F, col.names = c("fid","sid",paste("PC",1:20,sep="")))

# ROI
pnc_roi = read.table(fn_roi, header = T)

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
v = c("total_area", "EstimatedTotalIntraCranialVol", "TotalGrayVol", "Left.Hippocampus", "Right.Hippocampus")
pnc1 = load_pnc_variables(pnc1, pnc_roi, vname = v)

id_study1 = as.character(read.table("ID.pnc_img_v1.txt", stringsAsFactors = F)$V1)
id_study2 = as.character(read.table("ID.pnc_img_v2.txt", stringsAsFactors = F)$V1)

pnc1$img_study_version = NA
pnc1[id_study1,"img_study_version"] = "V1"
pnc1[id_study2,"img_study_version"] = "V2"
pnc1$img_study_version = as.factor(pnc1$img_study_version)

# Model SES vs area -------------------------------------------------------

q = pnc1;
q$sexF = (q$sex == "F")*1
q$med_rating_q = as.numeric(q$med_rating)
q[which(q$img_study_version=="V2"),"age"] = q[which(q$img_study_version=="V2"),"age"] + 2
q$age2 = q$age^2


q$y = scale(q$Left.Hippocampus)

source(fn_functions)
mod_mehta = y ~ age + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PE
mod_noble = y ~ age + age2 + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + age*PE

h1 = run_model(mod_noble,q,"PE",model_summary = T)
h2 = run_model(mod_mehta,q,"PE", model_summary = T)
h3 = run_model(mod_mehta,q[which(q$PC1 > 0 & q$PC2 < 0 & q$age >= 8),],"PE", model_summary = T)
h4 = run_model(mod_mehta,q[which(q$PC1 < -0.005 & q$PC2 < 0 & q$age >= 8),],"PE", model_summary = T)

#




# add PING ----------------------------------------------------------------

ping0 = read.csv("PING-FULL.csv",header = T,row.names=1)
ping0$sid = rownames(ping0)

vnames = c("Age_At_IMGExam","Gender", colnames(ping0)[grep("GAF", colnames(ping0))],"DeviceSerialNumber",
           "FDH_Highest_Education", "FDH_3_Household_Income","MRI_cort_area.ctx.total")
nnames = c("age", "sex", colnames(ping0)[grep("GAF", colnames(ping0))],"DeviceSerialNumber",
           "PE", "HI", "total_area")

ping1 = data.frame(row.names = rownames(ping0))
for(j in 1:length(vnames)){
  ping1 = load_pnc_variables(ping1, ping0, vnames[j], nnames[j])
}

ping1 = load_pnc_variables(ping1, gen_pca, vname = colnames(gen_pca)[grep("PC", colnames(gen_pca))])
ping1$sexF = (ping1$sex=="F")*1

q$y = q$total_area
mod = y ~ age + age2 + age*PE + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6
run_model(mod,q,"PE")
run_model(mod,q[which(q$PC1 > 0 & q$PC2 < 0 & q$age >= 8),],"PE")



keep_v = c("age", "PE", "sexF", paste("PC",1:6,sep=""),"DeviceSerialNumber","total_area")
q$DeviceSerialNumber = "pnc"
m = rbind(q[,keep_v],ping1[,keep_v])
m$age2 = m$age^2
m$DeviceSerialNumber = as.factor(m$DeviceSerialNumber)

mod_noble = total_area ~ age + age2 + sexF + DeviceSerialNumber+ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + age*PE
sfit = summary(fit <- lm(mod_noble,m,na.action = "na.exclude"))
sfit; sum(sfit$df[-3])

mod = total_area ~ age + age2 + sexF + DeviceSerialNumber+ PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PE*age
sfit = summary(fit <- lm(mod,m[which(m$age >= 0),],na.action = "na.exclude"))
linearHypothesis(fit, c("PE", "age:PE"))$Pr[2]




