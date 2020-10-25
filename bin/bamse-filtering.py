#2020/10/22 - BAMSE 1.0

import argparse
import subprocess

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-i1', help="Input forward file", dest="input1", required=True)
parser.add_argument('-i2', help="Input reverse file", dest="input2", required=True)
parser.add_argument('-o1', help="Output forward file", dest="output1", required=True)
parser.add_argument('-o2', help="Output reverse file", dest="output2", required=True)
parser.add_argument('-q', help="truncQ in dada2", dest="truncq", required=True)
parser.add_argument('-l', help="truncLen in dada2", dest="truncl", required=True)
parser.add_argument('-n', help="maxN in dada2", dest="maxn", required=True)
parser.add_argument('-e', help="maxEE in dada2", dest="maxee", required=True)

args = parser.parse_args()

input1=args.input1
input2=args.input1
output1=args.output1
output2=args.output2
truncq=args.truncq
truncl=args.truncl
maxn=args.maxn
maxee=args.maxee

#####
# Perform filtering and trimming
#####

trim_filt = 'module load tools gcc R/3.4.0 && export i1='+input1+' && i2='+input2+' && export o1='+output1+' && export o2='+output2+' && export q='+truncq+' && export l='+truncl+' && export n='+maxn+' && export e='+maxee+' && Rscript --vanilla -f '+bamsepath+'/bin/bamse-filtering.R'
subprocess.Popen(trim_filt, shell=True).wait()
