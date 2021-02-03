#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-i ASVs.fastq] [-a ASVs.align.fastq] [-t ASVs.tree] [-c threads]" 1>&2; exit 1; }

while getopts ":i:a:t:c:" x; do
    case "${x}" in

        i)
            i=${OPTARG}
            ;;
        a)
            a=${OPTARG}
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

if [ -z "${i}" ] || [ -z "${a}" ] || [ -z "${t}" ] || [ -z "${c}" ]; then
    usage
fi

fasta=$i
alignment=$a
tree=$t
threads=$c

#####
# Perform alignment
#####

clustalo -i ${fasta} -o ${alignment} --threads ${threads}

#####
# Build tree
#####

raxml-ng --msa ${alignment} --model GTR --tree pars{1} --prefix ${alignment} --lh-epsilon 1.0 --spr-cutoff 0.5 --threads ${threads} --seed 100 --force
