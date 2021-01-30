#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-f read1.fq] [-r read2.fq] [-a read1.filt.fq] [-b read2.filt.fq] [-q quality] [-l ampliconlength] [-t threads]" 1>&2; exit 1; }

while getopts ":f:r:a:b:q:l:t:" o; do
    case "${o}" in

        f)
            f=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
        a)
            a=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
        q)
            q=${OPTARG}
            ;;
        l)
            l=${OPTARG}
            ;;
        t)
            t=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${a}" ] || [ -z "${b}" ] || [ -z "${q}" ] || [ -z "${l}" ] || [ -z "${t}" ]; then
    usage
fi

sample=$s
read1=$f
read2=$r
filt1=$a
filt2=$b
qual=$q
length=$l
threads=$t

#####
# Define quality threshold
#####

#Filter quality
if [ "$qual" = "loose" ]; then
  maq=16 #maq=16 is equal to phred=20
  phred=20
fi
if [ "$qual" = "default" ]; then
  maq=18 #maq=18 is equal to phred=25
  phred=25
fi
if [ "$qual" = "strict" ]; then
  maq=21 #maq=21 is equal to phred=30
  phred=30
fi

#####
# Identify phred score and transform if necessary
#####

reformat.sh in=${read1} in2=${read2} out=${read1}.tmp1 out2=${read2}.tmp1 qin=auto qout=33

#####
# Trim low-quality 3' ends
#####

minreadlength=$(($length / 2 - 20))
AdapterRemoval --file1 ${read1}.tmp1 --file2 ${read2}.tmp1 --threads ${threads} --qualitybase-output 33 --qualitymax 62 --mate-separator '/' --output1 ${read1}.tmp2 --output2 ${read2}.tmp2 --trimqualities --trimwindows 5 --minquality ${phred} --preserve5p --trimns --minlength ${minreadlength}

#####
# Filter low-quality reads
#####

bbduk.sh in=${read1}.tmp2 in2=${read2}.tmp2 out=${filt1} out2=${filt2} maq=$maq qin=33 qout=33

#####
# Remove temporary files
#####

rm ${read1}.tmp1
rm ${read1}.tmp2
rm ${read2}.tmp1
rm ${read2}.tmp2

#####
# Output read number per sample to stats file
#####

readnumber=$(cat ${filt1} | wc -l)
readnumber2=$(( $readnumber / 4 ))
statpath=$(echo ${filt1} | sed 's/2-Filtered.*/0-Stats/')
statsfile=$(echo ${filt1} | sed 's/.*2-Filtered\///' | sed 's/.*\///' | sed 's/_1.fastq/\.txt/')
stats=$(echo "${statpath}/${statsfile}")
echo 'Quality filtered\t'$readnumber2 >> ${stats}
