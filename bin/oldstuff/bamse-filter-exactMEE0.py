import argparse
import Bio
from Bio import SeqIO

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-f', help="ASV fasta file", dest="forward_input", required=True)
parser.add_argument('-r', help="Output match list", dest="reverse_input", required=True)
parser.add_argument('-1', help="Output match list", dest="forward_output", required=True)
parser.add_argument('-2', help="Output match list", dest="reverse_output", required=True)
parser.add_argument('-l', help="Output match list", dest="length", required=True)
parser.add_argument('-e', help="Output match list", dest="error", required=True)
parser.add_argument('-o', help="Output match list", dest="overlap", required=True)
args = parser.parse_args()

forward_input=args.forward_input
reverse_input=args.reverse_input
forward_output=args.forward_output
reverse_output=args.reverse_output
length=args.length
error=args.error
overlap=args.overlap

#Calculate total minimum length required for filterin
minlength=int(length)-(int(overlap)*2)

#Define read length function
def maxEEpos(qual,EE):
	ee_vector=0
	pos=0
	while ee_vector <= EE and pos < len(qual):
		error=10**(-qual[pos]/10)
		ee_vector=ee_vector+error
		pos += 1
	return pos

#Load files
fastq_parser1 = SeqIO.parse(forward_input, "fastq")
fastq_parser2 = SeqIO.parse(reverse_input, "fastq")

#Trim reads and only print reads with minimum overlapping size
with open(forward_output, "w") as file1, open(reverse_output, "w") as file2:
	for read1, read2 in zip(fastq_parser1, fastq_parser2):
		pos1=maxEEpos(read1.letter_annotations["phred_quality"],int(error))
		pos2=maxEEpos(read2.letter_annotations["phred_quality"],int(error))
		read1=read1[0:pos1]
		read2=read2[0:pos2]
		totallen=len(read1)+len(read2)
		if int(totallen) > int(minlength):
			readout1=read1.format("fastq")
			readout2=read2.format("fastq")
			bytes = file1.write(readout1)
			bytes = file2.write(readout2)
