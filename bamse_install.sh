#############
# BAMSE installation script
#############

# Create environment yaml
cat > bamse-environment.yaml <<EOL
name: bamse-env
channels:
  - conda-forge
  - bioconda
dependencies:
  - conda-forge::snakemake-minimal=6.3.0
  - conda-forge::biopython=1.78
  - conda-forge::ruamel.yaml=0.16.12
  - conda-forge::cutadapt=2.10
  - conda-forge::bbmap=38.87
  - conda-forge::r=4.0.0
  - conda-forge::r-devtools=2.4.1
  - conda-forge::bioconductor-dada2=1.18.0
  - conda-forge::r-dplyr=1.0.6
  - conda-forge::r-stringr=1.4.0
  - conda-forge::r-optparse=1.6.6
  - conda-forge::r-gtools=3.8.2
  - conda-forge::r-ape=5.5
  - conda-forge::perl-statistics-descriptive=3.0702
  - conda-forge::gawk=5.1.0
  - conda-forge::vsearch=2.15.2
  - conda-forge::clustalo=1.2.4
  - conda-forge::iqtree=2.0.3
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
conda env create --file bamse-environment.yaml python=3.8.0

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
