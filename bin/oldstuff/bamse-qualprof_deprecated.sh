#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-i reads.fastq] [-s read.stats]" 1>&2; exit 1; }

while getopts ":i:s:" o; do
    case "${o}" in
        i)
            i=${OPTARG}
            ;;
        s)
            s=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${s}" ]; then
    usage
fi

input=$i
output=$s

#Enable posix interface
set +o posix

#####
# Obtain quality profiles
#####

fastqcdir=$(echo ${input} | sed 's|\(.*\)/.*|\1|')
fastqcfolder=$(echo ${input} | sed 's|.*/||' | sed 's|\.fastq|_fastqc|')
fastqc --nogroup --extract -o ${fastqcdir} ${input}

#Per-base quality
sed -n '/^#Base/,$p' ${fastqcdir}/${fastqcfolder}/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1,2 > ${output}_1
#Per-base quality (applying sliding window)
cat ${output}_1 | cut -d$'\t' -f2 | awk -v OFS="\t" 'BEGIN{window=5;slide=1} {mod=NR%window; if(NR<=window){count++}else{sum-=array[mod]}sum+=$1;array[mod]=$1;} (NR%slide)==0{print sum/count}' > ${output}_2
#Total reads
totalreads=$(grep "Total Sequences" ${fastqcdir}/${fastqcfolder}/fastqc_data.txt | cut -d$'\t' -f2)
#Per-base reads
sed -n '/^#Length/,$p' ${fastqcdir}/${fastqcfolder}/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1,2 | awk '{ for (i=1; i<=NF; ++i) {sum[i]+=$i; $i=sum[i] }; print $2}' | awk -v s=${totalreads} '{print s-$0}' | sed '$d' > ${output}_3
#Filling rows
startline=$(sed -n '/^#Length/,$p' ${fastqcdir}/${fastqcfolder}/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1 | head -n1)
startreads=$(cat ${output}_3 | head -n1)
yes "$totalreads" | head -n ${startline} > ${output}_4

#Merge files
cat ${output}_4 ${output}_3 > ${output}_5
cat ${output}_5 | awk -v s=${totalreads} '{print $0*100/s}' > ${output}_6
paste ${output}_1 ${output}_2 ${output}_5 ${output}_6 > ${output}

#Remove fastqc directory
rm -rf ${fastqcdir}/${fastqcfolder}
rm -f ${fastqcdir}/${fastqcfolder}.html
rm -f ${fastqcdir}/${fastqcfolder}.zip
rm -f ${output}_*
