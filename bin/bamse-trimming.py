#2020/10/22 - BAMSE 1.0

import subprocess
import argparse

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-1', help="path1", dest="read1", required=True)
parser.add_argument('-2', help="path2", dest="read2", required=True)
parser.add_argument('-si', help="stats input file", dest="in_stats", required=True)
parser.add_argument('-so', help="stats output file", dest="out_stats", required=True)
args = parser.parse_args()

input_file=args.input
read1=args.read1
read2=args.read2
in_stats=args.in_stats
out_stats=args.out_stats

trimm1Cmd = 'script here'
subprocess.check_call(trimm1Cmd, shell=True)
trimm2Cmd = 'script here'
subprocess.check_call(trimm2Cmd, shell=True)
