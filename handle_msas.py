##script to add msas needed for each multimer sequence to the out folder of 

import os 
import shutil
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('out_path', type=str, help="path to folder containing predictions/msas")
parser.add_argument('input_path', type=str, help='path to folder containing "Ligands" and "Receptors" folders')

args = parser.parse_args()

##change to work with flags
#out_path = "/home/groups/katrinjs/new_outs/"
#input_path = "/home/groups/katrinjs/inputs/"

out_path = args.out_path
input_path = args.input_path 

receptor_msa_path = os.path.join(out_path, "receptors_msas")
ligand_msa_path = os.path.join(out_path, "ligands_msas")
fasta_sequences_path = os.path.join(input_path, "fasta_sequences")

sequence_file_paths = [os.path.join(fasta_sequences_path, i) for i in os.listdir(fasta_sequences_path)]
sequence_names = os.listdir(fasta_sequences_path)

receptor_msas = [os.path.join(receptor_msa_path, i) for i in os.listdir(receptor_msa_path)] 

path2pair = {}

for i in range(len(sequence_file_paths)):
#for i in range(5):
  seq_name = sequence_names[i]
  try:
    os.mkdir(os.path.join(out_path, seq_name.split(".")[0]))
  
  except:
    pass

  ligand = seq_name.split('_')[0]
  receptor = seq_name.split('_')[1].split('.')[0]
  #path2pair[sequence_file_paths[i]] = {"ligand":ligand, "receptor"} 
  for r in os.listdir(receptor_msa_path):
     if receptor == r:
       #print(seq_name)
       files = os.listdir(os.path.join(receptor_msa_path, receptor+"/msas"))
       
       try:
         shutil.copytree(receptor_msa_path + "/" + r + "/" + "msas" + "/" + files[0], out_path + "/" + seq_name.split(".")[0] + "/B") 
       except:
         print(f"Did not copy receptor MSA for {seq_name} because it already exists")

  for l in os.listdir(ligand_msa_path):
    if ligand == l:
       files = os.listdir(os.path.join(receptor_msa_path, ligand+"/msas")) #chain_id and A files 

       try:
         shutil.copytree(receptor_msa_path + "/" + r + "/" + "msas" + "/" + files[0], out_path + "/" + seq_name.split(".")[0] + "/A")
       except:
         print(f"Did not copy receptor MSA for {seq_name} because it already exists")  
