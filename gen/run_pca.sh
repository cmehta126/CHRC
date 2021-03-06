#!/bin/bash
#SBATCH -p general -N 1 -c 16 --mem-per-cpu=2500 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

cd /ysm-gpfs/home/cm953/scratch60/pnc/gen/final

# Prune
plink --bfile $1 --geno 0.05 --maf 0.05 --indep-pairwise 50 5 0.1 --out _working/prune_${1}

# Subset to pruned:
plink --bfile $1 --extract _working/prune_${1}.prune.in --make-bed --out _working/prune_${1}
# PCA
plink --threads 16 --bfile _working/prune_${1} --pca 20 --out pca_prune_${1}


