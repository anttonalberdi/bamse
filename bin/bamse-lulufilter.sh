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

input=$i
lulutable=$l
output=$o

#Enable posix interface
set +o posix

#####
# Filter fasta file
#####

grep -A1 -f <(cut -d',' -f1 $lulutable) ${input} > ${output}
