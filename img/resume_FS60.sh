#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

SID=$1
FN_NIFTI=~/scratch60/data/nifti/${SID}.T1.nii
PWD_FSURF_SUBJECT=$PNC_SUBJECTS

source ~/.bashrc

#### Run FreeSurfer.
#echo $SID >> /ysm-gpfs/home/cm953/project/pnc/mri/batch/began_freesurfer.txt
echo "Beginning FreeSurfer for $SID"
#recon-all -make all -s $SID -qcache
#recon-all -i $FN_NIFTI -subjid $SID -all -3T -qcache -norandomness -sd $SUBJECTS_DIR -parallel 
recon-all -make all -s $SID -all -3T -qcache -norandomness -sd $SUBJECTS_DIR
#recon-all -make qcache -s $SID -all -3T -qcache -norandomness -sd $SUBJECTS_DIR

m=$SUBJECTS_DIR/${SID}
bw=( 0 5 10 15 20 25 )
for ((b=0;b<6;b++))
do
  #recon-all -s $m -hemi lh -qcache -measure area.pial -fwhm ${bw[$b]} -target fsaverage
  #recon-all -s $m -hemi rh -qcache -measure area.pial -fwhm ${bw[$b]} -target fsaverage
done




#create ventricle and white matter masks
#import SUMA files to AFNI, in NIFTI format

#echo ${PWD_FSURF_SUBJECT}/${SID} 
cd ${PWD_FSURF_SUBJECT}/${SID}
#eval "pwd"

#@SUMA_Make_Spec_FS -sid ${SID} -NIFTI
#3dcalc -a SUMA/aparc+aseg.nii -datum byte -prefix SUMA/${SID}_vent.nii -expr 'amongst(a,4,43)'
#3dcalc -a SUMA/aparc+aseg.nii -datum byte -prefix SUMA/${SID}_WM.nii -expr 'amongst(a,2,7,16,41,46,251,252,253,254,255)'
#
#ls SUMA/${SID}_vent.nii; C1=$?; 
#ls SUMA/${SID}_WM.nii; C2=$?
#
#if (($C1==0 & $C2==0)); then
#	echo $SID >> /ysm-gpfs/scratch60/cm953/pnc/status/complete_suma.txt
#else
#	echo $SID >> /ysm-gpfs/scratch60/cm953/pnc/status/incomplete_suma.txt
#fi
#
#echo "Complete."
