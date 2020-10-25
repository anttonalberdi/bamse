#2020/10/25 - BAMSE 1.0
#use optparse for parsing variables
#https://github.com/lachlandeer/snakemake-econ-r/blob/master/src/data-management/rename_variables.R

# CLI parsing
library(optparse)

option_list = list(
 make_option("-i1",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("-i2", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character"),
 make_option("-o1",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("-o2", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character"),
 make_option("--maxN",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("--maxEE", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character"),
 make_option("--truncQ",type = "character",default = NULL,help = "stata dataset file name",metavar = "character"),
 make_option("--truncLen", type = "character", default = "NULL", help = "output file name [default = %default]", metavar = "character")
);

opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);

i1<-opt$i1
i2<-opt$i2
o1<-opt$01
o2<-opt$02
maxN<-opt$maxN
maxEE<-opt$maxEE
truncQ<-opt$truncQ
truncLen<-opt$truncLen

print(i1)
print(i2)
print(o1)
print(o1)

library(dada2)
filterAndTrim(i1, i2, o1, o2, maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE, truncLen=c(100,100), compress=TRUE, multithread=TRUE)
