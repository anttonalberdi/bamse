import argparse
import Bio
from Bio import SeqIO
from Bio import Seq
from Bio.Seq import Seq
from Bio.Alphabet import generic_dna

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

#Calculate total minimum length required for filtering
minlength=int(length)+(int(overlap)*2)

#Define read length function
def maxEEpos(qual,EE):
	ee_vector=0
	pos=0
	while ee_vector <= EE and pos < len(qual)-1:
		error=10**(-qual[pos]/10)
		ee_vector=ee_vector+error
		pos += 1
	return pos

def EE(qual):
	ee_vector=0
	pos=0
	while pos < len(qual)-1:
		error=10**(-qual[pos]/10)
		ee_vector=ee_vector+error
		pos += 1
	return ee_vector

#Load files
fastq_parser1 = SeqIO.parse(forward_input, "fastq")
fastq_parser2 = SeqIO.parse(reverse_input, "fastq")

#Trim reads and only print reads with minimum overlapping size
with open(forward_output, "w") as file1, open(reverse_output, "w") as file2:
	for read1, read2 in zip(fastq_parser1, fastq_parser2):
		pos1=maxEEpos(read1.letter_annotations["phred_quality"],int(error))
		pos2=maxEEpos(read2.letter_annotations["phred_quality"],int(error))
		read1trim1=read1[0:pos1]
		read2trim1=read2[0:pos2]
        #Calculate total length summing both reads
		totallen=int(len(read1trim1)+len(read2trim1))
        #Calculate excess of nucleotides based on minimum length
		excess=totallen-minlength
        #If excess is positive, find best trimming strategy
		if excess > 0:
			read1len=len(read1trim1)
			read2len=len(read2trim1)
			read1exc = []
			for x in range(read1len-excess,read1len-1):
				read1exc.append(x)
			read2exc = []
			for x in reversed(range(read2len-excess,read2len-1)):
				read2exc.append(x)
			trimposlist=[]
			for cut1, cut2 in zip(read1exc,read2exc):
				read1test=read1[0:cut1]
				qual1=EE(read1test.letter_annotations["phred_quality"])
				read2test=read2[0:cut2]
				qual2=EE(read2test.letter_annotations["phred_quality"])
				qual=(qual1+qual2)/2
				list=[cut1,cut2,qual]
				trimposlist.append(list)
			best=sorted(trimposlist, key = lambda x: x[2])
			try:
				read1cut=best[1][0]
				read2cut=best[1][1]
				read1trim2=read1trim1[0:read1cut]
				read2trim2=read2trim1[0:read2cut]
			except IndexError:
				read1trim2=read1trim1
				read2trim2=read2trim1
		if totallen > minlength:
			if (Seq("N") not in read1) & (Seq("N") not in read2):
				readout1=read1trim2.format("fastq")
				readout2=read2trim2.format("fastq")
				bytes = file1.write(readout1)
				bytes = file2.write(readout2)
