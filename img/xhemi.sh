#!/bin/bash
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

surfreg --s $1 --t fsaverage_sym --lh
surfreg --s $1 --t fsaverage_sym --lh --xhemi

