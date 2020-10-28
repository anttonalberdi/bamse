import argparse
import subprocess
import os
import sys
import ruamel.yaml
import pathlib

####################
# Argument parsing #
####################

parser = argparse.ArgumentParser(description='Runs bamse-dada2 pipeline.')
parser.add_argument('-i', help="Data information file", dest="input", required=True)
parser.add_argument('-d', help="Working directory of the project", dest="workdir", required=True)
parser.add_argument('-f', help="Forward primer sequence", dest="primF", required=True)
parser.add_argument('-r', help="Reverse primer sequence", dest="primR", required=True)
parser.add_argument('-x', help="Absolute path to the taxonomy database", dest="tax", required=True)
parser.add_argument('-t', help="Number of threads", dest="threads", required=True)
parser.add_argument('-q', help="Desired minimum quality (phred) score", dest="minq", required=False)
parser.add_argument('-p', help="Absolute path to the parameters file that BAMSE will create", dest="param", required=False)
parser.add_argument('-l', help="Absolute path to the log file that BAMSE will create", dest="log", required=False)
args = parser.parse_args()

# Translate arguments
in_f=args.input
path=args.workdir
primF=args.primF
primR=args.primR
tax=args.tax
cores=args.threads

# Retrieve current directory
file = os.path.dirname(sys.argv[0])
curr_dir = os.path.abspath(file)

# Create workign directory if does not exist
if not os.path.exists(path):
    os.makedirs(path)

# Define minQ value
if not (args.minq):
    minq = 30
else:
    param=args.minq

# Define param file
if not (args.param):
    param = os.path.join(os.path.abspath(curr_dir),"bamse.yaml")
else:
    param=args.param

# Define log file
if not (args.log):
    log = os.path.join(path,"bamse.log")
else:
    log=args.log

#Append information to the parameters file
f = open(str(param), "a")
f.write("BAMSE core paths\n")
f.write("bamsepath="+str(curr_dir)+"\n")
f.write("logpath="+str(log)+"\n")
f.write("taxonomy="+str(tax)+"\n")
f.close()

###############################
# Prepare working directories #
###############################

# Set input directory
dir0 = os.path.join(path,"0-Data")
#dir1 = os.path.join(path,"1-Trimmed")
#dir2 = os.path.join(path,"2-Filtered")

## If input directory does not exist, make it
if not os.path.exists(dir0):
    os.makedirs(dir0)
#if not os.path.exists(dir1):
#    os.makedirs(dir1)
#if not os.path.exists(dir2):
#    os.makedirs(dir2)

#################
# Transfer data #
#################


#Add comma in the end of each row of the input file to avoid downstream issues
commaCmd = 'sed -i "$!s/$/,/" '+in_f+''
subprocess.Popen(commaCmd, shell=True).wait()

# Read input data file
inputfile = open(in_f, "r")

#Declare empty output file list
outlist = []

## Read input data row by row
for line in inputfile:
    ### Skip line if starts with # (comment line)
    if not (line.startswith('#')):

        #Define variables
        linelist = line.split(',') # Create a list of each line
        name=linelist[0]
        sample=linelist[1]
        run=linelist[2]
        in_for=linelist[3]
        in_rev=linelist[4]

        # Transfer, rename and decompress data
        if os.path.isfile(in_for):
            if in_for.endswith('.gz'):
                read1Cmd = 'gunzip -c '+in_for+' > '+path+'/0-Data/'+name+'_1.fastq'
                subprocess.Popen(read1Cmd, shell=True).wait()
            else:
                read1Cmd = 'cp '+in_for+' '+path+'/0-Data/'+name+'_1.fastq'
                subprocess.Popen(read1Cmd, shell=True).wait()
        else:
            print('The file ' + in_for + 'does not exist.')

        if os.path.isfile(in_rev):
            if in_for.endswith('.gz'):
                read2Cmd = 'gunzip -c '+in_rev+' > '+path+'/0-Data/'+name+'_2.fastq'
                subprocess.Popen(read2Cmd, shell=True).wait()
            else:
                read2Cmd = 'cp '+in_rev+' '+path+'/0-Data/'+name+'_2.fastq'
                subprocess.Popen(read2Cmd, shell=True).wait()
        else:
            print('The file ' + in_rev + 'does not exist.')

        #Calculate read length and add to config file
        #[TO BE DONE!]

        #Create list of output files (only for development)
        out_for = path+'/2-Filtered/'+name+'_1.fastq'
        out_rev = path+'/2-Filtered/'+name+'_2.fastq'
        outlist.append(out_for)
        outlist.append(out_rev)

#Remove comma in the end of each row of the input file to return to initial condition
commaCmd = 'sed -i "$!s/,$//" '+in_f+''
subprocess.Popen(commaCmd, shell=True).wait()

curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)

#################
# Begin workflows
#################

print("BAMSE dada2 is starting\n\t\tMay the force be with you.")

##############################
# Run preprocessing workflow #
##############################

path_snkf = os.path.join(bamsepath,'workflows/preprocessing/Snakefile')
#Transform output file list into space-separated string (only for development)
out_preprocessing = " ".join(outlist)

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_preprocessing+' --configfile '+param+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()

######################
# Run dada2 workflow #
######################

# Define output names
out_dada2 = path+'/ASV_counts.txt '+path+'/ASVs.fasta '+path+'/ASV_taxa.txt'
curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)
path_snkf = os.path.join(bamsepath,'workflows/dada2/Snakefile')

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_dada2+' --configfile '+param+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()
