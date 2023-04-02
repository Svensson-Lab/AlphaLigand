import os 
import sys

if __name__ == "__main__":
    input_path = sys.argv[1]
    folders = os.listdir(input_path)
    
    if 'Ligands' not in folders:
          raise Exception(f"Ligands folder not found in '{input_path}'")
          
    if 'Receptors' not in folders:
          raise Exception(f"Receptors folder not found in '{input_path}'")

    #make folder for concatenated sequence files
    fasta_sequences = os.path.join(input_path, "fasta_sequences")
    try:
        os.mkdir(fasta_sequences)
        
    except:
        raise Exception(f"{fasta_sequences} already exists, delete this folder if you'd like to re-format the fasta files")
    
    ligands_folder = os.listdir(os.path.join(input_path, "Ligands"))
    receptors_folder = os.listdir(os.path.join(input_path, "Receptors"))
    
    ligands_fastas = list(filter(lambda x: '.fasta' in x, ligands_folder))
    receptors_fastas = list(filter(lambda x: '.fasta' in x, receptors_folder))
    
    for ligand in ligands_fastas:
        name = ligand.split('.')[0]
        for receptor in receptors_fastas:
            newName = f"{name}_{receptor}"
            file = open(os.path.join(fasta_sequences, newName), 'a')
            ligand_content = open(os.path.join(os.path.join(input_path, "Ligands"), ligand)).read()
            file.write(ligand_content)
            file.write('\n')
            receptor_content = open(os.path.join(os.path.join(input_path, "Receptors"), receptor)).read()
            file.write(receptor_content)
            file.close()