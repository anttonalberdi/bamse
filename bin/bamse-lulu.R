library(optparse)

option_list = list(
 make_option("--i",type = "character",default = NULL,help = "Input ASV table",metavar = "character"),
 make_option("--m", type = "character", default = "NULL", help = "Match file", metavar = "character"),
 make_option("--o",type = "character",default = NULL,help = "Output ASV table",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

table <- opt$i
match <- opt$m
output <- opt$o


library(lulu)

curated_result <- lulu(table, match)
write.table(curated_result$curated_table,output)
