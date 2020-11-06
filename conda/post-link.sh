#Get current directory
CUR_DIR=`pwd -P`

#Change to conda environment lib directory
cd /opt/anaconda3/envs/bamse-env/lib

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
