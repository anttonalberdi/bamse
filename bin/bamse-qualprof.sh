#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-s <samplename>] [-f read1.fq] [-r read2.fq] [-l <int>] [-q <int>] [-c sample.yaml] [-p bamse.yaml]" 1>&2; exit 1; }

while getopts ":s:f:r:l:q:c:p:" o; do
    case "${o}" in
        s)
            s=${OPTARG}
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

if [ -z "${s}" ] || [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${l}" ] || [ -z "${q}" ] || [ -z "${c}" ] || [ -z "${p}" ]; then
    usage
fi

sample=$s
read1=$f
read2=$r
ampliconlength=$l
minQ=$q
sampleparam=$c
param=$p

#####
# Obtain quality profiles
#####

cat $read1 | seqtk sample - 1000 | perl -MStatistics::Descriptive -lne 'push @a, $_; @a = @a[@a-4..$#a]; if ($. % 4 == 0){
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
		> ${sampleparam}.qual1

cat $read2 | seqtk sample - 1000 | perl -MStatistics::Descriptive -lne 'push @a, $_; @a = @a[@a-4..$#a]; if ($. % 4 == 0){
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
		> ${sampleparam}.qual2

		#####
		# Identify trimming length and min phred score
		#####

qualoverlap=0
while [[ "$qualoverlap" -le 5 ]] && [[ "$minQ" -ge 10 ]];do
    echo "$minQ"

  	trimm1=$(cat ${sampleparam}.qual1 | awk -F"\t" -v q=$minQ '$2<=q' | cut -f1 | sort | head -n1)
  	if [ -z "$trimm1" ];then
  	 trimm1=$(cat ${sampleparam}.qual1 | wc -l)
  	fi

  	trimm2=$(cat ${sampleparam}.qual2 | awk -F"\t" -v q=$minQ '$2<=q' | cut -f1 | sort | head -n1)
  	if [ -z "$trimm2" ];then
  	 trimm2=$(cat ${sampleparam}.qual2 | wc -l)
  	fi

  	qualoverlap=$(($trimm1 + $trimm2 - $ampliconlength))
    minQ=$((minQ - 1))
done

#####
# Print to sample-specific params file
#####

echo -e "truncF\t$trimm1" > ${sampleparam}
echo -e "truncR\t$trimm2" >> ${sampleparam}
echo -e "minQ\t$minQ" >> ${sampleparam}
