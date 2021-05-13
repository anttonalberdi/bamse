#2020/10/25 - BAMSE 1.0

library(optparse)
library(stringr)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-i", "--input"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-o", "--output"),type = "character",default = NULL, help = "Output trim document",metavar = "character"),
 make_option(c("-n", "--pattern"),type = "character",default = NULL, help = "Suffix pattern",metavar = "character"),
 make_option(c("-p", "--param"),type = "character",default = NULL, help = "Parameters file",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
inputdir<-opt$input
outputfile<-opt$output
pattern<-opt$pattern
paramfile<-opt$param
logfile<-opt$log

#inputdir="/Users/anttonalberdi/bamse_evie/2-Filtered/"
#paramfile="/Users/anttonalberdi/MiSeq_SOP_bamse/bamse.yaml"

trimtablist <- list.files(path = inputdir, pattern = pattern, full.names=TRUE, recursive=TRUE)
if(pattern == "csv"){
trimtablist <- trimtablist[!grepl("rev.csv",trimtablist)]
}

trimtab = lapply(trimtablist, function(x){as.data.frame(read.csv(x, header=FALSE))})
trimtabind = lapply(trimtab, function(x){cbind(score=x[,1],index=paste(x[,2],x[,3],sep="_"))})

#If untrimmed
if (all(is.na(unlist(trimtab)))){
  vector <- unlist(trimtabind)
  vector <- vector[!is.na(vector)]
  vector <- str_split(vector,"_")
  opt_read1 <- round(mean(as.numeric(unlist(lapply(vector, `[`, 1)))))
  opt_read2 <- round(mean(as.numeric(unlist(lapply(vector, `[`, 2)))))
  write.table(c(opt_read1,opt_read2,'average'),outputfile,quote=FALSE,row.names=FALSE,col.names=FALSE)

#If trimmed
}else{
  trimmatrix <- Reduce(function(x, y) merge(x, y, by = "index", all=TRUE), trimtabind)
  rownames(trimmatrix) <- trimmatrix[,1]
  trimmatrix <- trimmatrix[,-1]
  trimmatrix[] <- lapply(trimmatrix, function(x) as.numeric(as.character(x)))
  opt <- names(sort(rowMeans(trimmatrix,na.rm=TRUE),decreasing = TRUE)[1])
  opt_read1 <- str_split(opt,"_")[[1]][1]
  opt_read2 <- str_split(opt,"_")[[1]][2]
  write.table(c(opt_read1,opt_read2,'optimised'),outputfile,quote=FALSE,row.names=FALSE,col.names=FALSE)
}

#Save to parameter file
#write(paste("read1_trim:\n",opt_read1,sep=" "),file=paramfile,append=TRUE)
#write(paste("read2_trim:\n",opt_read2,sep=" "),file=paramfile,append=TRUE)
#Not in use anymore
