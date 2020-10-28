#2020/10/25 - BAMSE 1.0

library(optparse)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-d", "--directory"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-t", "--taxonomy"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-o", "--overlap"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-a", "--asvfile"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-c", "--count"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-x", "--taxa"),type = "character",default = NULL, help = "Input directory",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$directory
overlap <- opt$overlap
taxonomy <- opt$taxonomy
asvfile <- opt$asvfile
countfile <- opt$count
taxafile <- opt$taxa

#####
# List files
#####

filtFs <- list.files(path = dir, pattern = "_1.fastq", full.names=TRUE)
filtRs <- list.files(path = dir, pattern = "_2.fastq", full.names=TRUE)

#####
# Dereplicate
#####

drpFs <- derepFastq(filtFs, verbose=TRUE)
drpRs <- derepFastq(filtRs, verbose=TRUE)

#####
# Learn errors
#####

errFs <- learnErrors(filtFs, multithread=TRUE)
errRs <- learnErrors(filtRs, multithread=TRUE)

#####
# Dada
#####

dadaFs <- dada(drpFs, err=errFs, multithread=TRUE)
dadaRs <- dada(drpRs, err=errRs, multithread=TRUE)

#####
# Merge amplicons
#####

merged_amplicons <- mergePairs(dadaFs, drpFs, dadaRs, drpRs, minOverlap=overlap, maxMismatch=int(overlap/3),verbose=TRUE)
seqtab <- makeSequenceTable(merged_amplicons)

#####
# Chimera filtering
#####

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

taxa <- assignTaxonomy(seqtab.nochim, taxonomy, tryRC=T, multithread=TRUE)
row.names(taxa) <- sub(">", "", asv_headers)
write.table(taxa, taxafile, sep=",", quote=F, col.names=NA)
