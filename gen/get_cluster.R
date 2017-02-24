#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
fn.pca = args[1]
fn.ref = args[2]
fn.out = args[3]

source("~/project/code/fun_get_cluster.R")
ref_table = read.table(fn.ref, header=T, stringsAsFactors=F)
rownames(ref_table) = ref_table$ID

cn =  c("FID", "IID", paste("PC",1:20,sep=""))
pca_table = read.table(fn.pca, header = F, col.names = cn, stringsAsFactors=F);
rownames(pca_table) = pca_table$IID


pca_table$SR = "-"
pca_table[rownames(ref_table),"SR"] = ref_table[,"GROUP"]
pca1 = pca_table[,c("SR",cn[-c(1,2)])]

ID_EUR = mv.out.detect("EUR", pca1)
#ID_AFR = mv.out.detect("AFR", pca1)

x = pca_table[ID_EUR,1:2]
write.table(x, row.names = F, col.names = F, quote = F, file = fn.out)

