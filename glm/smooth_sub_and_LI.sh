#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

SUB=$1



run_smooth_and_LI () {
  SUB=$1
  meas=$2 
  fwhm=$3
  cd ~/project/fs_glm
  fn_out=./xsurf/stacked_sub/${SUB}.lh.lh+rh.${meas}.fsaverage_sym
  fn_diff=./xsurf/latIndex/${SUB}.lh.lh-rh.LI.${meas}.fsaverage_sym
  
  #lh.area.fwhm5.fsaverage
  #mris_preproc --target fsaverage_sym --hemi lh --xhemi --srcsurfreg fsaverage_sym.sphere.reg --meas area --out  ${fn_out}.mgh --s $SUB
  mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm  --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
 
  # fwhm=5
  # mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  # mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
  #  
  # fwhm=10
  # mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm  --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  # mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
  # 
  # fwhm=15
  # mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm  --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  # mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
  # 
  # fwhm=20
  # mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm  --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  # mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
  # 
  # fwhm=25
  # mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm  --i ${fn_out}.mgh --o ${fn_out}.fwhm${fwhm}.mgh
  # mri_concat ${fn_out}.fwhm${fwhm}.mgh --paired-diff-norm --o ${fn_diff}.fwhm${fwhm}.mgh
 
  return 0  
}


#run_smooth_and_LI $SUB area 10 
#run_smooth_and_LI $SUB area 25
run_smooth_and_LI $SUB area 15
run_smooth_and_LI $SUB thickness 5
run_smooth_and_LI $SUB thickness 10
run_smooth_and_LI $SUB thickness 15








#mris_preproc --target fsaverage_sym --hemi lh --xhemi --paired-diff --srcsurfreg fsaverage_sym.sphere.reg --meas area --out  $fn_out --s $SUB



