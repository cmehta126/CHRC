#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

SUB=$1
a=$SUBJECTS_DIR/$SUB/mri
b=${a}/dti
d=$SUBJECTS_DIR/$SUB/stats

mri_vol2vol --mov ${b}/lowb.nii.gz --targ ${a}/wmparc.mgz --inv --interp nearest --o ${b}/wmparc2diff.mgz --reg ${b}/register.dat --no-save-reg
mri_vol2vol --mov ${b}/lowb.nii.gz --targ ${a}/brainmask.mgz --inv --interp nearest --o ${b}/brainmask2diff.mgz --reg ${b}/register.dat --no-save-reg

#mri_vol2vol --mov ${b}/lowb.nii.gz --targ ${a}/aparc+aseg.mgz --inv --interp nearest --o ${a}/aparc+aseg2diff.mgz --reg ${b}/register.dat --no-save-reg

#mri_mask ${b}/fa.nii.gz ${a}/wmparc2diff.mgz ${b}/fa-masked.mgz

#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/fa.nii.gz --sum ${d}/fa.stats
#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/adc.nii.gz --sum ${d}/adc.stats
#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/vr.nii.gz --sum ${d}/vr.stats
#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/ra.nii.gz --sum ${d}/ra.stats
#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/radialdiff.nii.gz --sum ${d}/radialdiff.stats
#

meas=fa
mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats

meas=ivc
mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats

meas=radialdiff
mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats

meas=vr
mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats

meas=adc
mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats

#meas=ra
#mri_segstats --seg ${b}/wmparc2diff.mgz --ctab $FREESURFER_HOME/FreeSurferColorLUT.txt --i ${b}/${meas}.nii.gz --sum ${d}/${meas}.stats




