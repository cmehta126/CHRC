cd ~/scratch60/glm/


#exp=e005
#meas=axialdiff; 

awk '{print NF}' file | sort -nu | tail -n 1

con=c10_5; exp=d005
fwhm=5; 

meas=fa; exp=d005; con=c10_5; fwhm=5; nsim=100;

m0=( axialdiff radialdiff adc )


con=c8_3; exp=d005;
module load FSL; 
source /ysm-gpfs/apps/software/FSL/5.0.9-centos6_64/etc/fslconf/fsl.sh
Text2Vest ${con}.txt ${con}.con
Text2Vest ${con}_F.txt ${con}.fts
Text2Vest ${exp}_design.txt ${exp}_design.mat


$code/glm/parallel_glm_dwi.sh


m0=( fa radialdiff adc )
for meas in ${m0[@]}; do
  nsim=1000; con=c8_3; fwhm=5; exp=d005
  for ((j=1;j<5;j++)); do
    fnout=~/scratch60/glm/output/${meas}-${exp}-${con}-${j}.out 
    sbatch --output=$fnout -J ${j}-${meas} $code/glm/parallel_glm_dwi.sh $meas $exp $fwhm $con $nsim $j 
  done
done




module load FSL; 
source /ysm-gpfs/apps/software/FSL/5.0.9-centos6_64/etc/fslconf/fsl.sh
Text2Vest ${con}.txt ${con}.con
Text2Vest ${exp}_design.txt ${exp}_design.mat

[ -f ${con}_F.txt  ] && Text2Vest ${con}_F.txt ${con}.fts
Text2Vest ${exp}_design.txt ${exp}_design.mat

design=$exp; 
cd /ysm-gpfs/home/cm953/scratch60/glm
emdf=_${exp}_${meas}_fwhm${fwhm}_Design_${design}_Con_${con}
[ -d _${emdf} ] && rm -rf $emdf
nsim=100
base=/ysm-gpfs/home/cm953/scratch60/glm
#Text2Vest ${con}.txt ${con}.con
em=${exp}-${meas}
 
indir=${base}/dwi
outdir=${base}/results/fsl${emdf}
[ -d $outdir ] && rm -rf $outdir
[ ! -d $outdir ] && mkdir $outdir
invol=${indir}/volumes-${em}-CVS_fwhm${fwhm}.nii.gz
mask=${indir}/volumes-${em}-CVS_mask.nii.gz
outvol=${outdir}/${emdf}

echo $outvol

[ -f ${con}.fts ] && randomise -i $invol -o $outvol -d ${design}_design.mat -t ${con}.con -f ${con}.fts -m $mask -T -c 2.5 -F 6.0 -N -R  -n $nsim -x --glm_output

[ ! -f ${con}.fts ] && randomise -i $invol -o $outvol -d ${design}_design.mat -t ${con}.con -m $mask -T -c 2.5  -N -R  -n $nsim -x --glm_output
