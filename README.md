# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline


### Installation (local computer)
BAMSE does not require an installation, as it can be directly run from the repository cloned from github. The best way to ensure BAMSE will run smoothly is to create a conda environment that contains all the dependencies BAMSE requires.

Note that BAMSE works only with Python 3. In order to create the bamse-env conda environment, it is necessary to install miniconda3: https://docs.conda.io/en/latest/miniconda.html

To create the bamse-env conda environment that contains bamse and all its dependencies, perform the following steps:

```shell
#Download the bamse-env conda environment installation file
curl 'https://raw.githubusercontent.com/anttonalberdi/bamse/main/bamse_install.sh' > bamse_install.sh
#Run bamse installation script (Note that if this is the first time you create a conda environment, downloading all dependencies will take a while)
sh bamse_install.sh
```

### Installation (Computerome2)
2- Clone the github repository. In Computerome2, load the git module before downloading the repository.

```shell
#Go to the directory where you want to install BAMSE
cd /home/user/softwaredir
#Clone the BAMSE repository
module load tools git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
#Load dependencies
module load tools anaconda3/4.4.0 perl/5.30.2 intel/perflibs gcc/9.3.0 R/4.0.0
#Test if BAMSE is working
python bamse/bamse.py -h
```

### Running
For running the core workflow of bamse, use the following code:

```shell
#Directory in which BAMSE script are stored
bamsedir=/home/user/softwaredir/bamse
#Directory in which you want to store the project files
projectdir=/home/user/projects/test
#Run the launching script
python ${bamsedir}/bamse.py -i ${projectdir}/inputdata.txt -d ${projectdir} -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x silva_nr_v132_train_set.fa.gz -t 40
```
#### Parameters

**-i:** Data information file.

**-d:** Working directory of the project.

**-f:** Forward primer sequence (e.g. CTANGGGNNGCANCAG).

**-r:** Reverse primer sequence (e.g. GACTACNNGGGTATCTAAT).

**-a:** Expected sequence length without primers (e.g. 440).

**-x:** Absolute path to the taxonomy database, which can be downloaded here: https://zenodo.org/record/1172783/files/silva_nr_v132_train_set.fa.gz

**-t:** Number of threads (e.g. 40).

Optional:

**-q:** Desired minimum quality (phred) score. Note that BAMSE might need to change this, if the read-overlap is not long enough.

**-p:** Absolute path to the parameters file that BAMSE will create. By default, this will be stored in the working directory.

**-l:** Absolute path to the log file that BAMSE will create. By default, this will be stored in the working directory.

#### Data information file
The data input file must be a simple text file with the information corresponding to each dataset specified in a different row and **separated by commas**. The minimum information required is:

**Data unit:** Name of the minimum data unit. If no replicates (either biological or technical) have been used data unit and sample should be identical. If replicates have been used, data units with identical sample names will be merged by BAMSE.

**Sample:** String that specifies the sample name. This is the name that the ASV tables will get.

**Run:** String specifying the sequencing run. If all samples were sequences in the same flowcell or lane, use the same string for all samples.

**Forward read:** Absolute path to the forward read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

**Reverse read:** Absolute path to the reverse read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

| Data unit (replicate) | Sample | Run | Forward read | Reverse read |
| ----------- | ----------- | ----------- | ----------- | ----------- |
| Sample1_Rep1 | Sample1 | Run1 | Sample1_Rep1_1.fq.gz | Sample1_Rep1_2.fq.gz |
| Sample1_Rep2 | Sample1 | Run1 | Sample1_Rep2_1.fq.gz | Sample1_Rep2_2.fq.gz |
| Sample2_Rep1 | Sample2 | Run1 | Sample2_Rep1_1.fq.gz | Sample2_Rep1_2.fq.gz |
| Sample2_Rep2 | Sample2 | Run1 | Sample2_Rep2_1.fq.gz | Sample2_Rep2_2.fq.gz |
| Sample3_Rep1 | Sample3 | Run2 | Sample3_Rep1_1.fq.gz | Sample3_Rep1_2.fq.gz |
| Sample3_Rep2 | Sample3 | Run2 | Sample3_Rep2_1.fq.gz | Sample3_Rep2_2.fq.gz |

An example data input file can be found in inputfile.txt

If working in Computerome2, insert that code in a shell file, and submit a job using qsub.

```shell
echo "python ${bamsedir}/bamse.py -i ${projectdir}/inputdata.txt -d ${projectdir} -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x silva_nr_v132_train_set.fa.gz -t 40" > bamsejob.sh

workdir=/home/user/projectdir/
bamsedir=/home/user/softwaredir/bamse

qsub -V -A ku-cbd -W group_list=ku-cbd -v "workdir=${workdir},bamsedir=${bamsedir}"  -d `pwd` -e ${workdir}/BAMSE.err -o ${workdir}/BAMSE.out -l nodes=1:ppn=40,mem=180gb,walltime=1:00:00:00 -N BAMSE ${workdir}/bamsejob.sh
```
