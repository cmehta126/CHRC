#!/bin/bash
#SBATCH -N 1 -c 1 -p general --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
fn=$1
module load FSL/5.0.9-centos6_64
trac-all -path -c $fn
