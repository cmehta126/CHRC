#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=8000 -t 48:00:00 

sub=$1;
meas=$2;
echo "$sub : $meas to talairach"

a=$SUBJECTS_DIR/${sub}/mri/dti
reg=${a}/register.dat
vol=${a}/${meas}.nii.gz
vol_masked=${a}/${meas}-masked.nii.gz
vol_masked_cvs=${a}/${meas}-masked.ANAT+CVS-to-avg35.nii.gz

vol_cvs=${a}/${meas}.ANAT+CVS-to-avg35.nii.gz

voltal=${a}/${meas}-tal.nii.gz
#mri_vol2vol --reg $reg --tal --mov $vol --o $voltal

aseg=$SUBJECTS_DIR/${sub}/mri/aseg.mgz
norm=$SUBJECTS_DIR/${sub}/mri/norm.mgz
vol_anat=${a}/${meas}-anat.nii.gz
vol_anat_masked=${a}/${meas}-anat-masked_aseg.nii.gz

mri_vol2vol --reg $reg --mov $vol --targ $aseg --o $vol_anat

mri_mask $vol_anat $SUBJECTS_DIR/$sub/mri/wmparc.mgz $vol_anat_masked

mri_vol2vol --targ $FREESURFER_HOME/subjects/cvs_avg35/mri/norm.mgz \
            --m3z ~/scratch60/pnc/subjects/$sub/cvs/final_CVSmorph_tocvs_avg35.m3z \
            --noDefM3zPath --reg $reg --mov $vol_anat_masked \
            --o $vol_cvs \
            --interp trilin --no-save-reg

vol_cvs_masked=${a}/${meas}-masked.ANAT+CVS-to-avg35.nii.gz

mri_mask $vol_cvs $FREESURFER_HOME/subjects/cvs_avg35/mri/aseg.mgz $vol_cvs_masked



