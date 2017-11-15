#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
pwd_dti=$1
subj=$2
module load FSL/5.0.9-centos6_64
cd $pwd_dti
trac-all -bedp -c ${subj}_dmric.txt
