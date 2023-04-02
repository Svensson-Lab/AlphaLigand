#!/bin/bash
#SBATCH --job-name=msa-compute
#SBATCH --time=16:00:00
#SBATCH --mem-per-cpu=16GB
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=2

input=$1 #Fasta file path: $1
output=$2 #Output directory: $2
run_parafold_path=$3 #path to run_alphafold.sh script in the parallelfold installation
dbpath=$4 #directory to alphafold database folder
i=$5 #index of input fasta file 
paths=$6 #concatenated string of path to each database file split by ";", see compute_msa_parallel.sh file for ordering
installation_dir=$7

echo $installation_dir

filename=$(basename -- "$input")
gene="${filename%.*}"
date=$(date +"%Y-%m-%d")
log="${date}_${gene}_precomputed_log.txt"

log=$output"/"$log
echo "Started MSA Computation:"$(date +"%Y-%m-%d %T") > $log

bash $run_parafold_path \
	-a $installation_dir \
	-d $dbpath \
	-b $paths \
	-o $output \
	-p multimer \
	-i $input \
	-f true \
	-m model_1_multimer_v2 \
	-t 1800-01-01 \
	-c reduced_dbs \
	-use_gpu_relax=false

echo "Finished MSA Computation:"$(date +"%Y-%m-%d %T") >> $log
