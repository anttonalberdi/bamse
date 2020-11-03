#2020/10/22 - BAMSE 1.0
#UNDER CONSTRUCTION!

import subprocess
import argparse
import time

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-i', help="ASV fasta file", dest="input", required=True)
parser.add_argument('-o', help="Output match list", dest="match", required=True)
args = parser.parse_args()

input=args.input
output=args.match

matching = 'vsearch --usearch_global '+input+' --db '+input+' --self --id .84 --iddef 1 --userout '+output+' -userfields query+target+id --maxaccepts 0 --query_cov .9 --maxhits 10'
subprocess.Popen(matching, shell=True).wait()
