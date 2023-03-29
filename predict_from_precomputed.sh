#!/bin/bash
#SBATCH --job-name=structure-prediction
#SBATCH --time=16:00:00
#SBATCH --nodes=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=64GB

input=$1 #Fasta file path: $1
output=$2 #Output directory: $2
run_parafold_path=$3 #path to run_alphafold.sh script in the parallelfold installation
dbpath=$4 #directory to alphafold database folder
i=$5 #index of input fasta file 
paths=$6 #concatenated string of path to each database file split by ";", see compute_msa_parallel.sh file for ordering
installation_dir=$7

filename=$(basename -- "$input")
gene="${filename%.*}"
date=$(date +"%Y-%m-%d")
log="${date}_${gene}_prediction_log.txt"

log=$output"/"$log
echo "Started Prediction:"$(date +"%Y-%m-%d %T") > $log

#bash $run_parafold_path \
#	-d $dbpath \
#	-b $paths \
#	-o $output \
#	-p multimer \
#	-i $input \
#	-f true \
#	-m model_1_multimer_v2 \
#	-t 1800-01-01 \
#	-c reduced_dbs \
#	-use_gpu_relax=false

bash $run_parafold_path -d $dbpath -b $paths -o $output -p true -m multimer -f $input -t 1800-01-01 -c reduced_dbs -e false -g false -q "/home/groups/katrinjs/alphafold-2.2.0/"
 
echo "Finished Prediction:"$(date +"%Y-%m-%d %T") >> $log
