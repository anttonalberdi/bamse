#!/bin/bash

#2021/02/06 - BAMSE 1.0

usage() { echo "Usage: $0 [-a ASV_counts.csv] [-f ASVs.fasta] [-m 7-Binning/binmap.txt] [-c 7-Binning/ASVs.counts.fasta] [-s 7-Binning/ASVs.counts.sorted.fasta] [-t 7-Binning/bintable.txt] [-b ASVs.binned.fasta]" 1>&2; exit 1; }

while getopts ":a:f:m:c:s:t:b:" o; do
    case "${o}" in

        a)
            a=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        m)
            m=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${a}" ] || [ -z "${f}" ] || [ -z "${m}" ] || [ -z "${c}" ] || [ -z "${s}" ] || [ -z "${t}" ] || [ -z "${b}" ]; then
    usage
fi

counts=$a
asvfasta=$f
binmap=$m
asvfastacounts=$c
asvfastasorted=$s
bintable=$t
asvfastabinned=$b

#####
# Generate bin mapping file
#####

#Enable posix interface
set +o posix

paste <(cat ${counts} | sed '1d' | cut -d',' -f1 | sed 's/$/\$/g') <(paste -d'=' <(cat ${counts} | sed '1d' | cut -d',' -f1 | sed 's/$/\;size/g') <(cat ${counts} | sed '1d' | awk -F  "," '{ for(i=2; i<=NF;i++) j+=$i; print j; j=0 }')) > ${binmap}

#Add counts
awk 'FNR==NR{A[$1]=$2;next}{for(i in A)gsub(i,A[i])}1' ${binmap} ${asvfasta} > ${asvfastacounts}

#Sort ASVs by counts
vsearch --sortbysize ${asvfastacounts} --output ${asvfastasorted} 2> /dev/null

#Perform clustering
VSEARCH --cluster_size ${asvfastasorted} \
    --threads 4 \
    --id 0.97 \
    --strand plus \
    --sizein \
    --fasta_width 0 \
    --uc ${bintable} \
    --centroids - 2> /dev/null | sed 's/\;.*//g' > ${asvfastabinned} 
