#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-i ASVs.fastq] [-a ASVs.align.fastq] [-d projectdir] [-t ASVs.tree] [-c threads]" 1>&2; exit 1; }

while getopts ":i:a:d:t:c:" x; do
    case "${x}" in

        i)
            i=${OPTARG}
            ;;
        a)
            a=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${a}" ] || [ -z "${d}" ] || [ -z "${t}" ] || [ -z "${c}" ]; then
    usage
fi

fasta=$i
alignment=$a
projectdir=$d
tree=$t
threads=$c

#####
# Perform alignment
#####

clustalo -i ${fasta} -o ${alignment} --threads ${threads} 2> /dev/null

#####
# Build tree
#####

iqtree -s ${alignment} -T 4 -m GTR 2> /dev/null
mv ${projectdir}/6-Phylogeny/ASVs.align.fasta.treefile ${tree}
