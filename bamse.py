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
parser.add_argument('-f', help="input.txt file", dest="input", required=True)
parser.add_argument('-d', help="temp files directory path", dest="workdir", required=True)
parser.add_argument('-x', help="taxonomy database", dest="tax", required=True)
parser.add_argument('-t', help="threads", dest="threads", required=True)
parser.add_argument('-c', help="config file", dest="config_preprocessing", required=False)
parser.add_argument('-r', help="config file", dest="config_dada2", required=False)
parser.add_argument('-p', help="comma separated primer sequences", dest="prim", required=False)
parser.add_argument('-l', help="pipeline log file", dest="log", required=False)
args = parser.parse_args()

# Translate arguments
in_f=args.input
path=args.workdir
cores=args.threads
tax=args.tax

# Retrieve current directory
file = os.path.dirname(sys.argv[0])
curr_dir = os.path.abspath(file)

# Create workign directory if does not exist
if not os.path.exists(path):
    os.makedirs(path)

# Define config files
if not (args.config_preprocessing):
    config_preprocessing = os.path.join(os.path.abspath(curr_dir),"workflows/preprocessing/config.yaml")
else:
    config_preprocessing=args.config_preprocessing

if not (args.config_dada2):
    config_dada2 = os.path.join(os.path.abspath(curr_dir),"workflows/dada2/config.yaml")
else:
    config_dada2=args.config_dada2

# Define log file
if not (args.log):
    log = os.path.join(path,"bamse-dada2.log")
else:
    log=args.log

# Define primers
if not (args.prim):
    prim = "CTANGGGNNGCANCAG,GACTACNNGGGTATCTAAT"
else:
    prim=args.prim

# Split primers
primsplit = prim.split(",")
prim_f = primsplit[0]
prim_r = primsplit[1]

#Append current directory to .yaml config for standalone calling
yaml = ruamel.yaml.YAML()
yaml.explicit_start = True
with open(str(config_preprocessing), 'r') as config_file:
    data = yaml.load(config_file)
    if data == None:
        data = {}

with open(str(config_preprocessing), 'w') as config_file:
    data['bamsepath'] = str(curr_dir)
    data['logpath'] = str(log)
    data['taxonomy'] = str(tax)
    dump = yaml.dump(data, config_file)

with open(str(config_dada2), 'r') as config_file:
    data = yaml.load(config_file)
    if data == None:
        data = {}

with open(str(config_dada2), 'w') as config_file:
    data['bamsepath'] = str(curr_dir)
    data['logpath'] = str(log)
    data['taxonomy'] = str(tax)
    dump = yaml.dump(data, config_file)

#############################
# Prepare working directories #
#############################


# Set input directory
dir0 = os.path.join(path,"0-Data")
dir1 = os.path.join(path,"1-Trimmed")
dir2 = os.path.join(path,"2-Filtered")

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

print(path)

def read_input(path,in_f):

    #Add comma in the end of each row of the input file to avoid downstream issues
    commaCmd = 'sed -i "$!s/$/,/" '+in_f+''
    subprocess.Popen(commaCmd, shell=True).wait()

    # Read input data file
    inputfile = open(in_f, "r")

    #Declare empty output file list
    outlist = []

    ## Read input data row by row
    for line in inputfile:
        print(line)
        ### Skip line if starts with # (comment line)
        if not (line.startswith('#')):

            #Define variables
            linelist = line.split(',') # Create a list of each line
            name=linelist[0]
            sample=linelist[1]
            run=linelist[2]
            in_for=linelist[3]
            in_rev=linelist[4]
            print(name)
            print(in_for)
            print(in_rev)

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

            #Create list of output files (only for development)
            out_for = path+'/2-Filtered/'+name+'_1.fastq'
            out_rev = path+'/2-Filtered/'+name+'_2.fastq'
            out = [out_for,out_rev]
            outlist.append(out)

    #Remove comma in the end of each row of the input file to return to initial condition
    commaCmd = 'sed -i "$!s/,$//" '+in_f+''
    subprocess.Popen(commaCmd, shell=True).wait()

read_input(path,in_f)
curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)

##############################
# Run preprocessing workflow #
##############################

path_snkf = os.path.join(bamsepath,'workflows/preprocessing/Snakefile')
#Transform output file list into space-separated string (only for development)
outstr = " ".join(outlist)

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+outstr+' --configfile '+config_preprocessing+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()

######################
# Run dada2 workflow #
######################

# Define output names
out_files = path+'/ASV_counts.txt '+path+'/ASVs.fasta '+path+'/ASV_taxa.txt'
curr_dir = os.path.dirname(sys.argv[0])
bamsepath = os.path.abspath(curr_dir)
path_snkf = os.path.join(bamsepath,'workflows/dada2/Snakefile')

# Run snakemake
prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_files+' --configfile '+config_dada2+' --cores '+cores+''
subprocess.Popen(prep_snk_Cmd, shell=True).wait()
print("BAMSE dada2 is starting\n\t\tMay the force be with you.")
