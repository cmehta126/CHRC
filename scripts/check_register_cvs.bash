
# ********************************************
# Check CVS status 
# ********************************************
module load dSQ
cd ~/scratch60/output/reg_cvs/
tsk=~/scratch60/output/reg_cvs/a0_task.txt 
dSQAutopsy $tsk job_4131896_status.tsv > _failed_job_4131896_status.txt 2> _report_job_4131896_status.txt

dSQ.py --taskfile _failed_job_4131896_status.txt -p scavenge -N 1 -c 4 -n 8 --mem-per-cpu=6000 -t 48:00:00 | sbatch

# ********************************************
# Check completed CVS
# ********************************************
fn_id=~/project/data/sid_dti_dmric_full.txt
wc -l $fn_id
A=( $(cat $fn_id) )
fin=~/scratch60/completed_cvs_V5.txt; [ -e $fin ] && rm $fin
nofin=~/scratch60/incompleted_cvs_V5.txt; [ -e $nofin ] && rm $nofin
for ((i=0;i<1396;i++)); do
  SUB=${A[$i]}
  d=~/scratch60/pnc/subjects/${SUB}/cvs/final_CVSmorph_tocvs_avg35.m3z
  [ -e $d ] && echo $SUB >> $fin
  [ ! -e $d ]&& echo "$i $SUB" >> $nofin
done
wc -l $fin
wc -l $nofin

# ********************************************
# Warp from Diffusion to CVS space
# ********************************************
SC=$code/dti/map_meas_to_cvs.sh
wc -l $fin
A=( $(cat $fin) )
tmp=($( wc $fin)); N=${tmp[0]}; unset tmp
m0=( fa adc )
for ((i=0;i<$N;i++)); do
  SUB=${A[$i]}
  for meas in "${m0[@]}"; do
    fn=$SUBJECTS_DIR/${SUB}/mri/dti/_${meas}-masked_ds.ANAT+CVS-to-avg35.nii.gz
    if [ ! -f $fn ]; then
      echo "warping subject $SUB $meas"
      fnout=~/scratch60/output/map_fa_meas_to_cvs/${SUB}_${meas}.out
      sbatch --out $fnout -J $i $SC $SUB $meas
    else 
      echo "subject $SUB $meas complete"
    fi
  done
done


# ********************************************
# Smooth volumes
# ********************************************
SC=$code/glm/smooth_dwi.sh
wc -l $fin
A=( $(cat $fin) )
tmp=($( wc $fin)); N=${tmp[0]}; unset tmp
m0=( fa adc )
fwhm=5
for ((i=0;i<$N;i++)); do
  sub=${A[$i]}; echo "Subject $sub --- $i  of $N"
  for meas in "${m0[@]}"; do
    sh $SC smooth_dwi.sh $sub $meas $fwhm
  done
done




# ********************************************
# Prep volumes
# ********************************************
# Get ids design matrix from R.
cd ~/scratch60/glm/
module load FSL; source ${FSLDIR}/etc/fslconf/fsl.sh

exp=d005;
dos2unix $exp*txt

# Smooth and automask volumes
sc=$code/glm/stack_and_smooth_dwi_glm.sh
exp=d005; meas=fa
em=${exp}-${meas}
3dAutomask  -prefix dwi/volumes-${em}-CVS_mask.nii.gz dwi/volumes-${em}-CVS.nii.gz
sh $sc $exp $meas 5

# Examine contrasts --->
sc=$code/glm/fsl_glm.sh
Text2Vest d005_design.txt d005_design.mat

con=c11_6
con=c11_dd
Text2Vest ${con}.txt ${con}.con
sh $sc d005 adc d005 5 $con

sh $sc d005 fa d005 5 $con


0 1 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 1 0 0 0 0
0 0 0 0 0 0 0 1 0 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 0 1 0
0 0 0 0 0 0 0 0 0 0 1

0 0 0 0 0 0 0 1 1 0 0
0 0 0 0 0 0 0 0 0 1 1



# Evaluating the validity of volume-based and surface-based brain image registration for developmental cognitive neuroscience studies in children 4 to 11 years of age., Satrajit S. Ghosh, Sita Kakunoori, Jean Augustinack, Alfonso Nieto-Castanon, Ioulia Kovelman, Nadine Gaab, Joanna A. Christodoulou, Christina Triantafyllou, John D.E. Gabrieli, Bruce Fischl (2010). NeuroImage 53 (2010) 85




