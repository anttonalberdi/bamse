#############
# BAMSE installation script
#############

# Create environment yaml
cat > bamse-environment.yaml <<EOL
name: bamse-env
channels:
  - bioconda
  - conda-forge
  - anaconda
dependencies:
  - snakemake-minimal =5.32.1
  - setuptools =49.6.0
  - biopython =1.70
  - numpy =1.12.1
  - ruamel.yaml =0.16.12
  - cutadapt =2.10
  - bbmap =38.87
  - libcurl =7.71.1
  - R =4.0.0
  - bioconductor-dada2 =1.18.0
  - boto3 =1.9.66
  - smart_open
  - r-dplyr =1.0.4
  - r-stringr =1.4.0
  - r-devtools =2.3.2
  - r-optparse =1.6.6
  - r-gtools =3.8.2
  - r-ape =5.4_1
  - perl-statistics-descriptive =3.0702
  - gawk =5.1.0
  - vsearch =2.15.2
  - clustalo =1.2.4
  - iqtree =2.0.3
EOL

echo ""
echo "############################"
echo "### Installing BAMSE 1.0 ###"
echo "############################"
echo ""

# Install conda environment
echo "Creating bamse-env conda environment"
echo "  This step can take a few minutes..."
echo ""
conda env create --file bamse-environment.yaml python=3.7.4

#Get conda path and source it
CONDA_PATH=$(which python | sed 's/bin\/python/etc\/profile.d\/conda.sh/')
source $CONDA_PATH

# Activate environment
echo "Activating conda environment"
conda activate bamse-env

# Install BAMSE
echo "Installing BAMSE"
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
#Get conda path and source it
ACTIVATE_PATH=$(which python | sed 's/bin\/python/etc\/conda\/activate.d\/bamse.sh/')
BAMSE_ROOT=$(which python | sed 's/bin\/python/lib\/bamse/')
echo "echo 'Activating BAMSE'" > $ACTIVATE_PATH
echo "export PATH=${BAMSE_ROOT}:\${PATH}" >> $ACTIVATE_PATH

#Return to initial Directory
cd $CUR_DIR

#Deactivate conda
conda deactivate

#Test bamse
echo ""
echo "BAMSE has been installed succesfully. Run the following commands to start using it"
echo "conda activate bamse-env"
echo "bamse -h"
