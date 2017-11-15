#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=40000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

cd /ysm-gpfs/home/cm953/scratch60/pnc/gen
name=$1


[ ! -d extra/_${name} ] && mkdir extra/_${name}

q=()
fn_sample=impute/${name}/chr1/final_impute2/chr1.imputed.sample
fn_impute=extra/_${name}/all_imputed_autosomes_${name}.impute2

[ -f $fn_impute ] && rm $fn_impute

echo "Combining imputation results on chromosomes"
for i in {1..22}
do
	fni=impute/${name}/chr$i/final_impute2/chr${i}.imputed.impute2
	echo "adding $fni"
	cat $fni > $fn_impute
	~/project/impute/bin/plink_linux --gen $fn_impute --sample $fn_sample --snps-only --make-bed --out extra/_${name}/tmp_chr${i}
	rm $fn_impute
	#q+=($fni)
done

#cat "${q[@]}" > $fn_impute
echo "Completed extracting imputed genotypes for each chromosome of ${name} and now running PLINK to combine format."
#~/project/impute/bin/plink_linux --gen $fn_impute --sample $fn_sample --snps-only --make-bed --out extra/_${name}/tmp_v1_${name}
#rm $fn_impute

cd extra/_${name}

cat tmp_chr1.fam > tmp_v0_${name}.fam
for chr in {1..22} 
do 
	cat tmp_chr${chr}.bim; 
done > tmp_v0_${name}.bim

(echo -en "\x6C\x1B\x01"; for chr in {1..22}; do tail -c +4 tmp_chr${chr}.bed; done) > tmp_v0_${name}.bed
plink --bfile tmp_v0_${name} --make-bed --out tmp_v1_${name}	

#rm tmp_chr*


# Restricting to RS IDs
cut -f2 tmp_v1_${name}.bim | grep 'rs' > tmp_u1_${name}.txt
~/project/impute/bin/plink_linux --bfile tmp_v1_${name} --attrib tmp_u1_${name}.txt --make-bed --out tmp_v2_${name}

# Updating variant names
paste -d' ' <(cat tmp_u1_${name}.txt) <(cut -d ':' -f1 tmp_u1_${name}.txt) > tmp_u2_${name}.txt
~/project/impute/bin/plink_linux --bfile tmp_v2_${name} --update-map tmp_u2_${name}.txt --update-name --make-bed  --out tmp_v3_${name}

# Identify duplicates (for removal)
cut -f2 tmp_v3_${name}.bim > tmp_s0_${name}.txt
sort tmp_s0_${name}.txt > tmp_s00_${name}.txt
uniq -d tmp_s00_${name}.txt > tmp_s1_${name}.txt
~/project/impute/bin/plink_linux --bfile tmp_v3_${name} --exclude tmp_s1_${name}.txt --make-bed  --out full_${name}

# Merge with observed SNPs
SNPS=$2
~/project/impute/bin/plink_linux --bfile full_${name} --attrib $SNPS --make-bed --out imputed_${name}

mv imputed_${name}* ../../final/

rm tmp*.bed
rm tmp*.bim

echo "DONE"

