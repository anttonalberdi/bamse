#2020/10/25 - BAMSE 1.0

library(optparse)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-d", "--directory"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-t", "--taxonomy"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-a", "--asvfile"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-c", "--count"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-x", "--taxa"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$directory
taxonomy <- opt$taxonomy
asvfile <- opt$asvfile
countfile <- opt$count
taxafile <- opt$taxa
logfile <- opt$log

#####
# Read rds files
#####

filelist <- list.files(path = dir, pattern = ".rds", full.names=TRUE)
SequenceTableList <- lapply(filelist,readRDS)

#####
# Merge different run
#####

if(length(SequenceTableList) == 1){
seqtab <- as.matrix(SequenceTableList[[1]])
}else{
seqtab <- as.matrix(mergeSequenceTables(tables=SequenceTableList))
}

# Output ASVs before chimera filtering to stats file
path <- sub("3-DADA2","",dir)

loop <- c(1:nrow(seqtab))
for (i in loop){
  name <- rownames(seqtab)[i]
  name2 <- sub("_1.fastq","",name)
  asvs <- rowSums(seqtab!=0)[i]
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  write(paste("ASVs before chimera filtering",asvs,sep="\t"),file=statsfile,append=TRUE)
}

#####
# Chimera filtering
#####

line="  Filtering chimeras"
write(line,file=logfile,append=TRUE)

seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE)
asv_tab <- t(seqtab.nochim)

# Output ASVs before chimera filtering to stats file
path <- sub("3-DADA2","",dir)

loop <- c(1:nrow(seqtab.nochim))
for (i in loop){
  name <- rownames(seqtab.nochim)[i]
  name2 <- sub("_1.fastq","",name)
  asvs <- rowSums(seqtab.nochim!=0)[i]
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  write(paste("ASVs after chimera filtering",asvs,sep="\t"),file=statsfile,append=TRUE)
}

#####
# Output ASV fasta
#####

asv_seqs <- rownames(asv_tab)
asv_headers <- vector(dim(asv_tab)[1], mode="character")
for (i in 1:dim(asv_tab)[1]) {
    asv_headers[i] <- paste(">ASV", i, sep="_")
    }
asv_fasta <- c(rbind(asv_headers, asv_seqs))
write(asv_fasta, asvfile)

#####
# Output count table
#####

colnames(asv_tab) <- sub("_1.fastq", "", colnames(asv_tab))
rownames(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, countfile, sep=",", quote=F, col.names=NA)

# Output ASV reads to stats file
path <- sub("3-DADA2","",dir)

loop <- c(1:ncol(asv_tab))
for (i in loop){
  name <- colnames(asv_tab)[i]
  name2 <- sub("_1.fastq","",name)
  counts <- sum(asv_tab[,i])
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  write(paste("Reads represented by ASVs",counts,sep="\t"),file=statsfile,append=TRUE)
}

#####
# Assign taxonomy
#####

line="  Assigning taxonomy"
write(line,file=logfile,append=TRUE)

taxa <- assignTaxonomy(seqtab.nochim, taxonomy, tryRC=T, multithread=TRUE)
row.names(taxa) <- sub(">", "", asv_headers)
write.table(taxa, taxafile, sep=",", quote=F, col.names=NA)
