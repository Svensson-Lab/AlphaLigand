#!/bin/bash
## Edit below with your requirements

fasta_path="/fastadir/inputs/" #path to receptor fasta files
run_parafold_path="run_parafold_no_template.sh" #path to run_parafold_no_template.sh script
out_dir="/outputdir/new_outs" #directory to write msas to
data_dir="/datadir/" #directory to alphafold database folder, (make sure not to have "/" at the end)
logdir=$out_dir #directory to write logs to, same as outdir by default
installation_dir="ParallelFold/"
do_ligands=true
do_receptors=false

bfd_database_path="$data_dir/bfd/bfd_metaclust_clu_complete_id30_c90_final_seq.sorted_opt"
small_bfd_database_path="$data_dir/small_bfd/bfd-first_non_consensus_sequences.fasta"
#mgnify_database_path="$data_dir/mgnify/mgy_clusters_2018_12.fa" #
mgnify_database_path="$data_dir/mgnify_2.3.3/mgy_clusters_2022_05.fa"
pdb_seqres_database_path="$data_dir/dummy_database/dummy_fas.fas"
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

#format ligands and receptors into merged fasta files
python process_input_folder.py $fasta_path


##Compute MSAs for each ligand indiviually
ligands_path=$fasta_path/Ligands

working=$PWD

cd $ligands_path
files=( $(ls *.fasta) )
num_files=${#files[@]}

cd $working

#fix batch related error
sed -i -e 's/\r$//' compute_msa.sh
sed -i -e 's/\r$//' predict_from_precomputed.sh

mkdir $out_dir/ligands_msas
mkdir $out_dir/receptors_msas

##if statement here that can be toggled

if $do_ligands

#Calculate msas for ligands in inputfolder
then
    #submit indiviual jobs per each ligand
    for (( i=0; i<${num_files}; i++ ));
    do
        #echo $ligands_path/${files[$i]}
        sbatch ./compute_msa.sh $ligands_path/${files[$i]} $out_dir/ligands_msas $run_parafold_path $data_dir/ $i $paths $installation_dir &
    done
fi

##Compute MSAs for each receptor indiviually

receptors_path=$fasta_path/Receptors

working=$PWD

cd $receptors_path
files=( $(ls *.fasta) )
num_files=${#files[@]}

cd $working

#fix batch related error
sed -i -e 's/\r$//' compute_msa.sh
sed -i -e 's/\r$//' predict_from_precomputed.sh

if $do_receptors
#Calculates msas for all receptors in inputfolder
then
    #submit indiviual jobs per each receptor
    for (( i=0; i<${num_files}; i++ ));
    do
        sbatch ./compute_msa.sh $receptors_path/${files[$i]} $out_dir/receptors_msas $run_parafold_path $data_dir/ $i $paths $installation_dir & 
   done
fi

wait # important to make sure the job doesn't exit before the background tasks are done
