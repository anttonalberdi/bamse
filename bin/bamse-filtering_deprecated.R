#2020/10/25 - BAMSE 1.0
#use optparse for parsing variables
#https://github.com/lachlandeer/snakemake-econ-r/blob/master/src/data-management/rename_variables.R

# CLI parsing
library(optparse)

option_list = list(
 make_option("--i1",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("--i2", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character"),
 make_option("--o1",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("--o2", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character"),
 make_option("--params", type = "character", default = "NULL", help = "Sample parameters", metavar = "character")

);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

i1<-opt$i1
i2<-opt$i2
o1<-opt$o1
o2<-opt$o2
params<-opt$params

params <- read.table(params,header=FALSE,sep="\t")
truncLen <- c(params[1,2],params[2,2])

#Not using it for now
minq <- params[3,2]
ee1 <- 10^(minq/-10)*truncLen[1]
ee2 <- 10^(minq/-10)*truncLen[2]
maxee <- c(ee1,ee2)

library(dada2)
filterAndTrim(fwd=i1, filt=o1, rev=i2, filt.rev=o2, maxN=0, maxEE=Inf, truncQ=0, rm.phix=TRUE, truncLen=truncLen, compress=FALSE, multithread=TRUE)
