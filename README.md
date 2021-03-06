# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline. BAMSE is a snakemake-based pipeline consisting of multiple concatenated workflows to prepare, generate, curate and analyse ASV-based processing of amplicon sequencing data. BAMSE includes a unique quality-filtering approach that ensures optimal quality filtering of sequencing reads generated through adaptor ligation, as well as phylogeny-building and binning/clustering steps.

## Install BAMSE

BAMSE works on Python 3. In order to use BAMSE it is necessary to previously have installed miniconda3: https://docs.conda.io/en/latest/miniconda.html

Once miniconda3 is installed, BAMSE and the conda environment containing all the dependencies required to run it smoothly, can be installed following these two simple steps:

```shell
#Download the bamse-env conda environment installation file
curl 'https://raw.githubusercontent.com/anttonalberdi/bamse/main/bamse_install.sh' > bamse_install.sh
#Run bamse installation script (Note that if this is the first time you create a conda environment, downloading all dependencies will take a while)
sh bamse_install.sh
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

## Run BAMSE

Once the software is installed, in order to run BAMSE you need the following:

* A data input textfile specifying the name of the samples, their run group and the location of the fastq files.
* Forward and reverse primer sequences.
* A taxonomy database.
* The length of the targeted marker (expected approximate length of ASVs)

![Launching script figure](https://raw.githubusercontent.com/anttonalberdi/bamse/main/figures/figure2.png)

```shell
# Check the current directory
pwd #in this example we will consider the command outputs: /home/projects

# Create the project directory in the current directory
mkdir bamse_example

# Move to the project directory
cd bamse_example

# Create the input data file using a text editor and save it in the project directory. The file must contain four columns separated by commas. Note the line ends need to be in LF (UNIX) and not in CRLF (Windows) format. It should look something like this:
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

