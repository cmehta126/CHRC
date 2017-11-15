#!/bin/bash
#SBATCH -p general
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 

plat=$1

cd /ysm-gpfs/home/cm953/scratch60/pnc/gen

echo "Platform ${plat[$k]}"

o1=extra/hi_info5_snps_${plat[$k]}.txt
o2=extra/hi_info7_snps_${plat[$k]}.txt

o0=extra/good_sites_${plat[$k]}.txt


[ -f $o1 ] && rm $o1
[ -f $o2 ] && rm $o2
[ -f $o0 ] && rm $o0
	
for ((i=1;i<=22;i++))
do
    echo "Chromosome $i"
    x=impute/${plat[$k]}/chr${i}/final_impute2/chr${i}.imputed.impute2_info
    y=impute/${plat[$k]}/chr${i}/final_impute2/chr${i}.imputed.good_sites
    awk '{ if (NR >1 && $7 >= 0.5) print $2}' $x | awk -F':' '{print $1}'  >> $o1
    awk '{ if (NR >1 && $7 >= 0.7) print $2}' $x | awk -F':' '{print $1}'  >> $o2
    awk -F':' '{print $1}' $y >> $o0
done

echo "Completed."
