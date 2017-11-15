#!/bin/bash
#SBATCH -N 1 -c 4 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

sub_path=~/scratch60/pnc/subjects/${1}

#[ -d ${sub_path}/cvs ] && rm -rf ${sub_path}/cvs
[ ! -d $sub_path ] && mkdir $sub_path

mri_cvs_register --mov $1 --openmp 8 --outdir ${sub_path}/cvs 
