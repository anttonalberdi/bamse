#2020/10/25 - BAMSE 1.0
#Perl script taken from: http://userweb.eng.gla.ac.uk/umer.ijaz/bioinformatics/QC.html#perbase_quality_FASTQ.sh

usage() { echo "Usage: $0 [-f read1.fq] [-r read2.fq] [-l <int>] [-q <int>] [-c params.yaml]" 1>&2; exit 1; }

while getopts ":f:r:l:q:c:" o; do
    case "${o}" in
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
        *)
            usage
            ;;
    esac
done

shift $((OPTIND-1))

if [ -z "${f}" ] || [ -z "${r}" ] || [ -z "${l}" ] || [ -z "${q}" ] || [ -z "${c}" ]; then
    usage
fi

read1=$f
read2=$r
ampliconlength=$l
minQ=$q
paramfile=$c

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
# Print to params file
#####

cat $paramfile | tr '\n' '*' | sed "s/truncF:\* 0/truncF:\* $trimm1/g"  | tr '*' '\n' > $paramfile
cat $paramfile | tr '\n' '*' | sed "s/truncR:\* 0/truncR:\* $trimm2/g"  | tr '*' '\n' > $paramfile
