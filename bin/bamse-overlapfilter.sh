#2020/10/25 - BAMSE 1.0

usage() { echo "Usage: $0 [-f read1.fq] [-r read2.fq] [-a read1.filt.fq] [-b read2.filt.fq] [-1 read1.trimlengths] [-2 read2.trimlengths] [-n 400] [-m 450] [-q 'default']" 1>&2; exit 1; }

while getopts ":f:r:a:b:h:j:n:m:q:" o; do
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
        n)
    		    n=${OPTARG}
    		    ;;
        m)
        		m=${OPTARG}
        		;;
        q)
          	q=${OPTARG}
          	;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${a}" ] || [ -z "${b}" ] || [ -z "${h}" ] || [ -z "${j}" ] || [ -z "${n}" ] || [ -z "${m}" ] || [ -z "${q}" ]; then
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

#####
# Output read number per sample to stats file
#####

readnumber=$(cat ${filt1} | wc -l)
readnumber2=$(( $readnumber / 4 ))
statpath=$(echo ${filt1} | sed 's/2-Filtered.*/0-Stats/')
statsfile=$(echo ${filt1} | sed 's/.*2-Filtered\///' | sed 's/.*\///' | sed 's/_1.fastq/\.txt/')
stats=$(echo "${statpath}/${statsfile}")
echo 'Quality filtered\t'$readnumber2 >> ${stats}
