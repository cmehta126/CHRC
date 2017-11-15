#!/usr/bin/Rscript
#SBATCH -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

system('module load MATLAB/2017a')
require(R.matlab)
Matlab$startServer(); 


# Strings to send to matlab for loading mgh files.
S1 = "Y0 = load_mgh('~/data/fs60/glm/mgh/lh.volume.fwhm5.mgh');"




