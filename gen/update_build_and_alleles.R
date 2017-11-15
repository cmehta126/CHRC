#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
k = as.numeric(args[1])
require(fastmatch)
x = read.table('/ysm-gpfs/home/cm953/scratch60/pnc/gen/stats/folder_id.txt', header = F, stringsAsFactors = F);
setwd("/SAY/standard/Neonatology-726014-MYSM/pnc_from_dbGAP/GenotypeFiles");
setwd(x[k,1])

bbf = paste(x[k,2], c("bed", "bim", "fam"), sep = ".")
system(paste("cp ", bbf[1], " /ysm-gpfs/home/cm953/scratch60/pnc/gen/orig_data/temp_", bbf[1], sep = ""))
system(paste("cp ", bbf[2], " /ysm-gpfs/home/cm953/scratch60/pnc/gen/orig_data/temp_", bbf[2], sep = ""))
system(paste("cp ", bbf[3], " /ysm-gpfs/home/cm953/scratch60/pnc/gen/orig_data/temp_", bbf[3], sep = ""))

# Load Bim File
setwd('/ysm-gpfs/home/cm953/scratch60/pnc/gen/build_files')
fn_ua = paste(x[k,3], ".update_alleles.txt", sep = "")
fn_strand = paste(x[k,3], "-b37.strand", sep = "")
fn_multiple = paste(x[k,3], "-b37.multiple", sep = "")
fn_bim = paste("/ysm-gpfs/home/cm953/scratch60/pnc/gen/orig_data/temp_", bbf[2], sep = "")


bim = read.table(fn_bim, header = F, col.names = c("chr", "snp", "cM", "pos", "A1", "A2"), stringsAsFactors = F)
ua = read.table(fn_ua, header = F, col.names = c("snp", "O1", "O2", "U1", "U2"), stringsAsFactors = F)
strand = read.table(fn_strand, header = F, col.names = c("snp", "chr", "pos", "cM", "strand", "geno"), stringsAsFactors = F)


rownames(bim) = bim$snp
rownames(ua) = ua$snp
rownames(strand) = strand$snp

bim0 = bim


ua[,c("chr", "pos", "cM", "strand", "geno")] = "0"

q = intersect(rownames(ua), rownames(strand))
ua[fmatch(q, rownames(ua)), c("chr", "pos", "cM", "strand", "geno")] = strand[fmatch(q, rownames(strand)), c("chr", "pos", "cM", "strand", "geno")]

# AT/TA
oix = rownames(ua)[union(which(ua$U1 == "A" & ua$U2 == "T"), which(ua$U1 == "T" & ua$U2 == "A"))]
pix = intersect(oix, rownames(ua)[which(ua$strand == "+")])
ua[fmatch(pix, rownames(ua)), "U1"] = "A"
ua[fmatch(pix, rownames(ua)), "U2"] = "T"

pix = intersect(oix, rownames(ua)[which(ua$strand == "-")])
ua[fmatch(pix, rownames(ua)), "U1"] = "T"
ua[fmatch(pix, rownames(ua)), "U2"] = "A"

# CG/GC
oix = rownames(ua)[union(which(ua$U1 == "C" & ua$U2 == "G"), which(ua$U1 == "G" & ua$U2 == "C"))]
pix = intersect(oix, rownames(ua)[which(ua$strand == "+")])
ua[fmatch(pix, rownames(ua)), "U1"] = "C"
ua[fmatch(pix, rownames(ua)), "U2"] = "G"

pix = intersect(oix, rownames(ua)[which(ua$strand == "-")])
ua[fmatch(pix, rownames(ua)), "U1"] = "G"
ua[fmatch(pix, rownames(ua)), "U2"] = "C"

# Update BIM file.
r = intersect(rownames(bim), rownames(ua))

ua = ua[fmatch(rownames(bim), rownames(ua)), ]
mean(rownames(ua) == rownames(bim))
bim$A1[which(bim$A1 == 1)] = ua$U1[which(bim$A1 == 1)]
bim$A1[which(bim$A1 == 2)] = ua$U2[which(bim$A1 == 2)]
bim$A2[which(bim$A2 == 1)] = ua$U1[which(bim$A2 == 1)]
bim$A2[which(bim$A2 == 2)] = ua$U2[which(bim$A2 == 2)]

write.table(bim, fn_bim, col.names = F, row.names = F, quote = F, sep = "\t")

setwd("/ysm-gpfs/home/cm953/scratch60/pnc/gen/orig_data/");


a = paste("temp_", x[k, 2], sep = "")
a2 = paste("temp2_", x[k, 2], sep = "")
b = paste("top_", x[k, 2], sep = "")


amulti = paste("../build_files/", x[k,3], "-b37.multiple", sep = "")
amiss = paste("../build_files/", x[k,3], "-b37.miss", sep = "")

sp1 = paste("plink --bfile ", a, " --exclude ", amulti, " --make-bed --out ", a2)
sp2 = paste("plink --bfile ", a2, " --exclude ", amiss, " --make-bed --out ", b)

system(sp1)
system(sp2)

print(b)






