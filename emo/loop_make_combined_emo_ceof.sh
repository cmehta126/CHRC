#!/bin/bash
#SBATCH -p general -N 1 -c 1 --mem-per-cpu=6000 -t 48:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu
FN=/ysm-gpfs/home/cm953/data/pnc_sid_emo_stats.txt
cat $FN | while read SID; do echo $SID; sh make_combined_emo_coef.sh $SID; done;
# *****************************************************************************


