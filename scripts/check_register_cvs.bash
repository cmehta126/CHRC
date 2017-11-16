# ********************************************
# Warp from Diffusion to CVS space
# ********************************************
fin=~/scratch60/completed_cvs.txt; 
fin=~/scratch60/completed_cvs_V4.txt; 
SC=$code/dti/map_meas_to_cvs.sh
wc -l $fin
A=( $(cat $fin) )
for ((i=0;i<1023;i++)); do
  SUB=${A[$i]}
  meas=adc
  fnout=~/scratch60/output/map_fa_meas_to_cvs/${SUB}_${meas}.out
  sbatch --out $fnout -J $i $SC $SUB $meas
  meas=fa
  fnout=~/scratch60/output/map_fa_meas_to_cvs/${SUB}_${meas}.out
  sbatch --out $fnout -J $i $SC $SUB $meas
done


fin=~/scratch60/completed_cvs_V4.txt; 
SC=$code/dti/map_meas_to_cvs.sh
wc -l $fin
A=( $(cat $fin) )
