import mdtraj as md
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import subprocess
import glob
from typing import List 
import argparse

def extract_af_metrics(pred_folder: str, receptor_chains: List[int], ligand_chains: List[int], relaxed: bool = True, pred_is_nested: bool = False, peptide_template_pdb: str = None):
    '''
    Extract ranking metrics from an AlphaFold-Multimer result.
    pred_folder: 
        result directory (AlphaFold output)
    receptor_chains:
        chain ids belonging to the receptor
    ligand_chains:
        chain ids belonging to the peptide
    relaxed:
        Whether the AlphaFold results was relaxed or not.
    pred_is_nested:
        (Legacy) indicates that pred_folder contains the results in subdirectories
    peptide_template_pdb:
        A PDB file of the ligand. If provided, report TMscore to this structure in the output. Requires tmtools.
    '''
    
    df = pd.DataFrame({})
    relaxed_str = 'relaxed' if relaxed else 'unrelaxed'
    
    # depending on the dir structure, we need different globbing
    # True  pred_folder/XX/*_model_*.pdb
    # False pred_folder/*_model_*.pdb
    if pred_is_nested:
        pdb_files = [f for f in glob.glob(os.path.join(pred_folder, f'*/{relaxed_str}_model_*.pdb'))]
    else:
        pdb_files = [f for f in glob.glob(os.path.join(pred_folder, f'*{relaxed_str}_model_*.pdb'))]
    pdb_files = np.asarray(pdb_files)
    
    for pdb_file in pdb_files:
        _, _, model_id, _, _, _, sample_id = pdb_file.split('/')[-1].split('_')
        sample_id = sample_id.split('.')[0]
        model_num = f'{model_id}-{sample_id}'
        df.at[model_num, 'pred_folder'] = pred_folder
        
        # Open pickle file
        #pickle_file = [f for f in glob.glob(os.path.join( os.path.dirname(pdb_file), 'result_model_' + str(model_num) + '*.pkl'))][0]		pickle_file = os.path.join( os.path.dirname(pdb_file), f'result_model_{model_id}_multimer_v2_pred_{sample_id}.pkl')

        pickle_file = os.path.join( os.path.dirname(pdb_file), f'result_model_{model_id}_multimer_v2_pred_{sample_id}.pkl')
        prediction = pd.read_pickle(pickle_file)
        
        #df.at[model_num, 'pdockq'] = compute_pdockq(pdb_file, pickle_file)
        
        # Extract ptm, iptm and ranking confidence
        df.at[model_num, 'ptm'] = prediction['ptm']
        df.at[model_num, 'iptm'] = prediction['iptm']
        df.at[model_num, 'ranking_confidence'] = prediction['ranking_confidence']
        
        # Extract plddt and PAE average over binding interface
        model_mdtraj = md.load(pdb_file)
        table, bonds = model_mdtraj.topology.to_dataframe()
        table = table[(table['name']=='CA')]
        table['residue'] = np.arange(0, len(table))
        receptor_res = table[table['chainID'].isin(receptor_chains)]['residue']
        ligand_res = table[table['chainID'].isin(ligand_chains)]['residue']
        input_to_calc_contacts = []
        for i in ligand_res:
            for j in receptor_res:
                input_to_calc_contacts.append([i,j])
        contacts, input_to_calc_contacts = md.compute_contacts(model_mdtraj, contacts=input_to_calc_contacts, scheme='closest', periodic=False)
        receptor_res_in_contact = []
        ligand_res_in_contact = []
        
        for i in input_to_calc_contacts[np.where(contacts[0]<0.35)]: # threshold in nm
            ligand_res_in_contact.append(i[0])
            receptor_res_in_contact.append(i[1])
        receptor_res_in_contact, receptor_res_counts = np.unique(np.asarray(receptor_res_in_contact), return_counts=True)
        ligand_res_in_contact, ligand_res_counts = np.unique(np.asarray(ligand_res_in_contact), return_counts=True)
        
        if len(ligand_res_in_contact) > 0:
            df.at[model_num, 'plddt_ligand'] = np.median(prediction['plddt'][ligand_res_in_contact])
            df.at[model_num, 'plddt_receptor'] = np.median(prediction['plddt'][receptor_res_in_contact])
            
            df.at[model_num, 'PAE'] = np.median(prediction['predicted_aligned_error'][receptor_res_in_contact,:][:,ligand_res_in_contact])
        
        if peptide_template_pdb is not None:
            df.at[model_num, 'tm_score'] = get_tm_score(pdb_file, peptide_template_pdb)
    
    return df
 
if __name__ == "__main__":
	"""
	#uncomment this if you want to input the out_path via command line, and comment out out_path below 
	parser = argparse.ArgumentParser()
	parser.add_argument('out_path', type=str, help="path to folder containing predictions/msas")
	
	args = parser.parse_args()
	out_path = args.out_path
	"""
	
	#folder containing output folder for each sequence
	out_path = "/home/groups/katrinjs/new_outs/"

	#print df if True
	print_ = True

	#directory to save csv of the metrics to, leave "" if you don't want to save
	save_dir = ""

	for f in os.listdir(out_path):
		if "." in f or f in ["receptors_msas", "ligands_msas"]:
			continue

		
		df = extract_af_metrics(os.path.join(out_path, f), [0], [1])
		if save_dir: df.to_csv(save_dir + f"/{f}.csv")
		if print_:
			print(f)
			print(df)
