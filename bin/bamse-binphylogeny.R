library(optparse)
library(gtools)
library(ape)

option_list = list(
 make_option("--i", type = "character",default = NULL,help = "Input binned ASV count table",metavar = "character"),
 make_option("--t", type = "character",default = NULL, help = "Input unbinned ASV tree", metavar = "character"),
 make_option("--o", type = "character",default = NULL,help = "Output ASV table",metavar = "character")
);

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

bincounttable <- opt$i
inputtree <- opt$t
outputtreefile <- opt$o

inputtree <- read.tree(inputtree)
bintable <- read.table(bincounttable,header=TRUE, row.names=1, sep=",")

#Identify tips to removed
tipstoremove <- setdiff(inputtree$tip.label,rownames(bintable))
outputtree <- drop.tip(inputtree, tipstoremove)

#Write tre
write.tree(outputtree,outputtreefile)
