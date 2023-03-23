The collection of scripts in this repository predicts the structures of protein-multimers using lists of fasta files in a directory using [Slurm](https://slurm.schedmd.com/documentation.html).

## Installation
1. Install miniconda:<br> 
`wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh` 
1. Clone this repository: <br> 
`git clone git@github.com:Svensson-Lab/run-hpc-alphafold.git` <br> 
`cd run-hpc-alphafold`
1. Install requirements <br> 
`conda create --name alphafold --file req.txt` 
1. Activate environment: <br>
`conda activate alphafold`
## Usage

### Inputs
To provide your paths to each script please edit the necessary parts of either the `predict_structures` or the `compute_msa_parallel` files. For both MSA computations and structure predictions, we use the same inputs: (these inputs are the only parts of the script you will need to edit)
```
fasta_path="inputs" #path to receptor fasta files 
run_parafold_path="run_parafold_no_template.sh" #path to run_parafold_no_template.sh script

out_dir="/home/groups/katrinjs/predictions" #directory to write to
data_dir="$OAK/alphafold_data" #directory to alphafold database folder, (make sure not to have "/" at the end)  
logdir=$out_dir #directory to write logs to, same as outdir by default
```
1. `fasta_path` is the directory of fasta files that will be processed.
1. `run_parafold_path` is the script to run alphafold, unless you have a specific modification there is no need to change this.
1. `out_dir` is the directory to write MSAs and predictions to.
1. `data_dir` is the directory to alphafold database folder, (make sure not to have a "/" at the end)
1. `logdir` is directory to write logs to, same as outdir by default

### Compute MSAs 
If you wish to only (pre)compute MSAs for a given directory of fasta sequences, run the `compute_msa_parallel` script. [Link to precomputed MSAs](https://drive.google.com/file/d/1CzcO4JfKO8NrnVQvIKIQTCn__ha1ZWly/view?usp=share_link). Then after editing to file according to the "Inputs" heading, you can call `./compute_msa_parallel`.

### Predictions
If you wish to do predictions AND MSAs, you can run the `predict_structures.sh` script. Precomputed MSAs located in the out directory is used by default, you can download MSAs for the library described in (https://www.biorxiv.org/content/10.1101/2023.03.16.531341v1) from the link above. If there are no MSAs in the out directory, the prediction script will compute them as necessary. Then after editing to file according to the "Inputs" heading, you can call `./predict_structures.sh`.

### Tips and Possible Issues
1. If the number of sequences you are processing is high, there is a possibly that your HPC environment will not allow you to submit the whole library. To solve this you can modify the `num_files` and `i` variables in the bash scripts to run fewer simultaneous predictions. For example `i=0` and `num_files=800` will process the first 800 sequences and i=800 and num_files=1600 will process the next 800.
