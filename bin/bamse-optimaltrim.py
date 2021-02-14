import argparse
import Bio
from Bio import SeqIO
import statistics
import numpy as np
import random

#Argument parsing
parser = argparse.ArgumentParser(description='Runs primer trimming script.')
parser.add_argument('-f', help="Forward read", dest="forward_input", required=True)
parser.add_argument('-r', help="Reverse read", dest="reverse_input", required=True)
parser.add_argument('-l', help="Amplicon length", dest="length", required=True)
parser.add_argument('-e', help="Maximum Expected Error per read", dest="maxEE", required=True)
parser.add_argument('-v', help="Overlap value", dest="overlap", required=True)
parser.add_argument('-m', help="Maximum number of reads to be analysed", dest="maxreads", required=True)
parser.add_argument('-o', help="Output score file", dest="output", required=True)
args = parser.parse_args()

forward_input=args.forward_input
reverse_input=args.reverse_input
length=int(args.length)
maxEE=int(args.maxEE)
overlap=int(args.overlap)
output=args.output
maxreads=int(args.maxreads)

#forward_input="/Users/anttonalberdi/bamse_evie/1-Primertrimmed/B/GM4.P10_r2_1.fastq"
#reverse_input="/Users/anttonalberdi/bamse_evie/1-Primertrimmed/B/GM4.P10_r2_2.fastq"

#Load fastq files
fastq_parser1 = SeqIO.parse(forward_input, "fastq")
fastq_parser2 = SeqIO.parse(reverse_input, "fastq")

#Calculate read length
read1lenlist=[]
read2lenlist=[]
for read1, read2 in zip(fastq_parser1, fastq_parser2):
	read1len=len(read1)
	read2len=len(read2)
	read1lenlist.append(read1len)
	read2lenlist.append(read2len)

#Average read length
read1len=int(statistics.mean(read1lenlist))
read2len=int(statistics.mean(read2lenlist))

#Maximum read length
read1lenmax=int(max(read1lenlist))
read2lenmax=int(max(read2lenlist))

minlength=int(length)+(int(overlap)*2)

read1exc=minlength-read1len
read2exc=minlength-read2len

#If reads cannot be trimmed
if (read1exc > read1len) or (read2exc > read2len):
	valuedb=np.array(['NA',read1len,read2len])
	#Save table
	np.savetxt(output, valuedb.reshape(1, valuedb.shape[0]), delimiter=",", fmt='%s')

#If reads can be trimmed:
else:
	#Get potential trimming sites in read1
	read1pottrim = []
	for x in range(read2exc+1,(minlength-read1exc)):
		read1pottrim.append(x)

	#Get potential trimming sites in read2
	read2pottrim = []
	for x in range(read1exc+1,(minlength-read2exc)):
		read2pottrim.append(x)

	#Reverse read2 list
	def reverse(list):
	    return [ele for ele in reversed(list)]

	read2pottrim = reverse(read2pottrim)

	#Check if lists look OK
	#[x + y for x, y in zip(read1pottrim, read2pottrim)] > YES!

	#Define estimated error probability function
	def EE(qual):
		ee_vector=0
		pos=0
		while pos < len(qual)-1:
			error=10**(-qual[pos]/10)
			ee_vector=ee_vector+error
			pos += 1
		return ee_vector

	#Calculate error values per trimming length
	fastq_parser1 = list(SeqIO.parse(forward_input, "fastq"))
	fastq_parser2 = list(SeqIO.parse(reverse_input, "fastq"))

	#Check if the maximum number of reads to be analysed is higher than the number of reads,
	#and reduce to number of reads if so.
	if maxreads > len(read1lenlist):
		maxreads=len(read1lenlist)

	#Create a random list of indices for subsampling reads
	randomlist=random.sample(range(0, maxreads), maxreads)

	readn=0
	elist_read=[]
	for x in range(0, maxreads):
		read1=fastq_parser1[x]
		read2=fastq_parser2[x]
		if readn < maxreads:
			elist_pos=[]
			for cut1, cut2 in zip(read1pottrim,read2pottrim):
				read1trim=read1[0:cut1]
				read2trim=read2[0:cut2]
				e1=round(EE(read1trim.letter_annotations["phred_quality"]),5)
				e2=round(EE(read2trim.letter_annotations["phred_quality"]),5)
				e=e1+e2
				if e1 < maxEE or e2 < maxEE:
					keep=1
				else:
					keep=0
				eunit=[readn,cut1,cut2,e1,e2,e,keep]
				elist_pos.append(eunit)
			elist_read.append(elist_pos)
			readn += 1
		else:
			break

	#Transform nested least into Numpy array
	earray_read = np.array(elist_read)
	#earray_read.shape

	#Get average error values and summatory read keeping values
	earray_avg=np.average(earray_read[:,],axis=0)
	earray_sum=np.sum(earray_read[:,],axis=0)
	trimpos1=earray_avg[:,1]
	trimpos2=earray_avg[:,2]
	read1_avgE=earray_avg[:,3]
	read2_avgE=earray_avg[:,4]
	reads_avgE=earray_avg[:,5]
	keep_raw=earray_sum[:,6]
	keep=keep_raw*100/readn
	#Figaro score
	#score=keep-(((read1_avgE-1)**2)+((read2_avgE-1)**2))
	score=keep-reads_avgE

	#Create position-score table
	valuedb=np.transpose(np.vstack((np.round(score,4),trimpos1.astype(int),trimpos2.astype(int))))

	#Save table
	np.savetxt(output, valuedb, fmt='%f,%i,%i')
