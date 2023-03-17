This collection of scripts predicts the structures of a list of fasta files in a directory using [Slurm](https://slurm.schedmd.com/documentation.html).

## Installation
Follow "Setup and installation" for alphafold_non_docker by kalininalab [here](https://github.com/kalininalab/alphafold_non_docker).
## Usage

### Inputs
For both MSA computations and structure predictions, we use the same inputs:
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
If you wish to only (pre)compute MSAs for a given directory of fasta sequences, you can run the `compute_msa_parallel` script. [Link to precomputed MSAs](https://drive.google.com/file/d/1CzcO4JfKO8NrnVQvIKIQTCn__ha1ZWly/view?usp=share_link)

### Predictions
If you wish to do predictions AND MSAs, you can run the `run_predictions` script. Precomputed MSAs are searched for in the out directory by default, you can download MSAs from the link above. If there are no MSAs in the out directory, the prediction script will compute them as necessary.

### Tips and Possible Issues
1. If the number of sequences you are processing is high, there is a possibly that your HPC environment will not allow you to submit the whole library. To alleviate this, you can modify the `num_files` and `i` variables in the bash scripts to a more managable number. For example `i=0` and `num_files=800` will process the first 800 sequences and i=800 and num_files=1600 will process the next 800.
