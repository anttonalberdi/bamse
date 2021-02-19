#2020/10/25 - BAMSE 1.0

library(optparse)
library(Rcpp)
library(dada2)

#####
# Parse arguments
#####

option_list = list(
 make_option(c("-f", "--read1"),type = "character",default = NULL, help = "Forward read",metavar = "character"),
 make_option(c("-r", "--read2"),type = "character",default = NULL, help = "Reverse read",metavar = "character"),
 make_option(c("-o", "--out1"),type = "character",default = NULL, help = "Output forward read",metavar = "character"),
 make_option(c("-u", "--out2"),type = "character",default = NULL, help = "Output reverse read",metavar = "character"),
 make_option(c("-t", "--trim"),type = "character",default = NULL, help = "Trimming information file",metavar = "character"),
 make_option(c("-e", "--maxee"),type = "character",default = NULL, help = "MEE",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
read1<-opt$read1
read2<-opt$read2
output1<-opt$out1
output2<-opt$out2
trimfile<-opt$trim
maxee<-opt$maxee

#####
# Prepare trimming information
#####

triminfo <- read.table(trimfile,header=FALSE)
forwardtrim=as.numeric(triminfo[1,])
reversetrim=as.numeric(triminfo[2,])

#####
# List input files
#####

#read1_list <- list.files(path = inputdir, pattern = "_1.fastq", full.names=TRUE, recursive=TRUE)
#read2_list <- list.files(path = inputdir, pattern = "_2.fastq", full.names=TRUE, recursive=TRUE)

#####
# List output files
#####

#read1_out <- gsub(inputdir,outputdir,read1_list)
#read2_out <- gsub(inputdir,outputdir,read2_list)

#####
# Perform filtering
#####

filterAndTrim(
    fwd = read1,
    rev = read2,
    filt = output1,
    filt.rev = output2,
    compress = FALSE,,
    truncLen = c(forwardtrim,reversetrim),
    maxEE = c(maxee,maxee),
    rm.phix = TRUE,
    OMP = TRUE,
    qualityType = "Auto",
    verbose = FALSE)
