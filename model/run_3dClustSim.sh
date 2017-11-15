#!/bin/bash
#SBATCH -p general -N 1 -c 20 --mem-per-cpu=5000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

3dClustSim -mask $1 -acf $2 $3 $4  -LOTS -both -niml -prefix $5

