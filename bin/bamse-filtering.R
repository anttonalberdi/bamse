#2020/10/25 - BAMSE 1.0


i1<-snakemake@input[["i1"]]
i2<-snakemake@input[["i2"]]
o1<-snakemake@input[["o1"]]
o2<-snakemake@input[["o2"]]
maxN<-snakemake@params[["maxN"]]
maxEE<-snakemake@params[["maxEE"]]
truncQ<-snakemake@params[["truncQ"]]
truncLen<-snakemake@params[["truncLen"]]

print(i1)
print(i2)
print(o1)
print(o1)

library(dada2)
filterAndTrim(i1, i2, o1, o2, maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE, truncLen=c(100,100), compress=TRUE, multithread=TRUE)
