#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=2000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

pwd_dti=$1
pwd_data=$2
subj=$3


cd $pwd_dti
fn_subj_data=${pwd_data}/${subj}_1.tar.gz
ex_35=$(tar -xf $fn_subj_data ${subj}/DTI_35dir/)$?
if (( $ex_35 == 0 )); then
  ~/project/bin/./dcm2nii -a y -e n -d n -p n ${subj}/DTI_35dir/Dicoms/DTI_35dir_I000000.dcm 
  mv ${subj}/DTI_35dir/Dicoms/*nii.gz ${subj}_DTI_35dir.nii.gz
  mv ${subj}/DTI_35dir/Dicoms/*bval ${subj}_DTI_35dir.bval
  mv ${subj}/DTI_35dir/Dicoms/*bvec ${subj}_DTI_35dir.bvec
fi

ex_36=$(tar -xf $fn_subj_data ${subj}/DTI_36dir/)$?
if (( $ex_36 == 0 )); then
  ~/project/bin/./dcm2nii -a y -e n -d n -p n ${subj}/DTI_36dir/Dicoms/DTI_36dir_I000000.dcm 
  mv ${subj}/DTI_36dir/Dicoms/*nii.gz ${subj}_DTI_36dir.nii.gz
  mv ${subj}/DTI_36dir/Dicoms/*bval ${subj}_DTI_36dir.bval
  mv ${subj}/DTI_36dir/Dicoms/*bvec ${subj}_DTI_36dir.bvec
fi

if (( $ex_35 == 0 && $ex_36 == 0 )); then
  mri_concat --i ${subj}_DTI_35dir.nii.gz --i ${subj}_DTI_36dir.nii.gz --o ${subj}_DTI.nii.gz
  paste -d ' ' ${subj}_DTI_35dir.bvec /dev/null ${subj}_DTI_36dir.bvec > ${subj}_DTI.bvec
  paste -d ' ' ${subj}_DTI_35dir.bval /dev/null ${subj}_DTI_36dir.bval > ${subj}_DTI.bval
  printf "setenv SUBJECTS_DIR $SUBJECTS_DIR \n" > ${subj}_dmric.txt
  printf "set subjlist = ($subj) \n" >> ${subj}_dmric.txt
  printf "set dcmlist = (${pwd_dti}/${subj}_DTI.nii.gz) \n" >> ${subj}_dmric.txt
  printf "set bveclist = (${pwd_dti}/${subj}_DTI.bvec) \n" >> ${subj}_dmric.txt
  printf "set bvallist = (${pwd_dti}/${subj}_DTI.bval) \n" >> ${subj}_dmric.txt
  echo "Extracted dti data for $subj."
fi

[ -d ${subj} ] &&  rm -rf ${subj}/

fn=${subj}_DTI_35dir.bval
[ -f $fn ] && rm $fn

fn=${subj}_DTI_36dir.bval
[ -f $fn ] && rm $fn

fn=${subj}_DTI_35dir.bvec
[ -f $fn ] && rm $fn

fn=${subj}_DTI_36dir.bvec
[ -f $fn ] && rm $fn

fn=${subj}_DTI_35dir.nii.gz
[ -f $fn ] && rm $fn

fn=${subj}_DTI_36dir.nii.gz
[ -f $fn ] && rm $fn



