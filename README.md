# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline


### Installation
BAMSE does not require an installation, as it can be directly run from the repository cloned from github. For doing so, follow these steps:

1- Go to the directory you want to "install"

```shell
cd /home/user/softwaredir
```

2- Clone the github repository. In Computerome2, load the git module before downloading the repository.

```shell
module load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```

3- Remember the BAMSE path for using it in the future. In this example:
```shell
/home/user/softwaredir/bamse
```

4- To download the latest version, remove the old directory and download it again.

```shell
cd /home/user/softwaredir
rm -rf bamse
module load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```
### Dependencies
BAMSE has a few dependencies:
#### ANACONDA/MINICONDA (Python 3)
https://conda.io/en/latest/miniconda.html
#### SNAKEMAKE (Python 3)
https://snakemake.readthedocs.io/en/stable/getting_started/installation.html
#### PERL
#### DADA2 (R)

For loading these dependencies at Computerome2 use the following script before launching BAMSE.
```shell
module load tools anaconda3/4.4.0 perl/5.30.2 intel/perflibs gcc/9.3.0 R/4.0.0
```

### Running
For running the core workflow of bamse, use the following code:

```shell
#Directory in which BAMSE script are stored
bamsedir=/home/user/softwaredir/bamse
#Directory in which you want to store the project files
projectdir=/home/user/softwaredir/test
#Run the launching script
python ${bamsedir}/bamse.py -i ${projectdir}/inputdata.txt -d ${projectdir} -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x silva_nr_v132_train_set.fa.gz -t 40
```
#### Parameters

**-i:** Data information file.

**-d:** Working directory of the project.

**-f:** Forward primer sequence (e.g. CTANGGGNNGCANCAG).

**-r:** Reverse primer sequence (e.g. GACTACNNGGGTATCTAAT).

**-a:** Expected sequence length without primers (e.g. 440).

**-x:** Absolute path to the taxonomy database,

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
