#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-f read1.fq] [-r read2.fq] [-a read1.filt.fq] [-b read2.filt.fq] [-1 read1.trimlengths] [-2 read2.trimlengths]" 1>&2; exit 1; }

while getopts ":f:r:a:b:h:j:" o; do
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
				h)
		        h=${OPTARG}
		        ;;
		    j)
		        j=${OPTARG}
		        ;;

        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${a}" ] || [ -z "${b}" ] || [ -z "${h}" ] || [ -z "${j}" ]; then
    usage
fi

sample=$s
read1=$f
read2=$r
filt1=$a
filt2=$b
trimlength1=$h
trimlength2=$j

#Enable posix interface
set +o posix

#####
# Obtain quality profiles
#####

base=$(echo ${read1} | sed 's/_1.fastq//')
#Test overlap (PEAR)
pear -v 5 -n 400 -f ${read1} -r ${read2} -o ${base}

#Extract headers
grep "^@" ${base}.assembled.fastq | cut -d ' ' -f 1 > ${base}.assembled.txt

#Filter reads (BBmap)
filterbyname.sh in=${read1} in2=${read2} out=${filt1} out2=${filt2} names=${base}.assembled.txt include=t substring=t overwrite=t

#Trim reads
cat ${base}.assembled.fastq | awk '{if(NR%4==2) print length($1)}' > ${base}_lm
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
