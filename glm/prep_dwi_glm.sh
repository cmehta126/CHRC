#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

cd ~/scratch60/glm
exp=$1
meas=$2

N=($(wc -l ${exp}_id.txt))
A=( $(cat ${exp}_id.txt) )
Nsub=$N #(grep NumSubjects d001_design.txt | awk '{ print $2 }')

if [ $N = $Nsub ]; then
   #fna=~/scratch60/glm/scripts/combine_3dTcat_${exp}-${meas}.sh
   fnmerge=~/scratch60/glm/scripts/fslmerge_${exp}-${meas}.sh

   #fnc=dwi/combine_${exp}-${meas}.sh
   #fnm=dwi/combine_${exp}_and_mask-${meas}.sh
   
   #printf "cd $SUBJECTS_DIR \n" > $fnc
   #printf "mri_concat " >> $fnc


   printf "cd $SUBJECTS_DIR \n" > $fnmerge
   printf "module load FSL; FSLDIR=/ysm-gpfs/apps/software/FSL/5.0.9-centos6_64; source ${FSLDIR}/etc/fslconf/fsl.sh; \n" >> $fnmerge
   printf "fslmerge -t ~/scratch60/glm/dwi/volumes-${exp}-${meas}-CVS.nii.gz " >> $fnmerge   

   #printf "cd $SUBJECTS_DIR \n" > $fna
   #printf "3dTcat " >> $fna
   
   for ((i=0;i<$N;i++)); do
     sub=${A[$i]}
     #printf "$sub/mri/dti/_${meas}-masked.ANAT+CVS-to-avg35.nii.gz " >> $fnc
     #printf "$sub/mri/dti/_${meas}-masked_ds.ANAT+CVS-to-avg35.nii.gz " >> $fna
     printf "$sub/mri/dti/_${meas}-masked_ds.ANAT+CVS-to-avg35.nii.gz " >> $fnmerge

   done
   #printf " -output ~/scratch60/glm/dwi/volumes-${exp}-${meas}-CVS.nii.gz -overwrite \n" >> $fna

   #cp $fnc $fnm
   #printf " --o ~/scratch60/glm/dwi/group-${exp}-${meas}-CVS.nii.gz \n" >> $fnc
   #printf " --o ~/scratch60/glm/dwi/group-masksum-${exp}-${meas}-CVS.nii.gz --mean \n" >> $fnm
   #printf "mri_binarize --i ~/scratch60/glm/dwi/group-masksum-${exp}-${meas}-CVS.nii.gz --min 0.999 --o ~/scratch60/glm/dwi/group-mask-${exp}-${meas}-CVS.nii.gz \n" >> $fnm

   sh $fnmerge
   echo 'good'
   3dinfo -n4 ~/scratch60/glm/dwi/volumes-${exp}-${meas}-CVS.nii.gz
else
   echo 'mismatch'
fi



















#sh $fna

#3dAutomask ~/scratch60/glm/dwi/volumes-${exp}-${meas}-CVS.nii.gz ~/scratch60/glm/dwi/volumes-${exp}-${meas}-CVS_mask.nii.gz

