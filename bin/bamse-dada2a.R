#2020/10/25 - BAMSE 1.0

library(optparse)
library(Rcpp)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-i", "--input"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-o", "--output"),type = "character",default = NULL, help = "Output R object",metavar = "character"),
 make_option(c("-p", "--pattern"),type = "character",default = NULL, help = "Suffix pattern",metavar = "character"),
 make_option(c("-v", "--overlap"),type = "character",default = NULL, help = "Minimum overlap value",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$input
pattern<-opt$pattern
outputfile<-opt$output
overlap<-as.numeric(opt$overlap)
logfile <- opt$log

#dir="/Users/anttonalberdi/bamse_evie/2-Filtered/B"

#####
# List files
#####
#This step has been updated in February 2021 to avoid forward and reverse read to be sorted differently
#if there are names that interfere with the _1 and _2 suffixes.

filtFs_list <- gsub(paste("_1.",pattern,sep=""),"",list.files(path = dir, pattern = paste("_1.",pattern,sep=""), full.names=TRUE))
filtRs_list <- gsub(paste("_2.",pattern,sep=""),"",list.files(path = dir, pattern = paste("_2.",pattern,sep=""), full.names=TRUE))

#Check if both vectors contain the same elements
if (setequal(filtFs_list, filtRs_list) == TRUE){
  filtFs <- paste(filtFs_list,paste("_1.",pattern,sep=""),sep="")
  filtRs <- paste(filtFs_list,paste("_2.",pattern,sep=""),sep="")
}else{
  print("ERROR! The forward and reverse reads do not match")
}

#####
# Detect and remove empty files
#####

#Detect empty files
filtFs_info = file.info(filtFs)
filtFs_empty = rownames(filtFs_info[filtFs_info$size == 0, ])

filtRs_info = file.info(filtRs)
filtRs_empty = rownames(filtRs_info[filtRs_info$size == 0, ])

#Remove empty files
filtFs <- filtFs[!filtFs %in% filtFs_empty]
filtRs <- filtRs[!filtRs %in% filtRs_empty]

#####
# Dereplicate
#####

#Append to log file
line="  Dereplicating samples"
write(line,file=logfile,append=TRUE)

drpFs <- derepFastq(filtFs)
drpRs <- derepFastq(filtRs)

#Output to stats file
path <- sub("2-Filtered.*","",dir)

#If more than one sample
if (length(filtFs) > 1){
  loop <- c(1:length(drpFs))
  for (i in loop){
    name <- names(drpFs)[i]
    name2 <- sub("_1.fastq","",name)
    statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
    dereplicated <- length(drpFs[[i]]$uniques)
    write(paste("Dereplicated reads",dereplicated,sep="\t"),file=statsfile,append=TRUE)
  }
}

#If a single sample
if (length(filtFs) == 1){
  name <- sub(".*/","",filtFs)
  name2 <- sub("_1.fastq","",name)
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  dereplicated <- length(drpFs$uniques)
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

merged_amplicons <- mergePairs(dadaFs, drpFs, dadaRs, drpRs, minOverlap=overlap)

#####
# Make sequence table
#####

seqtab <- makeSequenceTable(merged_amplicons)

#####
# Save R object
#####

saveRDS(seqtab,outputfile)