#Launch the job (note that more arguments can be included, as specified below)
bamse -i /home/projects/bamse_example/inputdata.txt -d /home/projects/bamse_example/ -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/bamse_example/silva_nr_v138_train_set.fa.gz -t 4
```

## Included steps

To date (February 2021), the pipeline consists of the following steps:

![Steps figure](https://raw.githubusercontent.com/anttonalberdi/bamse/main/figures/figure1.png)

**Step 1: Primer trimming**. BAMSE uses **Cutadapt** to trim the specified primer sequences from forward and reverse reads. It automatically detects whether all sequences are directional (output of PCR-based libraries) or not (output of ligation-based libraries). In the latter case, sequencing read files are split into properly oriented and reverse-oriented sequences, which are processed independently until the ASV table formation. This ensures error learning of DADA2 is conducted appropriately.

**Step 2: Optimal trimming and filtering**. BAMSE first uses a custom script to identify the optimal parameters for read trimming considering amplicon length, read length, overlap and maximum expected error. In the case of ligation-based libraries, optimal trimming parameters are calculated separately for properly oriented and reverse-oriented sequences. Then, BAMSE proceeds with optimal read trimming and filtering. The default maximum expected errors per read is 2, and the default minimum overlap is 20 nucleotides. These parameters can be modified through the flags -e and -o, respectively.

**Step 3: Error Learning**. BAMSE uses the **DADA2** error learning algorithm to learn the error patterns in the analysed dataset. When samples from multiple sequencing runs are analysed together, BAMSE will conduct error learning independently for each run. In the case of ligation-based libraries, error learning will also be conducted independently for properly oriented and reverse-oriented sequences.

**Step 4: Dereplication**.  BAMSE uses the **DADA2** dereplication script.

**Step 5: Dada algorithm**. BAMSE runs the **DADA2** algorithm for error correction.

**Step 6: Read merging**. BAMSE merges forward and reverse reads using **DADA2**.

**Step 7: Sample aggregation**. In the case of ligation-based libraries, BAMSE aggregates the count reads from the two data sets, containing properly oriented and reverse-oriented sequences, respectively, which were independently processed until this point. BAMSE also merges data from different sequencing runs as specified in the input file.

**Step 8: Chimera filtering**. BAMSE uses the **DADA2** chimera filtering algorithm to filter out chimeric sequences.

**Step 9: Copy number threshold filtering**. BAMSE filters ASVs by relative number of copies in each sample. The default parameter is 0.0001 (0.01%), which entails that any ASV with a representation below 0.01% of the total number of reads for a given sample will be converted into zero. For example, for a sample characterised with 10,000 reads, this will imply removing singletones, while for a sample characterised with 100,000 reads will entail removing ASVs below 10 reads. The filtering parameter can be modified or disabled using 0.

**Step 10: Taxonomy assignment**. BAMSE uses the **DADA2** taxonomy assignment algorithm.

**Step 11: Taxonomy filtering**. BAMSE only retains ASVs assigned at least to a Bacteria/Archaea Phylum level.

**Step 12: LULU curation (optional)**. BAMSE applies the **LULU** algorithm to curate the ASV table and merge the ASVs that are considered "child" (potentially erroneous) sequences of other ASVs based on their co-occurrence patterns.

**Coming soon: ASV table filtering**. BAMSE will filter the ASV table based on a number of criteria, including estimated diversity completeness level of each sample, minimum read number and minimum relative representation of ASVs.

**Step 13: Phylogenetic tree**. BAMSE runs **Clustal Omega** for aligning the ASV sequences and **IQ-Tree** for building a Maximum Likelihood phylogenetic tree that can be used for calculating phylogenetic diversity metrics.

**Step 14: ASV clustering**. BAMSE uses **VSEARCH** to cluster/bin ASVs using an identity threshold (default 97%), and stores output files along with the original ones.

## Parameters

### Mandatory

**-i:** Data information file.

**-d:** Working directory of the project.

**-f:** Forward primer sequence (e.g. CTANGGGNNGCANCAG).

**-r:** Reverse primer sequence (e.g. GACTACNNGGGTATCTAAT).

**-a:** Expected sequence length without primers (e.g. 440).

**-x:** Absolute path to the taxonomy database, which can be downloaded here: https://zenodo.org/record/3731176/files/silva_nr_v138_train_set.fa.gz

**-t:** Number of threads (e.g. 8).

### Optional

**-e:** Maximum expected error per read (default 2).

**-o:** Minimum overlap for merging reads (default 5).

**-q:** Desired quality filtering mode, either **loose** (q=20, 1 error expected every 100 nucleotides), **default** (q=25, 1 error expected every 500 nucleotides) or **strict** (q=30, 1 error expected every 1000 nucleotides).

**-c:** Relative minimum copy number threshold to consider an ASV in a sample. Default is 0.0001 (0.01%), which entails that for a sample characterised with 10,000 (10,000 x 0.0001 = 1) reads singletones will be removed, while for a sample characterised with 100,000 (100,000 x 0.0001 = 10) reads ASVs below 10 reads will be removed. The filtering parameter can be modified or disabled using 0.

**-m:** Stringency level of the DADA2 chimera filtering (default is 1). The higher then number the looser the definition of chimeras (more final ASVs retrieved).

**-p:** Absolute path to the parameters file that BAMSE will create. By default, this will be stored in the working directory.

**-l:** Absolute path to the log file that BAMSE will create. By default, this will be stored in the working directory.

**-u:** BAMSE runs LULU polishing.

## Data input file
The data input file must be a simple text file with the information corresponding to each dataset specified in a different row and **separated by commas**. The minimum information required is:

**Sample:** String that specifies the sample name. This is the name that the ASV tables will get.

**Run:** String specifying the sequencing run. If all samples were sequences in the same flowcell or lane, use the same string for all samples.

**Forward read:** Absolute path to the forward read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

**Reverse read:** Absolute path to the reverse read. Both compressed (e.g. fq.gz, fastq.gz) and uncompressed (e.g. fq, fastq) files are accepted.

| Sample | Run | Forward read | Reverse read |
| ----------- | ----------- | ----------- | ----------- |
| Sample1 | Run1 | /project/rawdata/Sample1_Rep1_1.fq.gz | /project/rawdata/Sample1_Rep1_2.fq.gz |
| Sample1 | Run1 | /project/rawdata/Sample1_Rep2_1.fq.gz | /project/rawdata/Sample1_Rep2_2.fq.gz |
| Sample2 | Run1 | /project/rawdata/Sample2_Rep1_1.fq.gz | /project/rawdata/Sample2_Rep1_2.fq.gz |
| Sample2 | Run1 | /project/rawdata/Sample2_Rep2_1.fq.gz | /project/rawdata/Sample2_Rep2_2.fq.gz |
| Sample3 | Run2 | /project/rawdata/Sample3_Rep1_1.fq.gz | /project/rawdata/Sample3_Rep1_2.fq.gz |
| Sample3 | Run2 | /project/rawdata/Sample3_Rep2_1.fq.gz | /project/rawdata/Sample3_Rep2_2.fq.gz |

An example data input file can be found in example/inputfile.txt

## Snakemake output
BAMSE implements Snakemake for efficient processing of the data. BAMSE will sequentially create the following folders and files throughout the process. The most relevant files are bolded. If any of these files are already generated BAMSE will not run the processes needed to generate them again, and will follow the pipeline from that checkpoint. If you want to re-run a specific step, remove the files, and BAMSE will start from the immediate previous step.

#### Data folder
This folder contains the raw data copied from the directory specified in the input file. Files are oranised by run as specified in the input file. A simple set-up of two runs and one sample per run is shown in the following:

- 0-Data
  - 0-Data/RUN1
    - 0-Data/RUN1/SAMPLEA_1.fastq
    - 0-Data/RUN1/SAMPLEA_2.fastq
  - 0-Data/RUN2
    - 0-Data/RUN2/SAMPLEB_1.fastq
    - 0-Data/RUN2/SAMPLEB_2.fastq

#### Data folder
BAMSE will output here the read count statistics for each sample.

- 0-Stats
  - 0-Stats/SAMPLEA.txt
  - 0-Stats/SAMPLEB.txt

#### Primertrimmed folder
This folder contains the primer-trimmed files. Files are organised by run as specified in the input file. Note that if the project has many samples this folder can occupy considerable space in the computer.

- 1-Primertrimmed
  - 1-Primertrimmed/RUN1
    - 1-Primertrimmed/RUN1/SAMPLEA_1.fastq
    - 1-Primertrimmed/RUN1/SAMPLEA_2.fastq
  - 1-Primertrimmed/RUN2
    - 1-Primertrimmed/RUN2/SAMPLEB_1.fastq
    - 1-Primertrimmed/RUN2/SAMPLEB_2.fastq

In the case of adaptor-based libraries, the split files will look like this:

- 1-Primertrimmed
  - 1-Primertrimmed/RUN1
    - 1-Primertrimmed/RUN1/SAMPLEA_1.fastq
    - 1-Primertrimmed/RUN1/SAMPLEA_1.rev.fastq
    - 1-Primertrimmed/RUN1/SAMPLEA_2.fastq
    - 1-Primertrimmed/RUN1/SAMPLEA_2.rev.fastq

#### Filtered folder
This folder contains the quality-trimmed and length-filtered paired reads. Files are organised by run as specified in the input file. Note that if the project has many samples this folder can occupy considerable space in the computer.

- 2-Filtered
  - 2-Filtered/RUN1
    - 2-Filtered/RUN1/SAMPLEA.csv
    - 2-Filtered/RUN1/SAMPLEA_1.fastq
    - 2-Filtered/RUN1/SAMPLEA_2.fastq
  - 2-Filtered/RUN2
    - 2-Filtered/RUN2/SAMPLEB.csv
    - 2-Filtered/RUN2/SAMPLEB_1.fastq
    - 2-Filtered/RUN2/SAMPLEB_2.fastq

In the case of adaptor-based libraries, the split files will look like this:

- 2-Filtered
  - 2-Filtered/RUN1
    - 2-Filtered/RUN1/SAMPLEA.csv
    - 2-Filtered/RUN1/SAMPLEA.rev.csv
    - 2-Filtered/RUN1/SAMPLEA_1.fastq
    - 2-Filtered/RUN1/SAMPLEA_1.rev.fastq
    - 2-Filtered/RUN1/SAMPLEA_2.fastq
    - 2-Filtered/RUN1/SAMPLEA_2.rev.fastq

#### DADA2 folder
The DADA2 step is split in two parts. In the initial part error correction and ASV generation is carried out, and the resulting data are stored as *.rds (Rdata) files. BAMSE will generate one *.rds file per run, as specified in the input file. In the second step, chimeras will be filtered before annotating the taxonomy. This second step will create three files containing, the ASV sequences (ASVs.fasta), taxonomy annotations (ASV_taxa.txt) and the ASV:sample table (ASV_counts.csv).

- 3-DADA2
  - 3-DADA2/RUN1.rds
  - 3-DADA2/RUN1.rev.rds
  - 3-DADA2/RUN2.rds
  - 3-DADA2/ASV_counts.csv
  - 3-DADA2/ASV_taxa.txt
  - 3-DADA2/ASVs.fasta

#### Taxonomy filter folder
The "raw" DADA2 output stored in the previous folder will be filtered to only retain ASVs with meaningful taxonomy. These include ASVs with a taxonomic annotation at least at the Phylum level. The taxonomy filter folder contains the sequences (ASVs.filt.fasta) and taxonomic annotations (ASVs.filt.txt) of the removed ASVs. The ASVs with correct annotations are stored in the main project directory. The original non-filtered files can be found in the previous DADA2 folder.

- 4-Taxonomyfilter
  - 4-Taxonomyfilter/ASVs.filt.fasta
  - 4-Taxonomyfilter/ASVs.filt.txt

- **ASV_counts.csv**
- **ASV_taxa.txt**
- **ASVs.fasta**

#### ASV phylogeny folder
The ASV phylogeny folder contains the files required or created by IQ-Tree when generating the Maximum Likelihood phylogeny of the ASVs. The resulting tree is stored in the main project directory.

- 6-Phylogeny/
  - 6-Phylogeny/ASVs.align.fasta
  - 6-Phylogeny/ASVs.align.fasta.bionj
  - 6-Phylogeny/ASVs.align.fasta.ckp.gz
  - 6-Phylogeny/ASVs.align.fasta.iqtree
  - 6-Phylogeny/ASVs.align.fasta.log
  - 6-Phylogeny/ASVs.align.fasta.mldist

- **ASVs.tre**

#### Binning folder
ASV sequences are binned into OTUs of 97% identity. The files required for the transformation are stored in the binning folder, while the binned results are stored in the main project directory.

- 7-Binning
  - 7-Binning/ASVs.counts.fasta
  - 7-Binning/ASVs.sorted.fasta
  - 7-Binning/binmap.txt
  - 7-Binning/bintable.txt

- **ASV_counts.binned.csv**
- **ASV_taxa.binned.txt**
- **ASVs.binned.fasta**
- **ASVs.binned.tre**

## References
If you use BAMSE, please acknowledge the following publications:
* Callahan, Benjamin J., et al. "DADA2: high-resolution sample inference from Illumina amplicon data." Nature methods 13.7 (2016): 581-583.
* Nguyen, Lam-Tung, et al. "IQ-TREE: a fast and effective stochastic algorithm for estimating maximum-likelihood phylogenies." Molecular biology and evolution 32.1 (2015): 268-274.
* Sievers, Fabian, and Desmond G. Higgins. "Clustal omega." Current protocols in bioinformatics 48.1 (2014): 3-13.
* Martin, Marcel. "Cutadapt removes adapter sequences from high-throughput sequencing reads." EMBnet. journal 17.1 (2011): 10-12.
* Bushnell, B. "BBTools: a suite of fast, multithreaded bioinformatics tools designed for analysis of DNA and RNA sequence data." Joint Genome Institute (2018).
