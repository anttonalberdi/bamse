import argparse
import subprocess
import os
import sys
import ruamel.yaml
import pathlib
import re

####################
# Argument parsing #
####################

parser = argparse.ArgumentParser(description='Runs bamse-dada2 pipeline.')
parser.add_argument('-i', help="Data information file", dest="input", required=True)
parser.add_argument('-d', help="Working directory of the project", dest="workdir", required=True)
parser.add_argument('-f', help="Forward primer sequence", dest="primF", required=True)
parser.add_argument('-r', help="Reverse primer sequence", dest="primR", required=True)
parser.add_argument('-a', help="Amplicon length", dest="ampliconlength", required=True)
parser.add_argument('-x', help="Absolute path to the taxonomy database", dest="tax", required=True)
parser.add_argument('-t', help="Number of threads", dest="threads", required=True)
parser.add_argument('-q', help="Desired minimum quality (phred) score", dest="minq", required=False)
parser.add_argument('-o', help="Desired minimum read overlap", dest="overlap", required=False)
parser.add_argument('-p', help="Absolute path to the parameters file that BAMSE will create", dest="param", required=False)
parser.add_argument('-l', help="Absolute path to the log file that BAMSE will create", dest="log", required=False)
args = parser.parse_args()

# Translate arguments
in_f=args.input
path=args.workdir
primF=args.primF
primR=args.primR
ampliconlength=args.ampliconlength
tax=args.tax
cores=args.threads

# Retrieve current directory
file = os.path.dirname(sys.argv[0])
curr_dir = os.path.abspath(file)

# Create workign directory if does not exist
if not os.path.exists(path):
    os.makedirs(path)

#Remove last / to the working directory (if necessary)
path = re.sub('/$','',path)

# Define minQ value
if not (args.minq):
    minq = 30
else:
    minq=args.minq

# Define minQ value
if not (args.overlap):
    overlap = 5
else:
    overlap=args.overlap

# Define param file
if not (args.param):
    param = os.path.join(os.path.abspath(path),"bamse.yaml")
else:
    param=args.param

# Define log file
if not (args.log):
    log = os.path.join(path,"bamse.log")
else:
    log=args.log

#Remove param file if exists
if os.path.exists(param):
    os.remove(param)


###################
# Create log file #
###################

logfile=open(log,"a+")
logfile.write("#####################")
logfile.write("#### BAMSE v1.0 #####")
logfile.write("#####################")
logfile.write("BAMSE is starting at:\n")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("\t{0}\n".format(current_time))
logfile.close()

#############################################
# Append information to the parameters file #
#############################################

#Append information to the parameters file
f = open(str(param), "a")
f.write("#BAMSE core paths\n")
f.write("bamsepath:\n "+str(curr_dir)+"\n")
f.write("projectpath:\n "+str(path)+"\n")
f.write("parampath:\n "+str(param)+"\n")
f.write("logpath:\n "+str(log)+"\n")
f.write("taxonomy:\n "+str(tax)+"\n")
f.write("\n#Primers\n")
f.write("primer1:\n "+str(primF)+"\n")
f.write("primer2:\n "+str(primR)+"\n")
f.write("\n#Trimming and filtering\n")
f.write("ampliconlength:\n "+str(ampliconlength)+"\n")
f.write("overlap:\n "+str(overlap)+"\n")
f.write("minq:\n "+str(minq)+"\n")
f.close()

#Append information to the log file
logfile=open(log,"a+")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("\nBAMSE will run with the following parameters:\n")
logfile.write("\t#Paths\n")
logfile.write("\tbamsepath:\n "+str(curr_dir)+"\n")
logfile.write("\tprojectpath:\n "+str(path)+"\n")
logfile.write("\tparampath:\n "+str(param)+"\n")
logfile.write("\tlogpath:\n "+str(log)+"\n")
logfile.write("\ttaxonomy:\n "+str(tax)+"\n")
logfile.write("#Primers\n")
logfile.write("\tprimer1:\n "+str(primF)+"\n")
logfile.write("\tprimer2:\n "+str(primR)+"\n")
logfile.write("#Trimming and filtering\n")
logfile.write("\tampliconlength:\n "+str(ampliconlength)+"\n")
logfile.write("\toverlap:\n "+str(overlap)+"\n")
logfile.write("\tminq:\n "+str(minq)+"\n")
logfile.close()

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

