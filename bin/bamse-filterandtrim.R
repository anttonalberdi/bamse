#2020/10/25 - BAMSE 1.0

library(optparse)
library(Rcpp)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-i", "--input"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-o", "--output"),type = "character",default = NULL, help = "Output directory",metavar = "character"),
 make_option(c("-t", "--trim"),type = "character",default = NULL, help = "Trimming information file",metavar = "character"),
 make_option(c("-e", "--maxee"),type = "character",default = NULL, help = "MEE",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
inputdir<-opt$input
outputdir<-opt$output
trimfile<-opt$trim
reversetrim<-opt$reverse
maxee<-opt$maxee

#inputdir="/Users/anttonalberdi/MiSeq_SOP_bamse/0-Data/"

triminfo <- read.table(trimfile,header=FALSE)

forwardtrim=triminfo[1,]
reversetrim=triminfo[2,]

read1_list <- list.files(path = inputdir, pattern = "_1.fastq", full.names=TRUE, recursive=TRUE)
read2_list <- list.files(path = inputdir, pattern = "_2.fastq", full.names=TRUE, recursive=TRUE)

#Generate output read list
read1_out <- gsub(inputdir,outputdir,read1_list)
read2_out <- gsub(inputdir,outputdir,read2_list)

filterAndTrim(
  fwd = read1_list,
  rev = read2_list,
  filt = read1_out,
  filt.rev = read2_out,
  compress = FALSE,,
  truncLen = c(forwardtrim,reversetrim),
  maxEE = c(maxee,maxee),
  rm.phix = TRUE,
  OMP = TRUE,
  qualityType = "Auto",
  verbose = FALSE
)
