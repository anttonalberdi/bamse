#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-a ASVs.fasta] [-c ASV_counts.csv] [-t ASV_taxa.txt] [-f filteredASVs.txt] [-s ASVs.filtered_out.fasta] [-u ASVs.filtered.fasta] [-v ASV_counts.filtered.csv] [-w ASV_taxa.filtered.txt] [-x taxonomic_level]" 1>&2; exit 1; }

while getopts ":a:c:t:f:s:u:v:w:x:" o; do
    case "${o}" in

        a)
            a=${OPTARG}
            ;;
        c)
            c=${OPTARG}
           ;;
        t)
            t=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        u)
            u=${OPTARG}
            ;;
        v)
            v=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;
        x)
            x=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${a}" ] || [ -z "${c}" ] || [ -z "${t}" ] || [ -z "${f}" ] || [ -z "${s}" ] || [ -z "${u}" ] || [ -z "${v}" ] || [ -z "${w}" ] || [ -z "${x}" ]; then
    usage
fi

asvs=$a
counts=$c
taxonomy=$t
filterlist=$f
filterfasta=$s
asvsfilt=$u
countsfilt=$v
taxonomyfilt=$w
taxonomylevel=$x



#####
# Filter fasta file
#####

#Identify ASVs to be filtered
if [ ${taxonomylevel} = "kingdom" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($2 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi
if [ ${taxonomylevel} = "phylum" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($3 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi
if [ ${taxonomylevel} = "class" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($4 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi
if [ ${taxonomylevel} = "order" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($5 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi
if [ ${taxonomylevel} = "family" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($6 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi
if [ ${taxonomylevel} = "genus" ];then
cat ${taxonomy} | sed '1d' | awk -F','  '{ if ($7 == "NA" || $2 != "Bacteria" && $2 != "Archaea") { print } }' | cut -d',' -f1 > ${filterlist}
fi

#Remove unwanted ASVs from ASV count table
if [ -s ${filterlist} ];then
    grep -w -f ${filterlist} -v $counts > ${countsfilt}
else
    cat $counts > ${countsfilt}
fi

#Remove unwanted ASVs from taxonomy table
if [ -s ${filterlist} ];then
  grep -w -f ${filterlist} -v $taxonomy > ${taxonomyfilt}
else
  cat $taxonomy > ${taxonomyfilt}
fi

#Extract unwanted ASVs to new fasta file and remove unwanted ASVs from original fasta file
if [ -s ${filterlist} ];then
  grep -w -f ${filterlist} -A1 ${asvs} | sed '/^--$/d' > ${filterfasta}
  grep -w -f ${filterfasta} -v ${asvs} > ${asvsfilt}
else
  touch ${filterfasta}
  cat ${asvs} > ${asvsfilt}
fi