# Output log to logfile
logfile=open(log,"a+")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("{0} | Transferring data to the working directory \r\n".format(current_time))
logfile.close()

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
        ###Skip line if it's empty
        if not len(line.strip()) == 0 :

            #Define variables
            linelist = line.split(',') # Create a list of each line
            name=linelist[0]
            sample=linelist[1]
            run=linelist[2]
            in_for=linelist[3]
            in_rev=linelist[4]

            # Transfer, rename and decompress data

            #Check if the file is already in the working directory
            out1=path+'/0-Data/'+name+'_1.fastq'
            if os.path.isfile(out1):
                logfile=open(log,"a+")
                logfile.write("\tThe file " + out1 + " is already in the working directory.\n")
                logfile.close()
            else:
                #If the file is not in the working directory, transfer it
                if os.path.isfile(in_for):
                    if in_for.endswith('.gz'):
                        read1Cmd = 'gunzip -c '+in_for+' > '+path+'/0-Data/'+name+'_1.fastq'
                        subprocess.Popen(read1Cmd, shell=True).wait()
                    else:
                        read1Cmd = 'cp '+in_for+' '+path+'/0-Data/'+name+'_1.fastq'
                        subprocess.Popen(read1Cmd, shell=True).wait()
                else:
                    logfile=open(log,"a+")
                    logfile.write("\tThe file " + in_for + " does not exist.\n")
                    logfile.close()

            #Check if the file is already in the working directory
            out2=path+'/0-Data/'+name+'_2.fastq'
            if os.path.isfile(out1):
                logfile=open(log,"a+")
                logfile.write("\tThe file " + out2 + " is already in the working directory.\n")
                logfile.close()
            else:
                #If the file is not in the working directory, transfer it
                if os.path.isfile(in_rev):
                    if in_for.endswith('.gz'):
                        read2Cmd = 'gunzip -c '+in_rev+' > '+path+'/0-Data/'+name+'_2.fastq'
                        subprocess.Popen(read2Cmd, shell=True).wait()
                    else:
                        read2Cmd = 'cp '+in_rev+' '+path+'/0-Data/'+name+'_2.fastq'
                        subprocess.Popen(read2Cmd, shell=True).wait()
                else:
                    logfile=open(log,"a+")
                    logfile.write("\tThe file " + in_rev + " does not exist.\n")
                    logfile.close()

            #Create list of output files for preprocessing workflow
            out_for = path+'/2-Filtered/'+name+'_1.fastq'
            out_rev = path+'/2-Filtered/'+name+'_2.fastq'
            outlist.append(out_for)
            outlist.append(out_rev)

#Remove comma in the end of each row of the input file to return to initial condition
commaCmd = 'sed -i "$!s/,$//" '+in_f+''
subprocess.Popen(commaCmd, shell=True).wait()

curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)

#####################################################
################## Begin workflows ##################
#####################################################

##############################
# Run preprocessing workflow #
##############################

# Output log to logfile
logfile=open(log,"a+")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("{0} | Starting preprocessing workflow \r\n".format(current_time))
logfile.close()

path_snkf = os.path.join(bamsepath,'workflows/preprocessing/Snakefile')
#Transform output file list into space-separated string (only for development)
out_preprocessing = " ".join(outlist)

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_preprocessing+' --configfile '+param+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()

######################
# Run dada2 workflow #
######################

# Output log to logfile
logfile=open(log,"a+")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("{0} | Starting dada2 workflow \r\n".format(current_time))
logfile.close()

# Define output names
out_dada2 = path+'/ASV_counts.txt '+path+'/ASVs.fasta '+path+'/ASV_taxa.txt'
curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)
path_snkf = os.path.join(bamsepath,'workflows/dada2/Snakefile')

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_dada2+' --configfile '+param+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()

# Output log to logfile
logfile=open(log,"a+")
current_time = time.strftime("%m.%d.%y %H:%M", time.localtime())
logfile.write("{0} | BAMSE has completed succesfully \r\n".format(current_time))
logfile.close()
