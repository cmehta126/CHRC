#!/bin/bash
#SBATCH -p general -N 1 -c 20 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

3dClustSim -mask ~/project/code/TT_N27_GM_3mm.nii -acf 0.46 5.17 11.91 -LOTS -both -prefix results/b

