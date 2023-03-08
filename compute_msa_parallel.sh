#!/bin/bash

## Edit below(or above) with your requirements
#add sbatch array 

fasta_path="inputs" #path to receptor fasta files 
run_parafold_path="run_parafold_no_template.sh" #path to run_parafold_no_template.sh script
out_dir="/home/groups/katrinjs/msas" #directory to write msas to
data_dir="$OAK/alphafold_data" #directory to alphafold database folder, (make sure not to have "/" at the end)  
logdir=$out_dir #directory to write logs to, same as outdir by default

bfd_database_path="$data_dir/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt"
small_bfd_database_path="$data_dir/small_bfd/bfd-first_non_consensus_sequences.fasta"
mgnify_database_path="$data_dir/mgnify/mgy_clusters_2018_12.fa"
#template_mmcif_dir="$data_dir/dummy_database/"
#obsolete_pdbs_path="$data_dir/dummy_database/dummy_obsolete.dat"
#pdb70_database_path="$data_dir/dummy_database/dummydb"
#pdb_seqres_database_path="$data_dir/dummy_database/dummy_fas.fas"
uniclust30_database_path="$data_dir/uniclust30/uniclust30_2018_08/uniclust30_2018_08"   # We recommend this use the 2020 version of uniclust
uniref90_database_path="$data_dir/uniref90/uniref90.fasta"
uniprot_database_path="$data_dir/uniprot/uniprot.fasta"

## Stop editing here

##Dummy database
dummy_dir="dummy_database/"
template_mmcif_dir="$dummy_dir/"
obsolete_pdbs_path="$dummy_dir/dummy_obsolete.dat"
pdb70_database_path="$dummy_dir/dummydb"
pdb_seqres_database_path="$dummy_dir/dummy_fas.fas"

paths="$bfd_database_path;$small_bfd_database_path;$mgnify_database_path;$template_mmcif_dir;$obsolete_pdbs_path;$pdb70_database_path;$pdb_seqres_database_path;$uniclust30_database_path;$uniref90_database_path;$uniprot_database_path"

working=$PWD


cd $fasta_path
files=( $(ls *.fasta) )
num_files=${#files[@]}

cd $working

#fix batch related error 
sed -i -e 's/\r$//' compute_msa.sh
sed -i -e 's/\r$//' predict_from_precomputed.sh

#first 800 done #num_files=800
#num_files=1600

num_files=1

#submit indiviual jobs per each sequence
for (( i=0; i<${num_files}; i++ ));
do
    sbatch ./compute_msa.sh $fasta_path/${files[$i]} $out_dir $run_parafold_path $data_dir/ $i $paths &
    #sbatch ./predict_from_precomputed.sh $fasta_path/${files[$i]} $out_dir /home/users/dkavi/ParallelFold/run_alphafold.sh $data_dir/ $i $paths &
done


wait # important to make sure the job doesn't exit before the background tasks are done
