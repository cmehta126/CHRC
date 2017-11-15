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
#recon-all -make all -s $SID -all -3T -qcache -norandomness -sd $SUBJECTS_DIR

recon-all -make qcache -s $SID -all -3T -qcache -norandomness -sd $SUBJECTS_DIR


#meas=( area area.pial curv jacobian_white sulc thickness volume w-g.pct.mgh white.H white.K )
#meas=( area area.pial thickness volume )

d=$SUBJECTS_DIR/${SID}
bwa=( 0 5 10 15 20 25 )
for ((j=0;j<6;j++))
do
  b=${bwa[$j]}
  recon-all -s $d -hemi lh -qcache -measure area.pial -fwhm $b -target fsaverage
  recon-all -s $d -hemi rh -qcache -measure area.pial -fwhm $b -target fsaverage
done







#lh.area.fwhm10.fsaverage.mgh       lh.jacobian_white.fwhm10.fsaverage.mgh  lh.volume.fwhm10.fsaverage.mgh       lh.white.K.fwhm10.fsaverage.mgh
#lh.area.pial.fwhm10.fsaverage.mgh  lh.sulc.fwhm10.fsaverage.mgh            lh.w-g.pct.mgh.fwhm10.fsaverage.mgh
#lh.curv.fwhm10.fsaverage.mgh       lh.thickness.fwhm10.fsaverage.mgh       lh.white.H.fwhm10.fsaverage.mgh




#create ventricle and white matter masks
#import SUMA files to AFNI, in NIFTI format

#echo ${PWD_FSURF_SUBJECT}/${SID} 
#cd ${PWD_FSURF_SUBJECT}/${SID}
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
