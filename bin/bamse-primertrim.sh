#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-a read1.fastq] [-b read2.fastq] [-c read1.trimmed.fastq] [-d read2.trimmed.fastq] [-f primer1] [-r primer2]" 1>&2; exit 1; }

while getopts ":a:b:c:d:f:r:" o; do
    case "${o}" in

        a)
            a=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
        c)
            c=${OPTARG}
            ;;
        d)
            d=${OPTARG}
            ;;
				f)
		        f=${OPTARG}
		        ;;
		    r)
		        r=${OPTARG}
		        ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${a}" ] || [ -z "${b}" ] || [ -z "${c}" ] || [ -z "${d}" ] || [ -z "${f}" ] || [ -z "${r}" ]; then
    usage
fi

read1=$a
read2=$b
filt1=$c
filt2=$d
primer1=$f
primer2=$r

#####
# Trim primers
#####

cutadapt --pair-adapters -e 0.2 -g ^${primer1} -G ^${primer2} --discard-untrimmed -o ${filt1}_a -p ${filt2}_a ${read1} ${read2}
cutadapt --pair-adapters -e 0.2 -g ^${primer2} -G ^${primer1} --discard-untrimmed -o ${filt1}_b -p ${filt2}_b ${read1} ${read2}

#####
# Output initial read number per sample to stats file
#####

initialreadnumber=$(cat ${read1} | wc -l)
initialreadnumber2=$(( $initialreadnumber / 4 ))
statpath=$(echo ${read1} | sed 's/0-Data.*/0-Stats/')
statsfile=$(echo ${read1} | sed 's/.*0-Data\///' | sed 's/.*\///' | sed 's/_1.fastq/\.txt/')
stats=$(echo "${statpath}/${statsfile}")
echo "Initial reads\t${initialreadnumber2}" > ${stats}

#####
# Check library type
#####

initial10=$(($initialreadnumber / 10))
dir5to3=$(cat ${filt1}_a | wc -l)
dir3to5=$(cat ${filt1}_b | wc -l)

if [ "$dir3to5" -gt "$initial10" ]; then
#It is ligation-based library; so dir3to5 reads need to be flipped (change read number in reversed)
  cat ${filt1}_a ${filt2}_b | sed 's/2:N:0:/1:N:0:/g'> ${filt1}
  cat ${filt2}_a ${filt1}_b | sed 's/1:N:0:/2:N:0:/g' > ${filt2}
else
#It is PCR-based library, so all reads are at the same direction
  mv ${filt1}_a ${filt1}
  mv ${filt2}_a ${filt2}
fi

#Remove temporary files
rm ${filt1}_a ${filt1}_b ${filt2}_a ${filt2}_b

#####
# Output read number per sample to stats file
#####

readnumber=$(cat ${filt1} | wc -l)
readnumber2=$(( $readnumber / 4 ))
echo 'Primers trimmed reads\t'$readnumber2 >> ${stats}
