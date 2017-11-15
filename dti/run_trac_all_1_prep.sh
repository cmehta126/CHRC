#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
fn=$2
subj=$1
echo $subj
module load FSL/5.0.9-centos6_64
source ${FSLDIR}/etc/fslconf/fsl.sh
#cd $pwd_dti/dmrirc

trac-all -prep -c $fn
