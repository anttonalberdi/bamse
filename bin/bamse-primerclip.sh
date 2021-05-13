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
filt1rev=$(echo $c | sed 's/_1.fastq/_1.rev.fastq/g')
filt2rev=$(echo $d | sed 's/_2.fastq/_2.rev.fastq/g')
primer1=$f
primer2=$r

echo $filt1rev

#####
# Trim primers
#####

cutadapt --pair-adapters -e 0.2 -g ^${primer1} -G ^${primer2} --discard-untrimmed -o ${filt1}_a -p ${filt2}_a ${read1} ${read2} 2>> /dev/null
cutadapt --pair-adapters -e 0.2 -g ^${primer2} -G ^${primer1} --discard-untrimmed -o ${filt1}_b -p ${filt2}_b ${read1} ${read2} 2>> /dev/null

#####
# Check library type
#####

initialreadnumber=$(cat ${read1} | wc -l)
initialreadnumber2=$(( $initialreadnumber / 4 ))
initial10=$(($initialreadnumber / 10))
dir5to3=$(cat ${filt1}_a | wc -l)
dir3to5=$(cat ${filt1}_b | wc -l)

if [ "$dir3to5" -gt "$initial10" ]; then
#It is ligation-based library; so dir3to5 reads need to be flipped (change read number in reversed)

  cat ${filt1}_a > ${filt1}
  cat ${filt2}_a > ${filt2}

  cat ${filt2}_b | sed 's/2:N:0:/1:N:0:/g' > ${filt1rev}
  cat ${filt1}_b | sed 's/1:N:0:/2:N:0:/g'> ${filt2rev}

else
#It is PCR-based library, so all reads are at the same direction
  cat ${filt1}_a > ${filt1}
  cat ${filt2}_a > ${filt2}
fi

#Remove temporary files
rm ${filt1}_a ${filt1}_b ${filt2}_a ${filt2}_b

#####
# Output read number per sample to stats file
#####


statpath=$(echo ${read1} | sed 's/0-Data.*/0-Stats/')
statsfile=$(echo ${read1} | sed 's/.*0-Data\///' | sed 's/.*\///' | sed 's/_1.fastq/\.txt/')
stats=$(echo "${statpath}/${statsfile}")
if test -f "${filt1rev}"; then
  readnumber=$(cat ${filt1} ${filt1rev} | wc -l)
else
  readnumber=$(cat ${filt1} | wc -l)
fi
readnumber2=$(( $readnumber / 4 ))
if [ "$readnumber2" -gt 0 ];then
echo 'Primer-trimmed reads:\t'$readnumber2 >> ${stats}
fi
