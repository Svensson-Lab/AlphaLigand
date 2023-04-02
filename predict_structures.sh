#!/bin/bash
## Edit below with your requirements
fasta_path="/home/groups/katrinjs/inputs" #path to receptor fasta files 
run_parafold_path="run_alphafold_test.sh" #path to run_alphafold.sh script, no need to change unless you have a specific use 
out_dir="/home/groups/katrinjs/new_outs" #directory to write to
installation_dir="/home/groups/katrinjs/alphafold/" #directory of alphafold installation, i.e. where run_alphafold.py is located
data_dir="$OAK" #directory to alphafold database folder, (make sure not to have "/" at the end)  
logdir=$out_dir #directory to write logs to, same as outdir by default

##database paths, (the dates are set as the most recent version of the database, modify based on your installation if necessary)
bfd_database_path="$data_dir/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt"
small_bfd_database_path="$data_dir/small_bfd/bfd-first_non_consensus_sequences.fasta"
mgnify_database_path="$data_dir/mgnify_2.3.3/mgy_clusters_2022_05.fa"
#mgnify_database_path="$data_dir/mgnify/mgy_clusters.fa" #2.2.4 version 
pdb_seqres_database_path="$data_dir/dummy_database/dummy_fas.fas"
uniref30_database_path="$data_dir/uniref30/UniRef30_2021_03"  #since we are using reduced_db, it doesn't matter what this is set to, since we don't use neither uniclust or uniref 
uniref90_database_path="$data_dir/uniref90/uniref90.fasta"
uniprot_database_path="$data_dir/uniprot/uniprot.fasta"

##Stop editing here

##Dummy database, comes with cloning the run-hpc-alphafold repo
dummy_dir="dummy_database/"
template_mmcif_dir="$dummy_dir/"
obsolete_pdbs_path="$dummy_dir/dummy_obsolete.dat"
pdb70_database_path="$dummy_dir/dummydb"
pdb_seqres_database_path="$dummy_dir/dummy_fas.fas"

paths="$bfd_database_path;$small_bfd_database_path;$mgnify_database_path;$template_mmcif_dir;$obsolete_pdbs_path;$pdb70_database_path;$pdb_seqres_database_path;$uniref30_database_path;$uniref90_database_path;$uniprot_database_path"

python process_input_folder.py $fasta_path

fasta_path=$fasta_path/fasta_sequences
working=$PWD

cd $fasta_path
files=( $(ls *.fasta) )
num_files=${#files[@]}

cd $working

#fix batch related error 
sed -i -e 's/\r$//' predict_from_precomputed.sh
sed -i -e 's/\r$//' run_alphafold_test.sh

num_files=1

#submit indiviual jobs per each sequence
for (( i=0; i<${num_files}; i++ ));
do
    sbatch ./predict_from_precomputed.sh $fasta_path/${files[$i]} $out_dir $run_parafold_path $data_dir/ $i $paths $installation_dir &
    #sbatch ./predict_from_precomputed.sh $fasta_path/${files[$i]} $out_dir $run_parafold_path $data_dir/ $i $paths $installation_dir &
done

wait # important to make sure the job doesn't exit before the background tasks are done
