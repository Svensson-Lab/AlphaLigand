import pandas as pd
import pickle
import os
import array as a
import statistics
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('out_path', type=str, help="path to folder containing predictions/msas")
parser.add_argument('i', type=str, help="_")

args = parser.parse_args()

##change to work with flags
#out_path = "/home/groups/katrinjs/new_outs/"
#input_path = "/home/groups/katrinjs/inputs/"

outputdir = args.out_path
i = int(args.i)
version = 3

"""
# Output dir from from alphafold
outputdir="/home/groups/katrinjs/new_outs/"

#number of predictions
i=1
version = 3
"""
dirs = os.listdir(outputdir)
original_stdout = sys.stdout

#pickle_out = pickle.load(open(outputdir+dirs[1]+'/result_model_'+str(1)+'_multimer_v2_pred_0.pkl', 'rb'))
for x in dirs:
    pickle_iptm=a.array('f')
    for pred in range(1, i+1):
        try:
            path = outputdir + x +'/result_model_'+str(pred)+f'_multimer_v{version}_pred_1.pkl'
            pickle_out = pickle.load(open(path, 'rb'))
            pickle_out = pickle_out['iptm']
            pickle_iptm.append(pickle_out)

        except:
            break

    else:
        with open(f'ipTMs_{x}.csv', 'a') as f:
            sys.stdout = f
            print(x+',', end = '')
            print(*pickle_iptm,sep = ",")
            with open(f'ipTMs_{x}_penalized.csv', 'a') as f:
                sys.stdout = f
                try:
                    median_value = statistics.median(pickle_iptm)
                    median_absolute_deviation = median_value - statistics.median([abs(number-median_value) for number in pickle_iptm])

                except statistics.StatisticsError:
                    median_absolute_deviation = ''

                print(x+',', end = '')
                print(median_absolute_deviation)
                sys.stdout = original_stdout