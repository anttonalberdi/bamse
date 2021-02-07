library(optparse)
library(gtools)

option_list = list(
 make_option("--i", type = "character",default = NULL,help = "Input ASV count table",metavar = "character"),
 make_option("--b", type = "character",default = NULL, help = "Input binning table", metavar = "character"),
 make_option("--o", type = "character",default = NULL,help = "Output ASV table",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

asvcounttable <- opt$i
binningtable <- opt$b
outputtable <- opt$o

asvtable<- read.table(asvcounttable,header=TRUE, row.names=1, sep=",")
bintable <- read.table(binningtable,sep="\t")

#Filter bintable
bintable2 <- bintable[bintable[,1] != "C",]

#Create replace vector
asvvector <- c()
for (i in c(1:nrow(bintable2))){
binrow <- bintable2[i,]
child <- binrow[9]
parent <- binrow[10]

if(parent == "*"){
  value <- gsub("\\;size.*","",child[1,1])
}else{
  value <- gsub("\\;size.*","",parent[1,1])
}
asvvector <- c(asvvector,value)
}

#Aggregate
asvtablevector <- cbind(asvtable,asvvector)
bincounttable <- aggregate(asvtablevector[,-ncol(asvtablevector)],by=list(asvtablevector[,ncol(asvtablevector)]),FUN=sum)
rownames(bincounttable) <- bincounttable[,1]
bincounttable <- bincounttable[,-1]

#Sort ASVs
reorder <- rownames(bincounttable)
reorder <- reorder[order(nchar(reorder), reorder)]
bincounttable <- bincounttable[reorder,]

#Output aggregated table
write.table(bincounttable,outputtable,sep=",",quote=FALSE)
