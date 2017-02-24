
base_dir = "~/research/data/"
fn_functions = "~/research/chrc/model/functions.R"

source(fn_functions)
setwd(base_dir)


ping0 = read.csv("PING-FULL.csv",header = T,row.names=1)



vnames = c("Age_At_IMGExam","Gender", colnames(ping0)[grep("GAF", colnames(ping0))],"DeviceSerialNumber",
           "FDH_Highest_Education", "FDH_3_Household_Income","MRI_cort_area.ctx.total")
nnames = c("age", "sex", colnames(ping0)[grep("GAF", colnames(ping0))],"DeviceSerialNumber",
           "PE", "HI", "total_area")






vnames
L = ping0[,vnames]
colnames(L) = nnames
L$sexF = (L$sex=="F")*1
L$age2 = L$age^2

mod_noble = total_area ~ age + age2 + sexF + DeviceSerialNumber+ GAF_africa + GAF_amerind + GAF_eastAsia + GAF_oceania + GAF_centralAsia + age*PE
run_model(mod_noble,L,"PE")


L1 = L[which(L$age >= 12),]
mod = total_area ~ age + sexF + DeviceSerialNumber+ GAF_africa + GAF_amerind + GAF_eastAsia + GAF_oceania + GAF_centralAsia + PE*age
run_model(mod,L1,"PE")

mod = total_area ~ age + age2 + sexF + DeviceSerialNumber+ GAF_africa + GAF_amerind + GAF_eastAsia + GAF_oceania + GAF_centralAsia + age*HI
run_model(mod,L,"HI")


