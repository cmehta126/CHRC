#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

SUB=$1; si=$2
echo $SUB
out=~/export/sub${si}/
[ -d $out ] && rm -rf $out
[ ! -d $out ] && mkdir $out
#mkdir ~/export/g${si}
b=${SUBJECTS_DIR}/${SUB}/mri/dti
cd $b;
cp lowb.nii.gz $out
cp adc.nii.gz $out
cp radialdiff.nii.gz $out
cp fa.nii.gz $out
cp register.dat $out 
cp wmparc2diff.mgz $out
cp _* $out
cp *-masked.nii.gz $out



cd ~/scratch60/pnc/subjects/$SUB/cvs/
cp final_CVSmorphed_tocvs_avg35_aseg.mgz $out
cp final_CVSmorphed_tocvs_avg35_norm.mgz $out

#cp $SUBJECTS_DIR/$SUB/mri/dti/adc-masked.ANAT+CVS-to-avg35.mgz $out
#cp $SUBJECTS_DIR/$SUB/mri/dti/fa-masked.ANAT+CVS-to-avg35.mgz $out #cp $SUBJECTS_DIR/$SUB/mri/dti/dwi.nii.gz ~/export/g${si}/

cp $SUBJECTS_DIR/$SUB/surf/lh.white $out
cp $SUBJECTS_DIR/$SUB/surf/rh.white $out 

cd $SUBJECTS_DIR/$SUB/mri/
cp brainmask.mgz $out

cp $SUBJECTS_DIR/$SUB/mri/orig.mgz $out
cp $SUBJECTS_DIR/$SUB/mri/wmparc.mgz $out

cp /ysm-gpfs/home/cm953/scratch60/pnc/subjects/${SUB}/cvs/final_CVSmorphed_tocvs_avg35_norm.mgz $out
cp /ysm-gpfs/home/cm953/scratch60/pnc/subjects/${SUB}/cvs/final_CVSmorphed_tocvs_avg35_aseg.mgz $out

