import argparse
import subprocess
import os
import sys
import ruamel.yaml
import pathlib

#python bamse/bamse.py -f bamse/workflows/inputfile.txt -d /home/projects/ku-cbd/people/antalb/bamse2/ -x sdf -t 1

####################
# Argument parsing #
####################

parser = argparse.ArgumentParser(description='Runs bamse-dada2 pipeline.')
parser.add_argument('-f', help="input.txt file", dest="input", required=True)
parser.add_argument('-d', help="temp files directory path", dest="workdir", required=True)
parser.add_argument('-x', help="taxonomy database", dest="tax", required=True)
parser.add_argument('-t', help="threads", dest="threads", required=True)
parser.add_argument('-c', help="config file", dest="config_file", required=False)
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

# Define config file
if not (args.config_file):
    config = os.path.join(os.path.abspath(curr_dir),"workflows/dada2/config.yaml")
else:
    config=args.config_file

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
#yaml = ruamel.yaml.YAML()
#yaml.explicit_start = True
#with open(str(config), 'r') as config_file:
#    data = yaml.load(config_file)
#    if data == None:
#        data = {}

#with open(str(config), 'w') as config_file:
#    data['bamsepath'] = str(curr_dir)
#    data['logpath'] = str(log)
#    data['taxonomydb'] = str(tax)
#    dump = yaml.dump(data, config_file)

#############################
# Prepare working directory #
#############################

def prepare_dir(path):
    # Set input directory
    in_dir = os.path.join(path,"0-Data")

    ## If input directory does not exist, make it
    if not os.path.exists(in_dir):
        os.makedirs(in_dir)

prepare_dir(path)

#################
# Transfer data #
#################

print(path)

def read_input(path,in_f):
    # Read input data file
    inputfile = open(in_f, "r")

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

            # Transfer, rename and decompress data
            if os.path.isfile(in_for):
                if in_for.endswith('.gz'):
                    read1Cmd = 'gunzip -c '+in_for+' > '+path+'/0-Data/'+name+'_1.fastq'
                    subprocess.check_call(read1Cmd, shell=True)
                else:
                    read1Cmd = 'cp '+in_for+' '+path+'/0-Data/'+name+'_1.fastq'
                    subprocess.check_call(read1Cmd, shell=True)

                if in_rev.endswith('.gz'):
                    read2Cmd = 'gunzip -c '+in_rev+' > '+path+'/0-Data/'+name+'_2.fastq'
                    subprocess.check_call(read2Cmd, shell=True)
                else:
                    read2Cmd = 'cp '+in_rev+' '+path+'/0-Data/'+name+'_2.fastq'
                    subprocess.check_call(read2Cmd, shell=True)
            else:
                print('The file ' + in_for + 'does not exist.')




read_input(path,in_f)

######################
# Run dada2 workflow #
######################

def run_dada2(in_f, path, config, cores):
    """Run snakemake on shell"""

    # Define output names
    out_files = in_out_dada2(path,in_f)
    curr_dir = os.path.dirname(sys.argv[0])
    bamsepath = os.path.abspath(curr_dir)
    path_snkf = os.path.join(holopath,'workflows/dada2/Snakefile')

    # Run snakemake
    prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_files+' --configfile '+config+' --cores '+cores+''
    subprocess.check_call(prep_snk_Cmd, shell=True)
    print("BAMSE dada2 is starting\n\t\tMay the force be with you.")

#run_dada2(in_f, path, config, cores)
