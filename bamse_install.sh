#############
# BAMSE installation script
#############

# Create environment yaml
rm bamse-environment.yaml
cat >> bamse-environment.yaml <<EOL
name: bamse-env
channels:
  - bioconda
  - conda-forge
  - anaconda
dependencies:
  - snakemake-minimal >=5.24.1
  - ruamel.yaml
  - cutadapt =2.10
  - pear =0.9.6
  - bbmap =38.87
  - libcurl =7.71.1
  - R =4.0.0
  - bioconductor-dada2
  - r-dplyr
  - r-devtools
  - r-optparse
  - perl-statistics-descriptive
  - gawk =5.1.0
  - vsearch
EOL

# Install conda environment
conda env create --file bamse-environment.yaml python=3.7.4

# Activate environment
conda activate bamse-env

# Install BAMSE
#Get current directory
CUR_DIR=`pwd -P`

#Change to conda environment lib directory
ENV_LIB=$(which python | sed 's/bin\/python/lib/')
cd $ENV_LIB

#Clone bamse
rm -rf bamse
git clone https://github.com/anttonalberdi/bamse.git

#Make it executable
cd bamse
chmod +x bamse

#Add to path
BAMSE_ROOT=`pwd -P`
export PATH=${BAMSE_ROOT}:${PATH}

#Return to initial Directory
cd $CUR_DIR

#Test bamse
bamse -h
