#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=40000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

cd /ysm-gpfs/home/cm953/scratch60/pnc/gen
name=$1

[ ! -d extra/_${name} ] && mkdir extra/_${name}

cd extra/_${name}

# Merge with observed SNPs
SNPS=$2
~/project/impute/bin/plink_linux --bfile full_${name} --maf 0.01 --attrib $SNPS --make-bed --out imputed_${name}

mv imputed_${name}* ../../final/

echo "DONE"

