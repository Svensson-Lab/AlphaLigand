#!/bin/bash
# Description: AlphaFold non-docker version
# Author: Sanjay Kumar Srikakulam
# Modified by Bozitao Zhong

while getopts ":d:b:o:p:i:t:u:c:m:R:bgrvsqfG" j; do
        case "${j}" in
        d)
                data_dir=$OPTARG 
        ;;
        b)
                db_paths=$OPTARG      
        ;;
        o)
                output_dir=$OPTARG
        ;;
        p)
                model_preset=$OPTARG
        ;;
        i)
                fasta_path=$OPTARG
        ;;
        t)
                max_template_date=$OPTARG
        ;;
        b)
                benchmark=true
        ;;
        g)
                use_gpu=true
        ;;
        u)
                gpu_devices=$OPTARG
        ;;
        c)
                db_preset=$OPTARG
        ;;
        r)
                amber_relaxation=false
        ;;
        m)
                model_selection=$OPTARG
        ;;
        v)
                visualizaion=true
        ;;
        s)
                skip_msa=true
        ;;
        q)
                quick_mode=true
        ;;
        R)
                recycling=$OPTARG
        ;;
        f)
                run_feature=true
        ;;
        G)
                use_gpu_relax=false
        ;;
        esac
done

# Parse input and set defaults
if [[ "$data_dir" == "" || "$output_dir" == "" || "$model_preset" == "" || "$fasta_path" == "" ]] ; then
    output_dir=""
fi

if [[ "$max_template_date" == "" ]] ; then
    max_template_date="2020-12-01"
fi

if [[ "$benchmark" == "" ]] ; then
    benchmark=false
fi

if [[ "$use_gpu" == "" ]] ; then
    use_gpu=true
fi

if [[ "$gpu_devices" == "" ]] ; then
    gpu_devices="0"
fi

if [[ "$db_preset" == "" ]] ; then
    db_preset="reduced_dbs"
fi

if [[ "$amber_relaxation" == "" ]] ; then
    amber_relaxation=true
fi

if [[ "$model_selection" == "" ]] ; then
    model_selection=""
fi

if [[ "$visualizaion" == "" ]] ; then
    visualizaion=false
fi

if [[ "$skip_msa" == "" ]] ; then
    skip_msa=false
fi

if [[ "$quick_mode" == "" ]] ; then
    quick_mode=false
fi

if [[ "$recycling" == "" ]] ; then
    recycling=3
fi

if [[ "$run_feature" == "" ]] ; then
    run_feature=false
fi

if [[ "$use_gpu_relax" == "" ]] ; then
    use_gpu_relax=true
fi


# This bash script looks for the run_alphafold.py script in its current working directory, if it does not exist then exits
#current_working_dir=$(pwd)
alphafold_script="/home/users/dkavi/ParallelFold/run_alphafold.py"
#alphafold_script=$PWD"/ParallelFold/run_alphafold_precomputed.py"

if [ ! -f "$alphafold_script" ]; then
    echo "Alphafold python script $alphafold_script does not exist."
    #exit 1
fi

# Export ENVIRONMENT variables and set CUDA devices for use
if [[ "$use_gpu" == true ]] ; then
    export CUDA_VISIBLE_DEVICES=0

    if [[ "$gpu_devices" ]] ; then
        export CUDA_VISIBLE_DEVICES=$gpu_devices
    fi
fi

export TF_FORCE_UNIFIED_MEMORY='1'
export XLA_PYTHON_CLIENT_MEM_FRACTION='4.0'

##iterate over data_dir and split with ";" as delimiter into array 
IFS=';' read -r -a array <<< $db_paths

# Path and user config (change me if required)
bfd_database_path=${array[0]}
small_bfd_database_path=${array[1]}
mgnify_database_path=${array[2]}
template_mmcif_dir=${array[3]}
obsolete_pdbs_path=${array[4]}
pdb70_database_path=${array[5]}
pdb_seqres_database_path=${array[6]}
uniclust30_database_path=${array[7]}   # We recommend this use the 2020 version of uniclust
uniref90_database_path=${array[8]}
uniprot_database_path=${array[9]}

