#2020/10/25 - BAMSE 1.0

library(optparse)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-d", "--directory"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-t", "--taxonomy"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-a", "--asvfile"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-c", "--count"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-x", "--taxa"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$directory
taxonomy <- opt$taxonomy
asvfile <- opt$asvfile
countfile <- opt$count
taxafile <- opt$taxa
logfile <- opt$log

#####
# List files
#####

filtFs <- list.files(path = dir, pattern = "_1.fastq", full.names=TRUE)
filtRs <- list.files(path = dir, pattern = "_2.fastq", full.names=TRUE)

#####
# Dereplicate
#####

#Append to log file
line="  Dereplicating samples"
write(line,file=logfile,append=TRUE)

drpFs <- derepFastq(filtFs, verbose=TRUE)
drpRs <- derepFastq(filtRs, verbose=TRUE)


#####
# Learn errors
#####

#Append to log file
line="  Learning errors"
write(line,file=logfile,append=TRUE)

errFs <- learnErrors(filtFs, multithread=TRUE)
errRs <- learnErrors(filtRs, multithread=TRUE)

#####
# Dada
#####

line="  Generating ASVs"
write(line,file=logfile,append=TRUE)

dadaFs <- dada(drpFs, err=errFs, multithread=TRUE)
dadaRs <- dada(drpRs, err=errRs, multithread=TRUE)

#####
# Merge amplicons
#####

merged_amplicons <- mergePairs(dadaFs, drpFs, dadaRs, drpRs, justConcatenate = TRUE)

#Remove Ns
loop <- c(1:length(merged_amplicons))
for (i in loop){
  merged_amplicons[[i]]$sequence <- gsub("NNNNNNNNNN","",merged_amplicons[[i]]$sequence)
}

seqtab <- makeSequenceTable(merged_amplicons)

#####
# Chimera filtering
#####

line="  Filtering chimeras"
write(line,file=logfile,append=TRUE)

seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
asv_tab <- t(seqtab.nochim)

#####
# Output ASV fasta
#####

asv_seqs <- rownames(asv_tab)
asv_headers <- vector(dim(asv_tab)[1], mode="character")
for (i in 1:dim(asv_tab)[1]) {
    asv_headers[i] <- paste(">ASV", i, sep="_")
    }
asv_fasta <- c(rbind(asv_headers, asv_seqs))
write(asv_fasta, asvfile)

#####
# Output count table
#####

colnames(asv_tab) <- sub("_1.fastq", "", colnames(asv_tab))
rownames(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, countfile, sep=",", quote=F, col.names=NA)

#####
# Assign taxonomy
#####

line="  Assigning taxonomy"
write(line,file=logfile,append=TRUE)

taxa <- assignTaxonomy(seqtab.nochim, taxonomy, tryRC=T, multithread=TRUE)
row.names(taxa) <- sub(">", "", asv_headers)
write.table(taxa, taxafile, sep=",", quote=F, col.names=NA)
