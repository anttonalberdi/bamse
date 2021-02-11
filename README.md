# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline. BAMSE is a snakemake-based pipeline consisting of multiple concatenated workflows to prepare, generate, curate and analyse ASV-based processing of amplicon sequencing data.

## Quickstart (installation and running)

BAMSE works on Python 3. In order to use BAMSE it is necessary to previously have installed miniconda3: https://docs.conda.io/en/latest/miniconda.html

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

## Update BAMSE

In order to update BAMSE you need to remove the conda environment, download it from Github and install it again.

```shell
#Get out from the conda environment (if active)
conda deactivate
#Remove the conda environment
conda remove --name bamse-env --all
#Download the bamse-env conda environment installation file
curl 'https://raw.githubusercontent.com/anttonalberdi/bamse/main/bamse_install.sh' > bamse_install.sh
#Run bamse installation script (Note that if this is the first time you create a conda environment, downloading all dependencies will take a while)
sh bamse_install.sh
#Activate the bamse-env conda environment
conda activate bamse-env

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
#Sample,#Run,#Forward_read,#Reverse_read
SampleA,Run1,/mydir/sampleA_1.fastq,/mydir/sampleA_2.fastq
SampleB,Run1,/mydir/sampleB_1.fastq,/mydir/sampleB_2.fastq
SampleC,Run2,/mydir/sampleC_1.fastq,/mydir/sampleC_2.fastq
#*It is recommended to use absolute paths (e.g. ''/home/projects/rawdata/sampleA_1.fastq', rather than 'sampleA_1.fastq') to avoid issues.

#Download the taxonomy database and save it in the project directory
curl 'https://zenodo.org/record/3731176/files/silva_nr_v138_train_set.fa.gz' > silva_nr_v138_train_set.fa.gz
#The database can be stored elsewhere, but in that case ensure the correct path is inputed to BAMSE.

#Activate the conda environment (this can be done at any step)
conda activate bamse-env

#Launch the job
bamse -i /home/projects/bamse_example/inputdata.txt -d /home/projects/bamse_example/ -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/bamse_example/silva_nr_v138_train_set.fa.gz -t 4
```

## Included steps

To date (February 2021), the pipeline consists of the following steps:

**Step 1: Primer trimming**. BAMSE uses **Cutadapt** to trim the specified primer sequences from forward and reverse reads. It automatically detects whether all sequences are directional (output of PCR-based libraries) or not (output of ligation-based libraries), and flips the reversed reads in the case of the latter.

**Step 2: Read filtering**. BAMSE first uses a custom script that trims the 3'-end of the reads until the maximum expected error (cumulative from 5' end) is reached. Then, read pairs shorter than the length needed to achieve the required read overlap are filtered out. The default maximum expected errors per read is 2, and the minimum overlap is 5 nucleotides. These parameters can be modified through the flags -e and -o, respectivelly.

**Step 3: Error Learning**. BAMSE uses the **DADA2** error learning algorithm to learn the error patterns in the analysed dataset.

**Step 4: Dereplication**.  BAMSE uses the **DADA2** dereplication script.

**Step 5: Dada algorithm**. BAMSE runs the **DADA2** algorithm for error correction.

**Step 6: Read merging**. BAMSE merges forward and reverse reads using **DADA2**.

**Step 7: Chimera filtering**. BAMSE uses the **DADA2** chimera filtering algorithm to filter out chimeric sequences.

**Step 10: Taxonomy assignment**. BAMSE uses the **DADA2** taxonomy assignment algorithm.

**Step 11: Taxonomy filtering**. BAMSE only retains ASVs assigned at least to a Bacteria/Archaea Phylum level.

**Step 12: LULU curation (optional)**. BAMSE applies the **LULU** algorithm to curate the ASV table and merge the ASVs that are considered "child" (potentially erroneous) sequences of other ASVs based on their co-occurrence patterns.

**Coming soon: ASV table filtering**. BAMSE will filter the ASV table based on a number of criteria, including estimated diversity completeness level of each sample, minimum read number and minimum relative representation of ASVs.

**Step 13: Phylogenetic tree**. BAMSE runs **Clustal Omega** for aligning the ASV sequences and **IQ-Tree** for building a Maximum Likelihood phylogenetic tree that can be used for calculating phylogenetic diversity metrics.

**Step 14: ASV clustering**. BAMSE uses **VSEARCH** to cluster/bin ASVs using an identity threshold (default 97%), and stores output files along with the original ones.

## Parameters

**-i:** Data information file.

**-d:** Working directory of the project.

**-f:** Forward primer sequence (e.g. CTANGGGNNGCANCAG).

**-r:** Reverse primer sequence (e.g. GACTACNNGGGTATCTAAT).

**-a:** Expected sequence length without primers (e.g. 440).

**-x:** Absolute path to the taxonomy database, which can be downloaded here: https://zenodo.org/record/3731176/files/silva_nr_v138_train_set.fa.gz

**-t:** Number of threads (e.g. 8).

Optional:

**-e:** Maximum expected error per read (default 2).

**-o:** Minimum overlap for merging reads (default 5).

**-q:** Desired quality filtering mode, either **loose** (q=20, 1 error expected every 100 nucleotides), **default** (q=25, 1 error expected every 500 nucleotides) or **strict** (q=30, 1 error expected every 1000 nucleotides).

**-m:** Stringency level of the DADA2 chimera filtering (default is 1). The higher then number the looser the definition of chimeras (more final ASVs retrieved).

