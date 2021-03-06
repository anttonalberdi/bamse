library(optparse)
library(gtools)

option_list = list(
 make_option("--i", type = "character",default = NULL,help = "Input ASV table",metavar = "character"),
 make_option("--m", type = "character",default = NULL, help = "Match file", metavar = "character"),
 make_option("--o", type = "character",default = NULL,help = "Output ASV table",metavar = "character"),
 make_option("--r", type = "character",default = NULL,help = "Output ASV mapping results",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

table <- opt$i
match <- opt$m
output <- opt$o
output2 <- opt$r

#Declare LULU function
lulu <- function(otutable, matchlist, minimum_ratio_type = "min", minimum_ratio = 1, minimum_match = 84, minimum_relative_cooccurence = 0.95) {
  require(dplyr)
  start.time <- Sys.time()
  colnames(matchlist) <- c("OTUid", "hit", "match")
  # remove no hits (vsearch)
  matchlist = matchlist[which(matchlist$hit != "*"), ]
  # remove self-hits
  matchlist = matchlist[which(matchlist$hit != matchlist$OTUid), ]

  # Making a separate table with stats (total readcount and spread).
  statistics_table <- otutable[, 0]
  statistics_table$total <- rowSums(otutable)

  # calculating spread (number of presences (samples with 1+ read) pr OTU)
  statistics_table$spread <- rowSums(otutable > 0)
  statistics_table <- statistics_table[with(statistics_table,
                                            order(spread,
                                                  total,
                                                  decreasing = TRUE)), ]
  otutable <- otutable[match(row.names(statistics_table),
                             row.names(otutable)), ]

  statistics_table$parent_id <- "NA"
  log_con <- file(paste0("lulu.log_", format(start.time, "%Y%m%d_%H%M%S")),
                  open = "a")
  for (line in seq(1:nrow(statistics_table))) {
    # make a progressline
    #print(paste0("progress: ", round(((line/nrow(statistics_table)) * 100), 0), "%"))
    potential_parent_id <- row.names(otutable)[line]
    cat(paste0("\n", "####processing: ", potential_parent_id, " #####"),
        file = log_con)
    daughter_samples <- otutable[line, ]
    hits <- matchlist[which(matchlist$OTUid == potential_parent_id &
                              matchlist$match > minimum_match), "hit"]
    cat(paste0("\n", "---hits: ", hits), file = log_con)
    last_relevant_entry <- sum(statistics_table$spread >=
                                 statistics_table$spread[line])
    potential_parents <- which(row.names(otutable)[1:last_relevant_entry]
                               %in% hits)
    cat(paste0("\n", "---potential parent: ",
               row.names(statistics_table)[potential_parents]), file = log_con)
    success <- FALSE
    if (length(potential_parents) > 0) {
      for (line2 in potential_parents) {
        cat(paste0("\n", "------checking: ", row.names(statistics_table)[line2]),
            file = log_con)
        if (!success) {
          relative_cooccurence <-
            sum((daughter_samples[otutable[line2, ] > 0]) > 0)/
            sum(daughter_samples > 0)
          cat(paste0("\n", "------relative cooccurence: ",
                     relative_cooccurence), file = log_con)
          if (relative_cooccurence >= minimum_relative_cooccurence) {
            cat(paste0(" which is sufficient!"), file = log_con)
            if (minimum_ratio_type == "avg") {
              relative_abundance <-
                mean(otutable[line2, ][daughter_samples > 0]/
                       daughter_samples[daughter_samples > 0])
              cat(paste0("\n", "------mean avg abundance: ",
                         relative_abundance), file = log_con)
            } else {
              relative_abundance <-
                min(otutable[line2, ][daughter_samples > 0]/
                      daughter_samples[daughter_samples > 0])
              cat(paste0("\n", "------min avg abundance: ",
                         relative_abundance), file = log_con)
            }
            if (relative_abundance > minimum_ratio) {
              cat(paste0(" which is OK!"), file = log_con)
              if (line2 < line) {
                statistics_table$parent_id[line] <-
                  statistics_table[row.names(otutable)[line2],"parent_id"]
                cat(paste0("\n", "SETTING ",
                           potential_parent_id, " to be an ERROR of ",
                           (statistics_table[row.names(otutable)[line2],
                                             "parent_id"]), "\n"),
                    file = log_con)
              } else {
                statistics_table$parent_id[line] <- row.names(otutable)[line2]
                cat(paste0("\n", "SETTING ", potential_parent_id,
                           " to be an ERROR of ", (row.names(otutable)[line2]),
                           "\n"), file = log_con)
              }
              success <- TRUE
            }
          }
        }
      }
    }
    if (!success) {
      statistics_table$parent_id[line] <- row.names(statistics_table)[line]
      cat(paste0("\n", "No parent found!", "\n"), file = log_con)
    }
  }

  close(log_con)
  total_abundances <- rowSums(otutable)
  curation_table <- cbind(nOTUid = statistics_table$parent_id, otutable)
  statistics_table$curated <- "merged"
  curate_index <- row.names(statistics_table) == statistics_table$parent_id
  statistics_table$curated[curate_index] <- "parent"
  statistics_table <- transform(statistics_table,
                                rank = ave(total,FUN = function(x)
                                  rank(-x, ties.method = "first")))
  curation_table <- as.data.frame(curation_table %>%
                                    group_by(nOTUid) %>%
                                    summarise_all(list(sum)))
  row.names(curation_table) <- as.character(curation_table$nOTUid)
  curation_table <- curation_table[, -1]
  curated_otus <- names(table(statistics_table$parent_id))
  curated_count <- length(curated_otus)
  discarded_otus <- setdiff(row.names(statistics_table), curated_otus)
  discarded_count <- length(discarded_otus)
  end.time <- Sys.time()
  time.taken <- end.time - start.time
  result <- list(curated_table = curation_table,
                 curated_count = curated_count,
                 curated_otus = curated_otus,
                 discarded_count = discarded_count,
                 discarded_otus = discarded_otus,
                 runtime = time.taken,
                 minimum_match = minimum_match,
                 minimum_relative_cooccurence = minimum_relative_cooccurence,
                 otu_map = statistics_table,
                 original_table = otutable)

  return(result)
}

#Read tables
asvtable <- read.table(table,sep=",",header=TRUE,row.names=1)
matchtable <- read.table(match,sep="\t",header=FALSE)

#Run LULU algorithm
curated_result <- lulu(asvtable, matchtable)
curated_ASVtable <- curated_result$curated_table
curated_ASVtable <- curated_ASVtable[mixedorder(rownames(curated_ASVtable)),]
curated_ASVmap <- curated_result$otu_map

# Output ASV reads to stats file
path <- sub("ASV_counts.csv","",table)

loop <- c(1:ncol(curated_ASVtable))
for (i in loop){
  name <- colnames(curated_ASVtable)[i]
  name2 <- sub("_1.fastq","",name)
  asvs <- colSums(curated_ASVtable!=0)[i]
  #counts <- sum(curated_ASVtable[,i])
  statsfile <- paste(path,"0-Stats/",name2,".txt",sep="")
  write(paste("OTUs after LULU curation",asvs,sep="\t"),file=statsfile,append=TRUE)
  #write(paste("Reads represented by ASVs after LULU curation",counts,sep="\t"),file=statsfile,append=TRUE)
}


#Output curated table
write.table(curated_ASVtable,output,sep=",",quote=FALSE)
write.table(curated_ASVmap,output2,sep=",",quote=FALSE)
