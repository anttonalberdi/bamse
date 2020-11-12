#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-i ASVs.fastq] [-l ASV_counts_lulu.txt] [-o ASVs_lulu.fastq]" 1>&2; exit 1; }

while getopts ":i:l:o:" x; do
    case "${x}" in

        i)
            i=${OPTARG}
            ;;
        l)
            l=${OPTARG}
            ;;
        o)
            o=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${l}" ] || [ -z "${o}" ]; then
    usage
fi

input=$i
lulutable=$l
output=$o


#####
# Filter fasta file
#####

cut -d',' -f1 ${lulutable} | sed '1d' | sed 's/ASV/\>ASV/' | sed 's/$/\$/' > ${lulutable}.list
grep -A1 -f ${lulutable}.list ${input} | grep -v -- '^--$' > ${output}
rm ${lulutable}.list

#####
# Merge stats info
#####

#Merge info
#cut -f2 bamse-test/0-Stats/* | awk -vn=8 '{a[NR]=$0}END{ x=1; while (x<=n){ for(i=x;i<=length(a);i+=n) printf a[i]" "; print ""; x++; } }' > bamse-test/statistics.txt
#names
#headers=$(ls -a bamse-test/0-Stats/* | sed 's/.*\///' | sed 's/\.txt//' | tr "\n" "\t")
#echo "${headers}" | cat - bamse-test/statistics.txt > bamse-test/statistics2.txt
