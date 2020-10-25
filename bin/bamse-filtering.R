#2020/10/25 - BAMSE 1.0

workdir<-Sys.getenv("WORKDIR")[1]
i1<-Sys.getenv("i1")[3]
i2<-Sys.getenv("i2")[4]
o1<-Sys.getenv("o1")[3]
o2<-Sys.getenv("o2")[4]
maxN<-Sys.getenv("maxN")[5]
maxEE<-Sys.getenv("maxEE")[6]
truncQ<-Sys.getenv("truncQ")[7]
truncLen<-Sys.getenv("truncLen")[8]

print(i1)
print(i2)
print(o1)
print(o1)

library(dada2)
filterAndTrim(i1, i2, o1, o2, maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE, truncLen=c(100,100), compress=TRUE, multithread=TRUE)
