#!/bin/bash
#SBATCH -N 1 -c 1 -p general --mem-per-cpu=48000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
exp=$1; meas=$2

cd /ysm-gpfs/home/cm953/scratch60/glm
[ -d _${exp}_${meas} ] && rm -rf _${exp}_${meas}
#mri_glmfit --y dwi/volumes-${exp}-${meas}-CVS.nii.gz --fwhm 5 --mask dwi/volumes-${exp}-${meas}-CVS_mask.nii.gz --X ${exp}_design.txt --C m8_age.mat \
#   --C m8_Ftest_PE1_intx.mat --C m8_PE1_intx.mat --C m8_PE1_main.mat --glmdir _${exp}_${meas}
#

exp=$1
meas=$2
nsim=5000

em=${exp}-${meas}
module load FSL

echo $FSLDIR
echo $em
source  ${FSLDIR}/etc/fslconf/fsl.sh
invol=volumes-${em}-CVS_sm.nii.gz

Con=c1_PE_main.con
Text2Vest c1_PE_main.txt $Con


invol=dwi/volumes-${em}-CVS_sm.nii.gz
mask=dwi/volumes-${em}-CVS_mask.nii.gz
outvol=results/fsl-${em}

randomise -i $invol -o $outvol -d ${exp}_design.mat -t $Con -m $mask -T -c 2.5 -N -R  -n $nsim -x --glm_output



