#2020/10/25 - BAMSE 1.0

library(optparse)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-i", "--input"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-o", "--output"),type = "character",default = NULL, help = "Output R object",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$input
outputfile<-opt$output
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

drpFs <- derepFastq(filtFs)
drpRs <- derepFastq(filtRs)

#Output to stats file
path <- sub("3-Trimmed.*","",dir)

loop <- c(1:length(drpFs))
for (i in loop){
  name <- names(drpFs)[i]
  name2 <- sub("_1.fastq","",name)
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  dereplicated <- length(drpFs[[i]]$uniques)
  write(paste("Dereplicated reads",dereplicated,sep="\t"),file=statsfile,append=TRUE)
}

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

#####
# Make sequence table
#####

seqtab <- makeSequenceTable(merged_amplicons)

#####
# Save R object
#####

#run <- sub('.*\\/', '', dir)
#outputfile2 <- paste(outputfile,run,sep="")
saveRDS(seqtab,outputfile)
