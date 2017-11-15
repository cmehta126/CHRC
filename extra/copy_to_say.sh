#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=25000 -t 192:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu


# To run:
# A1=genipe_PNC_GO_Omni; sbatch -J $A1 --out ${scratch}/mp_slurm/${A1}.out ${scratch}/copy_to_say.sh impute/${A1} $project

A=${2}/$1
B=${say}/$1

echo "Beginning move of $A to $B"
mv $A  $B
echo "Finished moving $A to $B"
