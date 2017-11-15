#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=16000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

HYP=$1
TYPE=$2
hemi=$3
meas=$4
fwhm=$5

cd ~/project/fs_glm

fn_id=${HYP}_ids.txt

if [ $TYPE = 'hemi' ]; then
  echo $TYPE
  mst=${meas}.fwhm${fwhm}.fsaverage
  fn_out=${HYP}_${TYPE}.${hemi}.${mst}.mgh
  echo "$TYPE - $HYP - $hemi - $meas - $fwhm"
  mris_preproc --f $fn_id --hemi $hemi --cache-in $mst --target fsaverage --o $fn_out
elif [ $TYPE = 'xhemi' ]; then 
  echo $TYPE
  fn_out=${HYP}_${TYPE}.lh.lh-rh.${meas}.sm00.mgh
  mris_preproc --target fsaverage_sym --hemi lh --xhemi --paired-diff --srcsurfreg fsaverage_sym.sphere.reg --meas $meas --out  $fn_out --f $fn_id
  mris_fwhm --s fsaverage_sym --hemi lh --cortex --smooth-only --fwhm $fwhm --i $fn_out --o ${HYP}_lh.lh-rh.${meas}.fwhm${fwhm}.mgh
fi


#mris_preproc --target fsaverage_sym --hemi lh --xhemi --paired-diff --srcsurfreg fsaverage_sym.sphere.reg --meas area --out  ${HYP}_lh.lh-rh.area.sm00.mgh --f ${HYP}_ids.txt 