**-p:** Absolute path to the parameters file that BAMSE will create. By default, this will be stored in the working directory.

**-l:** Absolute path to the log file that BAMSE will create. By default, this will be stored in the working directory.

**-u:** BAMSE runs LULU polishing.

#### Data information file
The data input file must be a simple text file with the information corresponding to each dataset specified in a different row and **separated by commas**. The minimum information required is:

**Data unit:** Name of the minimum data unit. If no replicates (either biological or technical) have been used data unit and sample should be identical. If replicates have been used, data units with identical sample names will be merged by BAMSE.

**Sample:** String that specifies the sample name. This is the name that the ASV tables will get.

**Run:** String specifying the sequencing run. If all samples were sequences in the same flowcell or lane, use the same string for all samples.

**Forward read:** Absolute path to the forward read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

**Reverse read:** Absolute path to the reverse read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

| Sample | Run | Forward read | Reverse read |
| ----------- | ----------- | ----------- | ----------- |
| Sample1 | Run1 | Sample1_Rep1_1.fq.gz | Sample1_Rep1_2.fq.gz |
| Sample1 | Run1 | Sample1_Rep2_1.fq.gz | Sample1_Rep2_2.fq.gz |
| Sample2 | Run1 | Sample2_Rep1_1.fq.gz | Sample2_Rep1_2.fq.gz |
| Sample2 | Run1 | Sample2_Rep2_1.fq.gz | Sample2_Rep2_2.fq.gz |
| Sample3 | Run2 | Sample3_Rep1_1.fq.gz | Sample3_Rep1_2.fq.gz |
| Sample3 | Run2 | Sample3_Rep2_1.fq.gz | Sample3_Rep2_2.fq.gz |

An example data input file can be found in example/inputfile.txt

## Snakemake output
BAMSE implements Snakemake for efficient processing of the data. BAMSE will sequentially create the following folders and files throughout the process. The most relevant files are bolded.

- 0-Data
- - 0-Data/RUN1
- 0-Data/RUN1/SAMPLEA_1.fastq
- 0-Data/RUN1/SAMPLEA_2.fastq
- 0-Data/RUN2
- 0-Data/RUN2/SAMPLEB_1.fastq
- 0-Data/RUN2/SAMPLEB_2.fastq

- 0-Stats
- 0-Stats/SAMPLE.txt

- 1-Primertrimmed
- 1-Primertrimmed/RUN1
- 1-Primertrimmed/RUN1/SAMPLEA_1.fastq
- 1-Primertrimmed/RUN1/SAMPLEA_2.fastq
- 1-Primertrimmed/RUN2
- 1-Primertrimmed/RUN2/SAMPLEB_1.fastq
- 1-Primertrimmed/RUN2/SAMPLEB_2.fastq

- 2-Filtered
- 2-Filtered/RUN1
- 2-Filtered/RUN1/SAMPLEA_1.fastq
- 2-Filtered/RUN1/SAMPLEA_2.fastq
- 2-Filtered/RUN2
- 2-Filtered/RUN2/SAMPLEB_1.fastq
- 2-Filtered/RUN2/SAMPLEB_2.fastq

- 3-DADA2
- 3-DADA2/RUN1.rds
- 3-DADA2/RUN2.rds
- 3-DADA2/ASV_counts.csv
- 3-DADA2/ASV_taxa.txt
- 3-DADA2/ASVs.fasta

- 4-Taxonomyfilter
- 4-Taxonomyfilter/ASVs.filt.fasta
- 4-Taxonomyfilter/ASVs.filt.txt

- **ASV_counts.csv**
- **ASV_taxa.txt**
- **ASVs.fasta**

- 6-Phylogeny/ASVs.align.fasta
- 6-Phylogeny/ASVs.align.fasta.bionj
- 6-Phylogeny/ASVs.align.fasta.ckp.gz
- 6-Phylogeny/ASVs.align.fasta.iqtree
- 6-Phylogeny/ASVs.align.fasta.log
- 6-Phylogeny/ASVs.align.fasta.mldist

- **ASVs.tre**

- 7-Binning/ASVs.counts.fasta
- 7-Binning/ASVs.sorted.fasta
- 7-Binning/binmap.txt
- 7-Binning/bintable.txt

- **ASV_counts.binned.csv**
- **ASV_taxa.binned.txt**
- **ASVs.binned.fasta**

## References
If you use BAMSE, please acknowledge the following publications:
* Callahan, Benjamin J., et al. "DADA2: high-resolution sample inference from Illumina amplicon data." Nature methods 13.7 (2016): 581-583.
* Nguyen, Lam-Tung, et al. "IQ-TREE: a fast and effective stochastic algorithm for estimating maximum-likelihood phylogenies." Molecular biology and evolution 32.1 (2015): 268-274.
* Sievers, Fabian, and Desmond G. Higgins. "Clustal omega." Current protocols in bioinformatics 48.1 (2014): 3-13.
* Schubert, Mikkel, Stinus Lindgreen, and Ludovic Orlando. "AdapterRemoval v2: rapid adapter trimming, identification, and read merging." BMC research notes 9.1 (2016): 1-7.
* Martin, Marcel. "Cutadapt removes adapter sequences from high-throughput sequencing reads." EMBnet. journal 17.1 (2011): 10-12.
* Bushnell, B. "BBTools: a suite of fast, multithreaded bioinformatics tools designed for analysis of DNA and RNA sequence data." Joint Genome Institute (2018).
