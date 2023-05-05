The collection of scripts in this repository predicts the structures of protein-multimers using lists of fasta files in a directory using [Slurm](https://slurm.schedmd.com/documentation.html). This is the release for AlphaFold version 2.3.x
=======
The collection of scripts in this repository predicts the structures of protein-multimers using lists of fasta files in a directory using [Slurm](https://slurm.schedmd.com/documentation.html). This is the release for AlphaFold version 2.3.1. See here for [v2.2.4](https://github.com/Svensson-Lab/run-hpc-alphafold/releases/tag/v2.2.4)

## Installation
Install miniconda: 
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh
``` 

Clone this repository: 

```
git clone git@github.com:Svensson-Lab/run-hpc-alphafold.git 
cd run-hpc-alphafold
```
Install requirements and create conda environment 

```
conda create --name alphafold python==3.8
conda update -n base conda

conda install -y -c conda-forge openmm==7.5.1 cudatoolkit==11.2.2 pdbfixer
conda install -y -c bioconda hmmer hhsuite==3.3.0 kalign2
```
Activate environment:
```
conda activate alphafold
```


Install libraries
``` 
pip install absl-py==1.0.0 biopython==1.79 chex==0.0.7 dm-haiku==0.0.9 dm-tree==0.1.6 immutabledict==2.0.0 jax==0.3.25 ml-collections==0.1.0 numpy==1.21.6 pandas==1.3.4 protobuf==3.20.1 scipy==1.7.0 tensorflow-cpu==2.9.0

pip install --upgrade --no-cache-dir jax==0.3.25 jaxlib==0.3.25+cuda11.cudnn805 -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
```



Set permissions for shell files: 
```
chmod +x compute_msa.sh
chmod +x compute_msa_parallel.sh
chmod +x predict_structures.sh 
chmod +x predict_from_precomputed.sh
```

## Usage
Do not move the scripts from the run-hpc-alphafold folder, this will cause errors in accessing paths. Please also make sure that you have alphafold repository and the required databases installed. See [Deep Mind](https://github.com/deepmind/alphafold) for more information. This repo currently uses the Alphafold 2.3.1 release with reduced databases.     


### Inputs
The inputs should be in a directory with two folders: "Ligands" and "Receptors", each containing .fasta files for the required sequences. The script will create another directory "fasta_sequences" which holds the merged sequences, these are the sequences the user will be receiving predictions for. The user provides a folder "Ligands" which contains a list of ligand fasta files and "Receptors" which contains the fasta files for your receptors. Example: 
 
```
path/to/inputs/directory/                           
    Receptors/                                   
        # fasta files for receptors
    Ligands/                       
	# fasta files for ligands        
```

To provide your paths to each script please edit the necessary parts of either the `predict_structures` or the `compute_msa_parallel` files. For both MSA computations and structure predictions, we use the inputs: 

```
fasta_path=path/to/inputs/directory/ #path to receptor fasta files 
run_parafold_path="run_parafold_no_template.sh" #path to run_parafold_no_template.sh script

out_dir="/home/groups/katrinjs/predictions" #directory to write to
data_dir="/path_to_your/alphafold_data" #directory to alphafold database folder, (make sure not to have "/" at the end)  
installation_dir="/path_to_your/alphafold_installation"
logdir=$out_dir #directory to write logs to, same as outdir by default
```
1. `fasta_path` is the directory of fasta files that will be processed (inputs from the section above)
1. `run_parafold_path` is the script to run alphafold, unless you have a specific modification there is no need to change this. Leaving `run_alphafold_test` and `run_parafold_no_template` is fine.
1. `out_dir` is the directory to write MSAs and predictions to.
1. `data_dir` is the directory to alphafold database folder, (make sure not to have a "/" at the end)
1. `installation_dir` is the directory of the alphafold installation, such as the folder cloned from deepmind's alphafold repository or the ParallelFold folder. This is the folder that should contain the run_alphafold.py file and the alphafold utilities.  
1. `logdir` is the directory to write logs to, same as outdir by default

### Running Alphafold
#### Compute MSAs
After editing the inputs in `compute_msa_parallel.sh`, run it using bash:
```
bash compute_msa_parallel.sh
```
If you aren't using Parafold, please replace your run_alphafold.py file in your alphafold installation with the run_alphafold.py script in this repository/the one found in the Parallelfold folder. 

This will compute MSAs for each ligand and receptor, saving them to ligands_msas and receptors_msas folders inside the output directory. If you already have MSAs for your ligands or receptors, there is option to stop the script from needlessly computing MSAs by setting `do_ligands` or `do_receptors` to false. You can download MSAs for the library described in [the paper](https://www.biorxiv.org/content/10.1101/2023.03.16.531341v1) from the link [here](https://drive.google.com/file/d/1CzcO4JfKO8NrnVQvIKIQTCn__ha1ZWly/view?usp=share_link). To use the precomputed MSAs, you can place your MSAs in receptors_msas or ligands_msas folder inside your output folder(these two folders are generated by the `compute_msa_parallel` script).

#### Copy MSAs
Make sure that the MSA computation in the above step is complete. Then, calling: 
```
python handle_msas.py out_dir input_dir
``` 
If you are not using Parafold to compute MSAs, there are some required modifications to make in the run_alphafold.py file in your Alphafold installation. We have provided a run_alphafold.py script for you in the repository, so you may replace your existing file under alphafold/run_alphafold.py with our version if you wish. If you are using Parafold, there are no required changes.

This script will move the required MSAs for each sequence to the corresponding folder in the output directory. For multimer BMP10_ACE.fasta for example, alphafold needs the MSA for BMP10 and ACE sequences, instead of computing them again every time,we can copy the MSAs we have precomputed in the "Compute MSAs" step. 

#### Predict structures
After changing the inputs in the `predict_structures.sh` script, calling:
```
bash predict_structures.sh
```
will read MSAs from the output folder and save predictions for each sequence to their corresponding folders inside the output folder.

### Tips and Possible Issues
1. If the number of sequences you are processing is high, there is a possibly that your HPC environment will not allow you to submit the whole library. To solve this you can modify the `num_files` and `i` variables in the bash scripts to run fewer simultaneous predictions. For example `i=0` and `num_files=800` will process the first 800 sequences and i=800 and num_files=1600 will process the next 800.
1. Make sure that the jax version is compatible with the version of Alphafold you are using, i.e. use "jax:0.3.25 + jaxlib:0.3.25" with Alphafold 2.3.x and "jax:0.3.17 + jaxlib:0.3.14" with Alphafold 2.2.4
1. We also provide a modified version for the "run_alphafold.py" script, which stops predictions on a given sequence if the iptm values are extremely low to save time. 
