#!/bin/bash
#SBATCH -p general
#SBATCH -N 1 -c 20 --mem-per-cpu=6000 
#SBATCH -t 96:00:00 --mail-type=ALL --mail-user=chintan.mehta@yale.edu

source ~/.bashrc
source $HOME/miniconda/bin/activate genipe_pyvenv
#cd /ysm-gpfs/project/cm953/impute
#sh /ysm-gpfs/project/cm953/impute/execute_tutorial.sh

cd /ysm-gpfs/home/cm953/project/impute

eval $PY27
BaseFile=$1
OutDir=$2
ReportTitle=$3
ReportNumber=$4

echo $BaseFile
echo $OutDir
echo $ReportTitle
echo $ReportNumber

eval $PY27
module load Python/2.7.11-foss-2016a

# Launching the imputation with genipe
genipe-launcher \
    --chrom autosomes \
    --bfile $BaseFile \
    --output-dir $OutDir \
    --shapeit-bin /ysm-gpfs/home/cm953/project/impute/bin/shapeit \
    --impute2-bin /ysm-gpfs/home/cm953/project/impute/bin/impute2 \
    --plink-bin /ysm-gpfs/home/cm953/project/impute/bin/plink \
    --reference /ysm-gpfs/home/cm953/project/impute/hg19/hg19.fasta \
    --hap-template /ysm-gpfs/home/cm953/project/impute/1000GP_Phase3/1000GP_Phase3_chr{chrom}.hap.gz \
    --legend-template /ysm-gpfs/home/cm953/project/impute/1000GP_Phase3/1000GP_Phase3_chr{chrom}.legend.gz \
    --map-template /ysm-gpfs/home/cm953/project/impute/1000GP_Phase3/genetic_map_chr{chrom}_combined_b37.txt \
    --sample-file /ysm-gpfs/home/cm953/project/impute/1000GP_Phase3/1000GP_Phase3.sample \
    --filtering-rules 'ALL<0.01' 'ALL>0.99' \
    --thread 20 \
    --info 0.3\
    --report-title $ReportTitle \
    --report-number $ReportNumber 
    #--use-drmaa --drmaa-config drmaa.config


