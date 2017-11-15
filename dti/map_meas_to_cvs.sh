#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=8000 -t 48:00:00 

sub=$1;
meas=$2;
echo "$sub : $meas to talairach"

a=$SUBJECTS_DIR/${sub}/mri/dti
reg=${a}/register.dat
vol=${a}/${meas}.nii.gz
vol_masked=${a}/${meas}-masked.nii.gz
#vol_masked_cvs=${a}/${meas}-masked.ANAT+CVS-to-avg35.nii.gz

vol_cvs=${a}/_${meas}.ANAT+CVS-to-avg35.nii.gz
vol_cvs_crop=${a}/_${meas}_crop.ANAT+CVS-to-avg35.nii.gz
# fa/adc volumes are registered (affine) to native space and then nonlinear warped to cvs template using trilinear interpolation
mri_vol2vol --targ $FREESURFER_HOME/subjects/cvs_avg35/mri/norm.mgz \
            --m3z ~/scratch60/pnc/subjects/$sub/cvs/final_CVSmorph_tocvs_avg35.m3z \
            --noDefM3zPath --reg $reg --mov $vol \
            --o $vol_cvs \
            --interp trilin --no-save-reg


vol_cvs_masked=${a}/_${meas}-masked.ANAT+CVS-to-avg35.nii.gz
# volumes are masked to gray and white matter volumes in the CVS space.
3dcalc -a $vol_cvs -b $FREESURFER_HOME/subjects/cvs_avg35/mri/aseg.nii.gz -expr 'a*step(b)' -prefix $vol_cvs_masked -overwrite

vol_cvs_masked_down=${a}/_${meas}-masked_ds.ANAT+CVS-to-avg35.nii.gz
# Volumes are resampled to 128 x 128 x 128
#mri_convert $vol_cvs_masked $vol_cvs_masked_down

3dresample -dxyz 2.0 2.0 2.0 -input $vol_cvs_masked -prefix $vol_cvs_masked_down







#voltal=${a}/${meas}-tal.nii.gz
#mri_vol2vol --reg $reg --tal --mov $vol --o $voltal
#aseg=$SUBJECTS_DIR/${sub}/mri/aseg.mgz
#norm=$SUBJECTS_DIR/${sub}/mri/norm.mgz
#vol_anat=${a}/${meas}-anat.nii.gz
#vol_anat_masked=${a}/${meas}-anat-masked_aseg.nii.gz

# mri_vol2vol --reg $reg --mov $vol --targ $aseg --o $vol_anat

#mri_mask $vol $SUBJECTS_DIR/$sub/mri/dti/wmparc2diff.mgz $vol_masked



















#mri_mask -T 0.5 $vol_cvs $FREESURFER_HOME/subjects/cvs_avg35/mri/aseg.mgz $vol_cvs_masked