if [[ "$db_preset" == "full_dbs" ]] ; then
    small_bfd_database_path=""
fi

if [[ "$db_preset" == "reduced_dbs" ]] ; then
    bfd_database_path=""
    uniclust30_database_path=""
fi

# Binary path (change me if required)
hhblits_binary_path=$(which hhblits)
hhsearch_binary_path=$(which hhsearch)
jackhmmer_binary_path=$(which jackhmmer)
kalign_binary_path=$(which kalign)
hmmsearch_binary_path=$(which hmmsearch)
hmmbuild_binary_path=$(which hmmbuild)

# Temporary
# Missing random_seed, use_precomputed_msas, amber_relaxation
if [[ "$model_preset" == "monomer" || "$model_preset" == "monomer_ptm" ]] ; then
    pdb_seqres_database_path=""
    uniprot_database_path=""
fi

if [[ "$model_preset" == "multimer" ]] ; then
    pdb70_database_path=""
fi

echo $fasta_path
echo $data_dir

#[ -d "/path/to/dir" ] && echo "Directory $data_dir exists." || echo "Error: Directory $data_dir does not exists."
#add paths to PATH

# Run AlphaFold with required parameters
python $alphafold_script --use_precomputed_msas=true --fasta_paths=$fasta_path --data_dir=$data_dir --output_dir=$output_dir --jackhmmer_binary_path=$jackhmmer_binary_path --hhblits_binary_path=$hhblits_binary_path --hhsearch_binary_path=$hhsearch_binary_path --hmmsearch_binary_path=$hmmsearch_binary_path --hmmbuild_binary_path=$hmmbuild_binary_path --kalign_binary_path=$kalign_binary_path --uniref90_database_path=$uniref90_database_path --mgnify_database_path=$mgnify_database_path --bfd_database_path=$bfd_database_path --small_bfd_database_path=$small_bfd_database_path --uniclust30_database_path=$uniclust30_database_path --uniprot_database_path=$uniprot_database_path --pdb70_database_path=$pdb70_database_path --pdb_seqres_database_path=$pdb_seqres_database_path --template_mmcif_dir=$template_mmcif_dir --max_template_date=$max_template_date --obsolete_pdbs_path=$obsolete_pdbs_path --db_preset=$db_preset --model_preset=$model_preset --benchmark=$benchmark --run_relax=$amber_relaxation --use_gpu_relax=$use_gpu_relax --use_gpu_relax=false --logtostderr
#python $alphafold_script --use_precomputed_msas=true --fasta_paths=$fasta_path --data_dir=$data_dir --output_dir=$output_dir --model_names=$model_selection --jackhmmer_binary_path=$jackhmmer_binary_path --hhblits_binary_path=$hhblits_binary_path --hhsearch_binary_path=$hhsearch_binary_path --hmmsearch_binary_path=$hmmsearch_binary_path --hmmbuild_binary_path=$hmmbuild_binary_path --kalign_binary_path=$kalign_binary_path --uniref90_database_path=$uniref90_database_path --mgnify_database_path=$mgnify_database_path --bfd_database_path=$bfd_database_path --small_bfd_database_path=$small_bfd_database_path --uniclust30_database_path=$uniclust30_database_path --uniprot_database_path=$uniprot_database_path --pdb70_database_path=$pdb70_database_path --pdb_seqres_database_path=$pdb_seqres_database_path --template_mmcif_dir=$template_mmcif_dir --max_template_date=$max_template_date --obsolete_pdbs_path=$obsolete_pdbs_path --db_preset=$db_preset --model_preset=$model_preset --benchmark=$benchmark --run_relax=$amber_relaxation --use_gpu_relax=$use_gpu_relax --recycling=$recycling --run_feature=$run_feature --use_gpu_relax=false --logtostderr