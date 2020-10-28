#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-s <samplename>] [-w <workdir>] [-f read1.fq] [-r read2.fq] [-l <int>] [-q <int>] [-c sample.yaml] [-p bamse.yaml]" 1>&2; exit 1; }

while getopts ":s:w:f:r:l:q:c:p:" o; do
    case "${o}" in
        s)
            s=${OPTARG}
            ;;
        w)
            w=${OPTARG}
            ;;
        f)
            f=${OPTARG}
            ;;
        r)
            r=${OPTARG}
            ;;
				l)
		        l=${OPTARG}
		        ;;
		    q)
		        q=${OPTARG}
		        ;;
				c)
						c=${OPTARG}
						;;
        p)
            p=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${w}" ] || [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${l}" ] || [ -z "${q}" ] || [ -z "${c}" || [ -z "${p}" ]; then
    usage
fi

sample=$s
workdir=$w
read1=$f
read2=$r
ampliconlength=$l
minQ=$q
sampleparam=$c
param=$p

#####
# Obtain amplicon lengths and overlaps
#####

#Get average lengths of reads
readlength1=$(cat $read1 | awk '{if(NR%4==2) {count++; bases += length} } END{print int(bases/count)}')
readlength2=$(cat $read2 | awk '{if(NR%4==2) {count++; bases += length} } END{print int(bases/count)}')

#Get average overlap
overlap=$(($readlength1 + $readlength2 - $ampliconlength))

#####
# Obtain quality profiles
#####

cat $read1 | perl -MStatistics::Descriptive -lne 'push @a, $_; @a = @a[@a-4..$#a]; if ($. % 4 == 0){
		chomp($a[3]);
		$max_j=0;
		$j=0;
		++$i;
		map{$r{$i.":".++$j}=(ord($_)-33)}split("",$a[3]);
		if($j>$max_j){
			$max_j=$j;}}
		}{
		for($jj=1;$jj<=$max_j;$jj++){
			@m=();
			for($ii=1;$ii<=$i;$ii++){
				unless(not defined $r{$ii.":".$jj})
					{push @m,$r{$ii.":".$jj}}}
		$s=Statistics::Descriptive::Full->new();
		$s->add_data(@m);
		print($jj."\t".$s->mean()."\t".$s->standard_deviation())}' | \
		# Apply sliding window to soften quality values
		awk -v OFS="\t" 'BEGIN{window=5;slide=1} {mod=NR%window; if(NR<=window){count++}else{sum-=array[mod];sum2-=array2[mod]}sum+=$2;sum2+=$3;array[mod]=$2;array2[mod]=$3;} (NR%slide)==0{print NR,sum/count,sum2/count}' \
		> test1.txt

cat $read2 | perl -MStatistics::Descriptive -lne 'push @a, $_; @a = @a[@a-4..$#a]; if ($. % 4 == 0){
		chomp($a[3]);
		$max_j=0;
		$j=0;
		++$i;
		map{$r{$i.":".++$j}=(ord($_)-33)}split("",$a[3]);
		if($j>$max_j){
			$max_j=$j;}}
		}{
		for($jj=1;$jj<=$max_j;$jj++){
			@m=();
			for($ii=1;$ii<=$i;$ii++){
				unless(not defined $r{$ii.":".$jj})
					{push @m,$r{$ii.":".$jj}}}
		$s=Statistics::Descriptive::Full->new();
		$s->add_data(@m);
		print($jj."\t".$s->mean()."\t".$s->standard_deviation())}' | \
		# Apply sliding window to soften quality values
		awk -v OFS="\t" 'BEGIN{window=5;slide=1} {mod=NR%window; if(NR<=window){count++}else{sum-=array[mod];sum2-=array2[mod]}sum+=$2;sum2+=$3;array[mod]=$2;array2[mod]=$3;} (NR%slide)==0{print NR,sum/count,sum2/count}' \
		> test2.txt

		#####
		# Identify trimming length and min phred score
		#####

qualoverlap=0
while [[ "$qualoverlap" -le 5 ]];do

	minQ=$((minQ - 1))

	trimm1=$(cat test1.txt | awk -F"\t" -v q=$minQ '$2<=q' | cut -f1 | sort | head -n1)
	if [ -z "$trimm1" ];then
	 trimm1=$readlength1
	fi

	trimm2=$(cat test2.txt | awk -F"\t" -v q=$minQ '$2<=q' | cut -f1 | sort | head -n1)
	if [ -z "$trimm2" ];then
	 trimm2=$readlength2
	fi

	qualoverlap=$(($trimm1 + $trimm2 - $ampliconlength))
done

#####
# Print to sample-specific params file
#####

echo -e "#Sample-specific parameters\n" >> ${sampleparam}
echo -e "truncF_$sample:\n $trimm1\n" >> ${sampleparam}
echo -e "truncR_$sample:\n $trimm2\n" >> ${sampleparam}
cat ${sampleparam} >> $param
