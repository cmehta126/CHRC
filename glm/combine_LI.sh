#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
HYP=$1; meas=$2; fwhm=$3;

cd ~/project/fs_glm
fn_id=${HYP}_ids.txt 
wc -l $fn_id
S1=( $(cat $fn_id) )
M1=xsurf/a_${HYP}.lh.lh-rh.LI.${meas}.fsaverage_sym.fwhm${fwhm}.mgh
SCRIPT=xsurf/concat_sample/make_${HYP}.lh.lh-rh.LI.${meas}.fsaverage_sym.fwhm${fwhm}.sh
printf 'mri_concat ' >  $SCRIPT
for ((i=0;i<1287;i++)); do
  SUB=${S1[$i]}
  SUBSURF=xsurf/latIndex/${SUB}.lh.lh-rh.LI.${meas}.fsaverage_sym.fwhm${fwhm}.mgh
  printf " --i $SUBSURF " >> $SCRIPT
done
printf " --o $M1" >> $SCRIPT
sh $SCRIPT
mv ${M1} ./

