#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=40000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

merge_data ()
{
	cp ../${1}.bed  M.bed
	cp ../${1}.bim  M.bim
	cp ../${1}.fam  M.fam

	cp ../${2}.bed  N.bed
	cp ../${2}.bim  N.bim
	cp ../${2}.fam  N.fam

	plink --bfile N --attrib $3 --make-bed --out A
	plink --bfile M --bmerge A.bed A.bim A.fam --snps-only --biallelic-only --make-bed --out B
        plink --bfile M --exclude B-merge.missnp --snps-only --biallelic-only --make-bed --out U
        plink --bfile A --exclude B-merge.missnp --snps-only --biallelic-only --make-bed --out V
	plink --bfile U --bmerge A.bed A.bim A.fam --snps-only --biallelic-only --make-bed --out ../${1}
	return 0
}


cd /ysm-gpfs/home/cm953/scratch60/pnc/gen/final
plink --bfile $2 --make-bed --snps-only --biallelic-only strict --out $1 #--attrib $3 --out $1

[ ! -d _working ] && mkdir _working
cd _working


plat=(pnc_610 pnc_550_v3 pnc_omni pnc_550_v1 pnc_1MDuo pnc_axiom pnc_axiomTx pnc_affy60)
 

for ((i=0;i<8;i++))
do
    fn=imputed_${plat[$i]}
    merge_data $1 $fn $3
    printf "\n\n completed $fn"
done
















