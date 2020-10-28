#2020/10/22 - BAMSE 1.0

import subprocess
import argparse

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-i1', help="Input forward file", dest="input1", required=True)
parser.add_argument('-i2', help="Input reverse file", dest="input2", required=True)
parser.add_argument('-o1', help="Output forward file", dest="output1", required=True)
parser.add_argument('-o2', help="Output reverse file", dest="output2", required=True)
parser.add_argument('-p1', help="Forward primer sequence", dest="primer1", required=True)
parser.add_argument('-p2', help="Reverse primer sequence", dest="primer2", required=True)
args = parser.parse_args()

input1=args.input1
input2=args.input1
output1=args.output1
output2=args.output2
primer1=args.primer1
primer2=args.primer2

#####
# Trim primers
#####

mode = 'ligation'

cutadapt --pair-adapters -e 0.2 -g ^CTANGGGNNGCANCAG -G ^GACTACNNGGGTATCTAAT --discard-untrimmed -o output1.fastq -p output2.fastq bamse3/0-Data/Datafile2_1.fastq bamse3/0-Data/Datafile2_2.fastq


cutadapt --pair-adapters -e 0.2 -g ^GACTACNNGGGTATCTAAT -G ^CTANGGGNNGCANCAG --discard-untrimmed -o output1.fastq -p output2.fastq bamse3/0-Data/Datafile2_1.fastq bamse3/0-Data/Datafile2_2.fastq


if mode == 'ligation':
    trim_ligation1 = 'module load tools anaconda3/4.4.0 && cutadapt --pair-adapters -e 0.2 -g ^'+primer1+' -G ^'+primer2+' --discard-untrimmed -o '+output1+'_a -p '+output2+'_a '+input1+' '+input2+''
    subprocess.Popen(trim_ligation1, shell=True).wait()
    trim_ligation2 = 'module load tools anaconda3/4.4.0 && cutadapt --pair-adapters -e 0.2 -g ^'+primer2+' -G ^'+primer1+' --discard-untrimmed -o '+output1+'_b -p '+output2+'_b '+input1+' '+input2+''
    subprocess.Popen(trim_ligation2, shell=True).wait()
    trim_ligation3 = 'cat '+output1+'_a '+output2+'_b > '+output1+''
    subprocess.Popen(trim_ligation3, shell=True).wait()
    trim_ligation4 = 'cat '+output2+'_a '+output1+'_b > '+output2+''
    subprocess.Popen(trim_ligation4, shell=True).wait()
    trim_ligation5 = 'rm '+output1+'_a '+output1+'_b '+output2+'_a '+output2+'_b'
    subprocess.Popen(trim_ligation5, shell=True).wait()

else:
    trim_PCR = 'module load tools anaconda3/4.4.0 && cutadapt -e 0.5 -g ^'+primer1+' -G ^'+primer2+' --discard-untrimmed -o '+output1+' -p '+output2+' '+input1+' '+input2+''
    subprocess.check_call(trim_PCR, shell=True)
