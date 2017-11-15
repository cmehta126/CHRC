#!/usr/bin/env Rscript
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=10000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
args = commandArgs(trailingOnly=TRUE)

group = args[1]
subbrick = args[2]
model = args[3]

# ALL
# contrast_20#0_Tstat
# age+sex+PC1+PC2+PC3+PC4+PC5+PC6+PE



# Read in subricks
#system("ls ~/project/pnc/mri/subjects/*/*.BOLD_nback/stats.*_REML+tlrc.BRIK > ~/tmp/a.txt")
x = read.table("~/project/pnc/model/nback/files_nback_stats.txt", header = F, stringsAsFactors = F);
colnames(x) = "task"
x$Subj = substr(x$task, 47, 58)
rownames(x) = x$Subj
#task_files = data.frame(row.names = substr(x, 47, 58), task_files = gsub(".BRIK","",x), stringsAsFactors = F)
print(head(x))

# Read data table.
pnc = read.table("~/project/data/pnc_data_abbr.txt", sep = "\t", header = T)
rownames(pnc) = pnc$Subj
vn = c("Subj", unlist(strsplit(model, "\\+")))

# intersect
o = intersect(rownames(pnc), rownames(x))

# subset and add variable ***
y = pnc[o, vn]

# subset on genetic ancestry?
if(group == "EGA"){
  y = y[which(y$genetic_ancestry == "EGA"),]
}else if(group == "AGA"){
  y = y[which(y$genetic_ancestry == "AGA"),]
}

# Add column for InputFile
o = intersect(rownames(y), rownames(x))
z = x[o,]
y = y[o,]
#zo =  paste(z[o,"task_files"],"'[", subbrick, "]'", sep = "")
print(head(z))
#y$InputFile = z$InputFile

y = na.omit(y)

fn_out = paste("~/project/pnc/model/nback/dataFile_afni.", 
               group, ".", 
               subbrick, ".",
               model, ".txt",
               sep = "")
write.table(file = fn_out)






