#2020/10/25 - BAMSE 1.0

library(optparse)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option("-d",type = "character",default = NULL,help = "Input directory",metavar = "character"),
 make_option("-o",type = "character",default = NULL,help = "Input directory",metavar = "character"),
 make_option("-c",type = "character",default = NULL,help = "Input directory",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$d
overlap <- opt$o
countfile <- opt$c

#####
# List files
#####

filtFs <- list.files(path = dir, pattern = "_1.fastq")
filtRs <- list.files(path = dir, pattern = "_2.fastq")

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

merged_amplicons <- mergePairs(dadaFs, drpFs, dadaRs, drpRs, minOverlap=overlap, verbose=TRUE)
seqtab <- makeSequenceTable(merged_amplicons)

#####
# Chimera filtering
#####

asv_tab <- t(removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE))

#####
# Output count table
#####

row.names(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, countfile, sep=",", quote=F, col.names=NA)
