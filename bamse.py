import argparse
import subprocess
import os
import sys
import ruamel.yaml

####################
# Argument parsing #
####################

parser = argparse.ArgumentParser(description='Runs bamse-dada2 pipeline.')
parser.add_argument('-f', help="input.txt file", dest="input_txt", required=True)
parser.add_argument('-d', help="temp files directory path", dest="work_dir", required=True)
parser.add_argument('-x', help="taxonomy database", dest="tax", required=True)
parser.add_argument('-t', help="threads", dest="threads", required=True)
parser.add_argument('-c', help="config file", dest="config_file", required=False)
parser.add_argument('-g', help="reference genome", dest="ref", required=False)
parser.add_argument('-l', help="pipeline log file", dest="log", required=False)
args = parser.parse_args()

# Translate arguments
in_f=args.input_txt
path=args.work_dir
ref=args.ref
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

#Append current directory to .yaml config for standalone calling
yaml = ruamel.yaml.YAML()
yaml.explicit_start = True
with open(str(config), 'r') as config_file:
    data = yaml.load(config_file)
    if data == None:
        data = {}

with open(str(config), 'w') as config_file:
    data['bamsepath'] = str(curr_dir)
    data['logpath'] = str(log)
    data['taxonomydb'] = str(tax)
    dump = yaml.dump(data, config_file)

#############################
# Input datafile processing #
#############################



######################
# Run dada2 workflow #
######################

def run_dada2(in_f, path, config, cores):
    """Run snakemake on shell"""

    # Define output names
    out_files = in_out_preprocessing(path,in_f)
    curr_dir = os.path.dirname(sys.argv[0])
    bamsepath = os.path.abspath(curr_dir)
    path_snkf = os.path.join(holopath,'workflows/dada2/Snakefile')

    # Run snakemake
    prep_snk_Cmd = 'module load tools anaconda3/4.4.0 && snakemake -s '+path_snkf+' -k '+out_files+' --configfile '+config+' --cores '+cores+''
    subprocess.check_call(prep_snk_Cmd, shell=True)
    print("BAMSE dada2 is starting\n\t\tMay the force be with you.")

run_dada2(in_f, path, config, cores)
