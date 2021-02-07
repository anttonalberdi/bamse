#2020/10/25 - BAMSE 1.0

import subprocess
import argparse
import time

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-i', help="Read subset", dest="input", required=True)
parser.add_argument('-l', help="Trimming length file", dest="trimfile", required=True)
parser.add_argument('-o', help="Trimmed read", dest="output", required=True)
args = parser.parse_args()

input=args.input
trimfile=args.trimfile
output=args.output


with open(input) as f:
    fastqlines = f.read().splitlines()

with open(trimfile) as f:
    trunclengthlines = f.read().splitlines()

#Create truncation length per line
trunclengthlines2 = []
for i in trunclengthlines:
    trunclengthlines2.extend([1000, i, 1, i])

#Truncate lines
finalfastqlines=[]
length=len(fastqlines)
for x in range(0,length):
  trunc=int(trunclengthlines2[x])
  if fastqlines[x] == '+':
    line='+'
  else:
    line=fastqlines[x][0:(trunc-1)]
  finalfastqlines.append(line)

with open(output, 'w+') as f:
  for line2 in finalfastqlines:
    f.write(line2 + '\n')
