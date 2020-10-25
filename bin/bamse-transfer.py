## bamse-transfer
# Transfers the data, rename and if necessary decompress them.
# Author: Antton Alberdi (antton.alberdi@sund.ku.dk)
# Date: 2020/10/23
# Last modification: 2020/10/23

import subprocess
import argparse

#Argument parsing
parser = argparse.ArgumentParser(description='Transfer data, rename and decompress (if needed).')
parser.add_argument('-1', help="path1", dest="read1", required=True)
parser.add_argument('-2', help="path2", dest="read2", required=True)
parser.add_argument('-d', help="destination path", dest="path", required=True)
parser.add_argument('-n', help="destination name", dest="name", required=True)
args = parser.parse_args()

input_file=args.input
read1=args.read1
read2=args.read2
path=args.path
name=args.name

#Transfer files
if path1.endswith('.gz'):
    copy1Cmd = 'gunzip -c '+read1+' > '+path+'/'+name+'_1.fastq'
    subprocess.check_call(copy1Cmd, shell=True)
    else:
        copy1Cmd = 'cp '+read1+' '+path+'/'+name+'_1.fastq'
        subprocess.check_call(copy1Cmd, shell=True)

if path2.endswith('.gz'):
    copy2Cmd = 'gunzip -c '+read2+' > '+path+'/'+name+'_2.fastq'
    subprocess.check_call(copy1Cmd, shell=True)
    else:
        copy2Cmd = 'cp '+read2+' '+path+'/'+name+'_2.fastq'
        subprocess.check_call(copy2Cmd, shell=True)
