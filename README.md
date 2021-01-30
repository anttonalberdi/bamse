# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline. BAMSE is a snakemake-based pipeline consisting of multiple concatenated workflows to prepare, generate, curate and analyse ASV-based processing of amplicon sequencing data.

## Quickstart (installation and running)

BAMSE works on Python 3. In order to use BAMSE it is necessary to install miniconda3: https://docs.conda.io/en/latest/miniconda.html

Once miniconda3 is installed, BAMSE and the conda environment containing all the dependencies required to run it smoothly, can be installed following these two simple steps:

```shell
#Download the bamse-env conda environment installation file
curl 'https://raw.githubusercontent.com/anttonalberdi/bamse/main/bamse_install.sh' > bamse_install.sh
#Run bamse installation script (Note that if this is the first time you create a conda environment, downloading all dependencies will take a while)
sh bamse_install.sh
```
For running the core workflow of bamse, use the following code:

```shell
#Activate the bamse-env conda environment
conda activate bamse-env
#Run bamse
bamse -i [datafile] -d [project_directory] -f [forward_primer_sequence] -r [reverse_primer_sequence] -a [amplicon_length] -x [taxonomy_database_file] -t [number_of_threads]
```

## Example
```shell
# Check the current directory
pwd #in this example we will consider the command outputs: /home/projects

# Create the project directory in the current directory
mkdir bamse_example

# Move to the project directory
cd bamse_example

# Create the input data file using a text editor and save it in the project directory. It should look something like this:
#Sample,#Replicate,#Run,#Forward_read,#Reverse_read
SampleA,Replicate1,Run1,sampleA_rep1_1.fastq,sampleA_rep1_2.fastq
SampleA,Replicate2,Run1,sampleA_rep2_1.fastq,sampleA_rep2_2.fastq
SampleB,Replicate1,Run1,sampleB_rep1_1.fastq,sampleB_rep1_2.fastq
SampleB,Replicate2,Run1,sampleB_rep2_1.fastq,sampleB_rep2_2.fastq
SampleC,Replicate1,Run2,sampleC_rep1_1.fastq,sampleC_rep1_2.fastq
SampleC,Replicate1,Run2,sampleC_rep1_1.fastq,sampleC_rep1_2.fastq

#Download the taxonomy database and save it in the project directory
curl 'https://zenodo.org/record/3731176/files/silva_nr_v138_train_set.fa.gz'

#Activate the conda environment (this can be done at any step)
conda activate bamse-env

#Launch the job
bamse -i /home/projects/bamse_example/inputdata.txt -d /home/projects/bamse_example/ -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/bamse_example/silva_nr_v138_train_set.fa.gz -t 4
```

## Included steps

To date (November 2020), the pipeline consists of the following steps:

**Step 1: Primer trimming**. BAMSE uses cutadapt to trim the primer sequences from forward and reverse reads. It automatically detects whether all sequences are directional (output of PCR-based libraries) or not (output of ligation-based libraries), and flips the reversed reads in the case of the latter.

**Step 2: Read filtering**. BAMSE first uses adapterremoval to trim 3' nucleotides and then BBduk to filter out reads under the specified quality scores: loose (q=20, 1 error expected every 100 nucleotides), default (q=25, 1 error expected every 500 nucleotides) or strict (q=30, 1 error expected every 1000 nucleotides).

**Step 3: Error Learning**. BAMSE uses the DADA2 error learning algorithm to learn the error patterns in the analysed dataset.

**Step 4: Dereplication**.  BAMSE uses the DADA2 dereplication script.

**Step 5: Dada algorithm**. BAMSE runs the DADA2 algorithm for error correction.

**Step 6: Read merging**. BAMSE merges forward and reverse read by concatenating them (Note that the reads are trimmed to their exact optimal lengths in step 3).

**Step 7: Chimera filtering**. BAMSE uses the DADA2 chimera filtering algorithm to filter out chimeric sequences.

**Step 10: Taxonomy assignment**. BAMSE uses the DADA2 taxonomy assignment algorithm.

**Step 11: LULU curation**. BAMSE applies the LULU algorithm to curate the ASV table and merge the ASVs that are considered "child" (potentially erroneous) sequences of other ASVs based on their co-occurrence patterns.

## Parameters

**-i:** Data information file.

**-d:** Working directory of the project.

**-f:** Forward primer sequence (e.g. CTANGGGNNGCANCAG).

**-r:** Reverse primer sequence (e.g. GACTACNNGGGTATCTAAT).

**-a:** Expected sequence length without primers (e.g. 440).

**-x:** Absolute path to the taxonomy database, which can be downloaded here: https://zenodo.org/record/3731176/files/silva_nr_v138_train_set.fa.gz

**-t:** Number of threads (e.g. 8).

Optional:

**-q:** Desired quality filtering mode, either **loose** (q=20, 1 error expected every 100 nucleotides), **default** (q=25, 1 error expected every 500 nucleotides) or **strict** (q=30, 1 error expected every 1000 nucleotides).

**-m:** Stringency level of the DADA2 chimera filtering (default is 1). The higher then number the looser the definition of chimeras (more final ASVs retrieved).

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

An example data input file can be found in example/inputfile.txt
