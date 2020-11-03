#2020/10/22 - BAMSE 1.0
#UNDER CONSTRUCTION!

import subprocess
import argparse
import time

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-f', help="ASV fasta file", dest="fasta", required=True)
parser.add_argument('-t', help="ASV table", dest="table", required=True)
parser.add_argument('-m', help="Output match list", dest="match", required=True)
args = parser.parse_args()

fasta=args.fasta
table=args.table
match=args.match




vsearch --usearch_global OTU_sequences.fasta --db OTU_sequences.fasta --self --id .84 --iddef 1 --userout match_list.txt -userfields query+target+id --maxaccepts 0 --query_cov .9 --maxhits 10

curated_result <- lulu(otutable_name, matchlist_name)
