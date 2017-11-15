#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=24000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

i=$1
snps=$2
cd /ysm-gpfs/home/cm953/scratch60/pnc/gen/final/_working
fn_vcf=/ysm-gpfs/home/cm953/project/data/1000GP_Phase3/ALL.chr${i}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz
~/project/bin/plink --vcf $fn_vcf --biallelic-only strict --extract $snps --make-bed --out tmp.chr${i}




