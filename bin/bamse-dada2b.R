#2020/10/25 - BAMSE 1.0

library(optparse)
library(Rcpp)
library(dada2)

#####
# Parse arguments
#####


option_list = list(
 make_option(c("-d", "--directory"),type = "character",default = NULL, help = "Input directory",metavar = "character"),
 make_option(c("-t", "--taxonomy"),type = "character",default = NULL, help = "Output taxonomy file",metavar = "character"),
 make_option(c("-a", "--asvfile"),type = "character",default = NULL, help = "Output ASV sequence file",metavar = "character"),
 make_option(c("-c", "--count"),type = "character",default = NULL, help = "Output count table",metavar = "character"),
 make_option(c("-x", "--taxa"),type = "character",default = NULL, help = "Taxonomy database path",metavar = "character"),
 make_option(c("-r", "--threshold"),type = "character",default = NULL, help = "Relative copy number filtering threshold",metavar = "character"),
 make_option(c("-f", "--fold"),type = "character",default = NULL, help = "Min Fold Parent Over Abundance",metavar = "character"),
 make_option(c("-l", "--log"),type = "character",default = NULL, help = "Log file",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)
dir<-opt$directory
taxonomy <- opt$taxonomy
asvfile <- opt$asvfile
countfile <- opt$count
taxafile <- opt$taxa
threshold <- as.numeric(opt$threshold)
fold <- as.numeric(opt$fold)
logfile <- opt$log

#dir="/Users/anttonalberdi/bamse_evie/3-DADA2"

#####
# Read rds files
#####

filelist <- list.files(path = dir, pattern = ".rds", full.names=TRUE)
SequenceTableList <- lapply(filelist,readRDS)

#####
# Merge different runs
#####

if(length(SequenceTableList) == 1){
seqtab <- as.data.frame(SequenceTableList[[1]])
}else{
seqtab <- as.data.frame(mergeSequenceTables(tables=SequenceTableList))
}

#####
# Aggregate samples with split from primer trimming
#####

seqtab$sample <- gsub("_1.fastq$","",(gsub("_1.rev.fastq$","",rownames(seqtab))))
seqtab_aggregated <- aggregate(seqtab[,-ncol(seqtab)],by=list(seqtab$sample),FUN=sum)
rownames(seqtab_aggregated) <- seqtab_aggregated[,1]
seqtab_aggregated <- seqtab_aggregated[,-1]

# Output ASVs before chimera filtering to stats file
path <- sub("3-DADA2","",dir)

loop <- c(1:nrow(seqtab_aggregated))
for (i in loop){
  name <- rownames(seqtab_aggregated)[i]
  name2 <- sub("_1.fastq","",name)
  asvs <- rowSums(seqtab_aggregated!=0)[i]
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  write(paste("ASVs before chimera filtering",asvs,sep="\t"),file=statsfile,append=TRUE)
}
message(paste("\n",ncol(seqtab_aggregated)," ASVs have been generated before chimera filtering.",sep=""))

#####
# Chimera filtering
#####

line="  Filtering chimeras"
write(line,file=logfile,append=TRUE)

seqtab.nochim <- removeBimeraDenovo(as.matrix(seqtab_aggregated), method="consensus", multithread=TRUE, verbose=TRUE, minFoldParentOverAbundance=fold)
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
message(paste(ncol(seqtab.nochim)," ASVs have been kept after chimera filtering.",sep=""))

#####
# Filter count table
#####

#Convert values below relative copy number threshold in each sample to 0
if(threshold != 0){
  invisible(sapply(1:ncol(asv_tab), function(colnum){temp = asv_tab[,colnum]
      rownums = which(temp < sum(temp)*threshold)
      asv_tab[rownums, colnum] <<- 0}))
}

#Filter all-zero ASVs
asv_tab <- asv_tab[!apply(asv_tab, 1, function(x) all(x == 0)), ]
message(paste(nrow(asv_tab)," ASVs have been kept after relative copy number threshold filtering.",sep=""))

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
# Output raw count table
#####

rownames(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, countfile, sep=",", quote=F, col.names=NA)

# Output ASV reads to stats file
path <- sub("3-DADA2","",dir)

loop <- c(1:ncol(asv_tab))
for (i in loop){
  name <- colnames(asv_tab)[i]
  counts <- sum(asv_tab[,i])
  statsfile <- paste(path,"0-Stats/",name,".txt",sep="")
  write(paste("Reads represented by ASVs",counts,sep="\t"),file=statsfile,append=TRUE)
}

#####
# Assign taxonomy
#####

message("Assigning taxonomy... (this step will probably take a while)")
line="  Assigning taxonomy"
write(line,file=logfile,append=TRUE)

#Filter chimera-filtered file
seqtab.nochim.filt <- seqtab.nochim[,colnames(seqtab.nochim) %in% asv_seqs]

#Assign taxonomy
taxa <- assignTaxonomy(seqtab.nochim.filt, taxonomy, tryRC=T, multithread=TRUE)
row.names(taxa) <- sub(">", "", asv_headers)

#Get taxonomy stats
phyla <- taxa[,2]
annotated <- length(phyla[!is.na(phyla)])
total <- nrow(taxa)
percentage <- round(annotated/total*100,2)

message(paste(annotated," (",percentage,"%)"," ASVs have been annotated at at least Phylum level.",sep=""))

write.table(taxa, taxafile, sep=",", quote=F, col.names=NA)
