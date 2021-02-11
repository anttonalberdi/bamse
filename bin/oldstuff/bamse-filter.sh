#!/bin/bash

#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-f read1.fq] [-r read2.fq] [-a read1.filt.fq] [-b read2.filt.fq] [-q quality] [-l ampliconlength] [-t threads] [-o logfile]" 1>&2; exit 1; }

while getopts ":f:r:a:b:q:l:t:o:" x; do
    case "${x}" in

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
        o)
            o=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${a}" ] || [ -z "${b}" ] || [ -z "${q}" ] || [ -z "${l}" ] || [ -z "${t}" ] || [ -z "${o}" ]; then
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
logfile=$o

#####
# Define quality threshold
#####
#Phred and maq values are different, because BBDuk calculates average
#quality score by converting to probability scale, taking an average,
#and then converting back to Phred scale. So for example, a 2bp read
#with quality scores 10 and 20 would yield an average quality of
#(0.9+0.99)/2=0.945 -> Q12.6 rather than Q15 with a linear average.

#If all nucleotides have the same quality score, then average Phred and
#Maq are identical, but if there are differneces across positions, Maq
#value decreases.

#E=sum(10^(-Q/10))
#E < expected errors
#Q < phred score of each Site
#E < the summatory of all nucleotides

#Filter quality
if [ "$qual" = "loose" ]; then
  #maq=11 approximately filters out reads with average phred=15
  #10^(-11/10)*250 > For a 250nt read, this equals 20 expected errors.
  maq=11
  phred=15
fi
if [ "$qual" = "default" ]; then
  #maq=16 approximately filters out reads with average phred=20
  #10^(-16/10)*250 > For a 250nt read, this equals 6.3 expected errors.
  maq=16
  phred=20
fi
if [ "$qual" = "strict" ]; then
  #maq=18 approximately filters out reads with average phred=25
  #10^(-18/10)*250 > For a 250nt read, this equals 3.96 expected errors.
  maq=18
  phred=25
fi
if [ "$qual" = "superstrict" ]; then
  #maq=21 approximately filters out reads with average phred=30
  #10^(-21/10)*250 > For a 250nt read, this equals 1.98 expected errors.
  maq=21
  phred=30
fi

#####
# Identify phred score and transform if necessary
#####

reformat.sh in=${read1} in2=${read2} out=${read1}.tmp1 out2=${read2}.tmp1 qin=auto qout=33 2> /dev/null

#####
# Trim low-quality 3' ends
#####

readlength=$(readlength.sh in=${read1} in2=${read2} | grep "Max:" | cut -f2)
minreadlength=$(($length - $readlength))
AdapterRemoval --file1 ${read1}.tmp1 --file2 ${read2}.tmp1 --threads ${threads} --qualitybase-output 33 --qualitymax 62 --mate-separator '/' --output1 ${read1}.tmp2 --output2 ${read2}.tmp2 --discarded /dev/null --singleton /dev/null --settings /dev/null --trimqualities --trimwindows 5 --minquality ${phred} --preserve5p --trimns --minlength ${minreadlength} > /dev/null

#####
# Filter low-quality reads
#####

bbduk.sh in=${read1}.tmp2 in2=${read2}.tmp2 out=${filt1} out2=${filt2} maq=$maq qin=33 qout=33 > /dev/null

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
