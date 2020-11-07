#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-i ASVs.fastq] [-l ASV_counts_lulu.txt] [-o ASVs_lulu.fastq]" 1>&2; exit 1; }

while getopts ":f:r:a:b:h:j:n:m:q:" o; do
    case "${o}" in

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

sample=$s
read1=$f
read2=$r
filt1=$a
filt2=$b
trimlength1=$h
trimlength2=$j
minlength=$n
maxlength=$m
qual=$q

#Enable posix interface
set +o posix

#####
# Obtain quality profiles
#####

base=$(echo ${read1} | sed 's/_1.fastq//')
#Test overlap (PEAR)
pear -v 5 -n ${minlength} -m ${maxlength} -f ${read1} -r ${read2} -o ${base}

#Filter quality
if [ "$qual" == "loose" ]; then
  maq=16 #maq=16 is equal to phred=20
fi
if [ "$qual" == "default" ]; then
  maq=18 #maq=18 is equal to phred=25
fi
if [ "$qual" == "strict" ]; then
  maq=21 #maq=21 is equal to phred=30
fi

bbduk.sh in=${base}.assembled.fastq out=${base}.assembled2.fastq maq=$maq

#Extract headers
grep "^@" ${base}.assembled2.fastq | cut -d ' ' -f 1 > ${base}.assembled.txt

#Filter reads (BBmap)
filterbyname.sh in=${read1} in2=${read2} out=${filt1} out2=${filt2} names=${base}.assembled.txt include=t substring=t overwrite=t

#Trim reads
cat ${base}.assembled2.fastq | awk '{if(NR%4==2) print length($1)}' > ${base}_lm
cat ${filt1} | awk '{if(NR%4==2) print length($1)}' > ${base}_l1
cat ${filt2} | awk '{if(NR%4==2) print length($1)}' > ${base}_l2
paste ${base}_l1 ${base}_l2 ${base}_lm | awk '{print ($1 + $2 - $3)}' > ${base}_o

#List read1 trimming lengths
paste ${base}_l1 ${base}_l2 ${base}_o | awk '{
if($3 %2 == 0)
  print ($1 - int($3 /2));
else
  print ($1 - int($3 /2))}' > ${trimlength1}

#List read2 trimming lengths
paste ${base}_l1 ${base}_l2 ${base}_o | awk '{
  if($3 %2 == 0)
    print ($2 - int($3 /2));
  else
    print ($2 - (int($3 /2)+1))}' > ${trimlength2}

#Remove temorary files
rm ${base}.assembled*
rm ${base}.unassembled*
rm ${base}.discarded.fastq
rm ${base}_l1
rm ${base}_l2
rm ${base}_lm
rm ${base}_o
