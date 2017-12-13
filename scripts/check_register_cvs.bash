
# ********************************************
# Check CVS status 
# ********************************************
module load dSQ
cd ~/scratch60/output/reg_cvs/
tsk=~/scratch60/output/reg_cvs/a0_task.txt 
dSQAutopsy $tsk job_4131896_status.tsv > _failed_job_4131896_status.txt 2> _report_job_4131896_status.txt

dSQ.py --taskfile _failed_job_4131896_status.txt -p scavenge -N 1 -c 1 -n 8 --mem-per-cpu=6000 -t 48:00:00 | sbatch


module load dSQ
cd ~/scratch60/output/reg_cvs/
tsk=_failed_job_4131896_status.txt
dSQAutopsy $tsk job_4287182_status.tsv > _failed_job_4287182_status.txt 2> _report_job_4287182_status.txt

dSQ.py --taskfile _failed_job_4287182_status.txt -p scavenge -N 1 -c 1 -n 8 --mem-per-cpu=6000 -t 48:00:00 | sbatch

# V6:
nofin=~/scratch60/incompleted_cvs_V7.txt; 
tsk=~/scratch60/output/reg_cvs/c0_task.txt 
A=($(awk '{ print $2}' $nofin))
for ((j=0;j<${#A[@]};j++)); do
  sub=${A[$j]}
  printf "sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh $sub \n" >> $tsk
done

module load dSQ
cd ~/scratch60/output/reg_cvs/
dSQ.py --taskfile ~/scratch60/output/reg_cvs/c0_task.txt -p general -N 1 -c 1 -n 8 --mem-per-cpu=4000 -t 48:00:00 | sbatch
jobid=4366895
jobfile=job_${jobid}_status
dSQAutopsy ~/scratch60/output/reg_cvs/b0_task.txt ${jobfile}.tsv > _failed_${jobfile}.txt 2> _report_${jobfile}.txt


cd ~/scratch60/output/reg_cvs/
for((i=3;i<9;i++)); do
  sub=${A[$i]}
  echo "$i $sub"
  fout=FIN_d0_${sub}.out
  [ -d ~/scratch60/pnc/subjects/${sub}/cvs ] && echo "$i $sub good"
  sbatch --out $fout -J $i -p general /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh  $sub
done


# 1 gen #sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 606637614373
# 2 sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 606682071682
# 3 sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 606704561367
# 4 sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 606730080838
# 5 sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 606734396733
# 6 sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 607892668061
sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 608314508465
sh /ysm-gpfs/home/cm953/project/chrc/dti/register_cvs.sh 608325082475


# ********************************************
# Check completed CVS
# ********************************************
fn_id=~/project/data/sid_dti_dmric_full.txt
wc -l $fn_id
A=( $(cat $fn_id) )
fin=~/scratch60/completed_cvs_V8.txt; 
nofin=~/scratch60/incompleted_cvs_V8.txt; 
[ -e $fin ] && rm $fin; [ -e $nofin ] && rm $nofin
for ((i=0;i<1396;i++)); do
  SUB=${A[$i]}
  d=~/scratch60/pnc/subjects/${SUB}/cvs/final_CVSmorph_tocvs_avg35.m3z
  [ -e $d ] && echo $SUB >> $fin
  [ ! -e $d ]&& echo "$i $SUB" >> $nofin
done
wc -l $fin
wc -l $nofin


# ********************************************
# Make Axial Diffusivity file
# ********************************************

fn_id=~/project/data/sid_dti_dmric_full.txt
wc -l $fn_id
S0=($(cat $fn_id))
for ((j=0;j<1396; j++)); do
  sub=${S0[$j]}
  echo $j; echo $sub;
  cd $SUBJECTS_DIR/${sub}/mri/dti
  [ -e axialdiff.nii.gz ] && echo "$j $sub"
  #fslsplit eigvals.nii.gz __rm_eigenvals -t
  #mv __rm_eigenvals0000.nii.gz axialdiff.nii.gz
  #rm __rm_eigenvals000*.nii.gz
done



# ********************************************
# Warp from Diffusion to CVS space
# ********************************************
SC=$code/dti/map_meas_to_cvs.sh
fin=~/scratch60/completed_cvs_V8.txt; 
wc -l $fin
A=( $(cat $fin) )
tmp=($( wc $fin)); N=${tmp[0]}; unset tmp
m0=( fa adc radialdiff axialdiff )
for ((i=1;i<$N;i++)); do
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
fin=~/scratch60/completed_cvs_V8.txt;
wc -l $fin
A=( $(cat $fin) )
tmp=($( wc $fin)); N=${tmp[0]}; unset tmp
m0=( fa adc radialdiff )
fwhm=10
for ((i=673;i<700;i++)); do
  sub=${A[$i]}; echo "Subject $sub --- $i  of $N"
  for meas in "${m0[@]}"; do
    sh $SC $sub $meas $fwhm
  done
done


a=$code/glm/normalize_dwi.sh
sh $a 600001103037 adc 5

# ********************************************
# Prep volumes
# ********************************************
# Get ids design matrix from R.
module load FSL; 

cd ~/scratch60/glm/
source ${FSLDIR}/etc/fslconf/fsl.sh

exp=d005;
dos2unix $exp*txt
wc -l d005_id.txt

# Smooth and automask volumes

exp=d005;
meas=radialdiff
prep_script=$code/glm/stack_smooth_automask_dwi_glm.sh
sh $prep_script $exp $meas 5


em=${exp}-${meas}
3dAutomask  -prefix dwi/volumes-${em}-CVS_mask.nii.gz -overwrite dwi/volumes-${em}-CVS_fwhm5.nii.gz



sc=$code/glm/stack_and_smooth_dwi_glm.sh
exp=e005; meas=axialdiff
em=${exp}-${meas}
sh $sc $exp $meas 5
3dAutomask  -prefix dwi/volumes-${em}-CVS_mask.nii.gz -overwrite dwi/volumes-${em}-CVS_fwhm5.nii.gz
#cp dwi/volumes-d005-${meas}-CVS_mask.nii.gz dwi/volumes-dea5-${meas}-CVS_mask.nii.gz 


# Examine contrasts --->
cd ~/scratch60/glm/
sc=$code/glm/fsl_glm.sh

con=c11_dd

con=c7_7

exp=e005
Text2Vest ${con}.txt ${con}.con
#Text2Vest ${con}_F.txt ${con}.fts
Text2Vest ${exp}_design.txt ${exp}_design.mat

#sh $sc $exp adc $exp 5 $con

sh $sc $exp fa $exp 5 $con


0 1 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 1 0 0 0 0
0 0 0 0 0 0 0 1 0 0 0
0 0 0 0 0 0 0 0 1 0 0
0 0 0 0 0 0 0 0 0 1 0
0 0 0 0 0 0 0 0 0 0 1

0 0 0 0 0 0 0 1 1 0 0
0 0 0 0 0 0 0 0 0 1 1



Evaluating the validity of volume-based and surface-based brain image registration for developmental cognitive neuroscience studies in children 4 to 11 years of age., Satrajit S. Ghosh, Sita Kakunoori, Jean Augustinack, Alfonso Nieto-Castanon, Ioulia Kovelman, Nadine Gaab, Joanna A. Christodoulou, Christina Triantafyllou, John D.E. Gabrieli, Bruce Fischl (2010). NeuroImage 53 (2010) 85




