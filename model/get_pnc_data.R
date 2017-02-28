require(car)

# Data
fn_functions = "~/project/chrc/model/functions.R"
fn_pnc = "~/project/data/phs000607.v2.pht003445.v2.p2.c1.Neurodevelopmental_Genomics_Subject_Phenotypes.GRU-NPU.txt"
fn_gen_pca = "~/project/pnc/gen/data/merged_PNC_imputed_snps_prune_01.eigenvec"
fn_roi = "~/project/data/PNC_roi_master.txt"

source(fn_functions)

# PNC Phenotypes file -----------------------------------------------------
pnc0 = read.table(fn_pnc,header = T,skip = 10,sep="\t")
pnc0$Subj = as.character(pnc0$SUBJID)

# master id ---------------------------------------------------------------
id_master = unique(as.character(pnc0$Subj))
pnc1 = data.frame(row.names = id_master, Subj = id_master)

# Load variables from pnc0 ------------------------------------------------
pnc1 = load_pnc_variables(pnc1, pnc0, "age_at_cnb", "age")
pnc1 = load_pnc_variables(pnc1, pnc0, "Sex", "sex",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Race", "sr_race",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Med_Rating", nname = "med_rating",make_factor = T)
pnc1 = load_pnc_variables(pnc1, pnc0, "Med_birth_year", nname = "birth_year",make_factor = F)
pnc1 = load_pnc_variables(pnc1, pnc0, "TAP_HAND", nname = "hand",make_factor = F)

pnc1 = load_pnc_variables(pnc1, pnc0, "Mother_Education",make_factor = F)
pnc1 = load_pnc_variables(pnc1, pnc0, "Father_Education",make_factor = F)
pnc1$PE = apply(pnc1[,c("Father_Education","Mother_Education")],1,get_highest_education)

# Load variables from gen_pca ------------------------------------------------
gen_pca = read.table(fn_gen_pca,header = F, col.names = c("fid","Subj",paste("PC",1:20,sep="")))
pnc1 = load_pnc_variables(pnc1, gen_pca, vname = colnames(gen_pca)[grep("PC", colnames(gen_pca))])

# Load polygenic scores ------------------------------------------------
pnc1 = load_pgs(pnc1, "EDU_inf", "~/project/pnc/gen/pgs/results/EDU_EGA_impute_LDpred-inf.txt")
pnc1 = load_pgs(pnc1, "SCZ_inf", "~/project/pnc/gen/pgs/results/SCZ_EGA_impute_LDpred-inf.txt")
pnc1 = load_pgs(pnc1, "AUT_inf", "~/project/pnc/gen/pgs/results/AUT_EGA_impute_LDpred-inf.txt")

pnc1 = load_pgs(pnc1, "EDU_p0.10", "~/project/pnc/gen/pgs/results/EDU_EGA_impute_LDpred_p1.0000e-01.txt")
pnc1 = load_pgs(pnc1, "SCZ_p0.10", "~/project/pnc/gen/pgs/results/SCZ_EGA_impute_LDpred_p1.0000e-01.txt")
pnc1 = load_pgs(pnc1, "AUT_p0.10", "~/project/pnc/gen/pgs/results/AUT_EGA_impute_LDpred_p1.0000e-01.txt")

# Designate genetic ancestry ----------------------------------------------
q = pnc1; q1 = pnc1$PC1; q2 = pnc1$PC5; plot(q1,q2,type ='n'); 
idx = which(q$sr_race!="AA" & q$sr_race != "EA"); points(q1[idx],q2[idx], pch = 17, col = 4)
idx = which(q$sr_race=="EA"); points(q1[idx],q2[idx], pch = 15, col = 2)
idx = which(q$sr_race=="AA"); points(q1[idx],q2[idx], pch = 16, col = 3)

pnc1$genetic_ancestry = "OT"
pnc1$genetic_ancestry[which(pnc1$PC1 > 0.005 & pnc1$PC2 < 0.00)] = "EGA"
pnc1$genetic_ancestry[which(pnc1$PC1 < -0.005 & pnc1$PC2 < 0.00)] = "AGA"
pnc1$genetic_ancestry = as.factor(pnc1$genetic_ancestry)

# Structural IMG ----------------------------------------------------------
id_study1 = as.character(read.table("~/project/data/ID.pnc_img_v1.txt", stringsAsFactors = F)$V1)
id_study2 = as.character(read.table("~/project/data/ID.pnc_img_v2.txt", stringsAsFactors = F)$V1)

pnc1$img_study_version = NA
pnc1[id_study1,"img_study_version"] = "V1"
pnc1[id_study2,"img_study_version"] = "V2"
pnc1$img_study_version = as.factor(pnc1$img_study_version)

pnc_roi = read.table(fn_roi, header = T)
v = c("total_area", "EstimatedTotalIntraCranialVol", "TotalGrayVol", "Left.Hippocampus")
pnc1 = load_pnc_variables(pnc1, pnc_roi, vname = v)

q = pnc1[which(!is.na(pnc1$img_study_version)),]
summary(q$genetic_ancestry)


# Print to file -----------------------------------------------------------

pnc2 = pnc1[which(!is.na(pnc1$img_study_version)),]
write.table(pnc2,"~/project/data/pnc_data_abbr.txt", row.names = F, col.names = T, quote = F)






# Model SES vs area -------------------------------------------------------
q = pnc1;
q$sexF = (q$sex == "F")*1
q$med_rating_q = as.numeric(q$med_rating)
q[which(q$img_study_version=="V2"),"age"] = q[which(q$img_study_version=="V2"),"age"] #+ 2
q$age2 = q$age^2

q$y = scale(q$TotalGrayVol)
q$ce = (q$PE >= 16)*1
qEA = q[which(q$genetic_ancestry=="EGA"),] 

source(fn_functions)
mod_pgs_ses_lin = y ~ age + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + PE + EDU_p0.10 #+ AUT_inf
fit = lm(mod_pgs_ses_lin, qEA)
summary(fit)$coefficients




qEA = q[which(q$genetic_ancestry == "EGA"),]
cor.test(qEA$SCZ_p0.10, qEA$PC3, use = 'comp')


linearHypothesis(fit, c("EDU_inf"))


#mod_noble = y ~ age + age2 + sexF + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + age*PE + EDU_inf
#h1 = run_model(mod_noble,q,"PE",model_summary = T)
h2 = run_model(mod_mehta,q,"PE", model_summary = T)
h3 = run_model(mod_mehta,q[which(q$genetic_ancestry=="EGA"),],"PE", model_summary = T)
#h4 = run_model(mod_mehta,q[which(q$PC1 < -0.005 & q$PC2 < 0 & q$age >= 8),],"PE", model_summary = T)



# add PING ----------------------------------------------------------------

ping0 = read.csv("PING-FULL.csv",header = T,row.names=1)
ping0$Subj = rownames(ping0)

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




