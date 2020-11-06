#tests

rm -rf bamse
git clone https://anttonalberdi:Ss7679Bd@github.com/anttonalberdi/bamse.git


#Transfer
python bamse/bamse.py -i bamse3/inputfile.txt -d /home/projects/ku-cbd/people/antalb/bamse3/ -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/ku-cbd/people/antalb/databases/silva_nr_v132_train_set.fa.gz -t 1

#Computerome Job


# Run BAMSE
workdir=/home/projects/ku-cbd/people/antalb/bamse3
bamsedir=/home/projects/ku-cbd/people/antalb/bamse
cd $workdir

module load tools anaconda3/4.4.0 perl/5.30.2 intel/perflibs gcc/9.3.0 R/4.0.0
qsub -V -A ku-cbd -W group_list=ku-cbd -v "workdir=${workdir},bamsedir=${bamsedir}"  -d `pwd` -e ${workdir}/BAMSE.err -o ${workdir}/BAMSE.out -l nodes=1:ppn=40,mem=180gb,walltime=0:06:00:00 -N BAMSE ${workdir}/bamse.sh

#bamse.sh
python ${bamsedir}/bamse.py -i ${workdir}/inputfile.txt -d ${workdir} -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/ku-cbd/people/antalb/databases/silva_nr_v132_train_set.fa.gz -t 40



GM10.B09,GM10.B09,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM10.B09.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM10.B09.2.fq.gz
GM10.B09,GM10.B09,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM10.B09.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM10.B09.2.fq.gz
GM11.E44,GM11.E44,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM11.E44.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM11.E44.2.fq.gz
GM12.B27,GM12.B27,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM12.B27.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM12.B27.2.fq.gz
GM1.E31,GM1.E31,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM1.E31.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM1.E31.2.fq.gz
GM2.E18,GM2.E18,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM2.E18.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM2.E18.2.fq.gz
GM3.H26,GM3.H26,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM3.H26.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM3.H26.2.fq.gz
GM4.E27,GM4.E27,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM4.E27.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM4.E27.2.fq.gz
GM4.P53,GM4.P53,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM4.P53.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM4.P53.2.fq.gz
GM5.H22,GM5.H22,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM5.H22.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM5.H22.2.fq.gz
GM5.P60,GM5.P60,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM5.P60.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM5.P60.2.fq.gz
GM7.P73,GM7.P73,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM7.P73.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM7.P73.2.fq.gz
GM8.H10,GM8.H10,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM8.H10.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM8.H10.2.fq.gz
GM9.H39_r3,GM9.H39_r3,Run1,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM9.H39_r3.1.fq.gz,/home/projects/ku-cbd/people/antalb/Israel_bat_microbiome/1-QualityFiltered_DADA2/GM9.H39_r3.2.fq.gz



sh /Users/anttonalberdi/github/bamse/bin/bamse-qualprof.sh -i bamse-test/1-Trimmed/GM1.E31_1.fastq -s bamse-test/1-Trimmed/GM1.E31_1.stats
sh /Users/anttonalberdi/github/bamse/bin/bamse-qualprof.sh -i bamse-test/1-Trimmed/GM1.E31_2.fastq -s bamse-test/1-Trimmed/GM1.E31_2.stats


python /Users/anttonalberdi/github/bamse/bamse.py -i bamse-test/inputdata.txt -d bamse-test -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x bamse-test/silva_nr_v132_train_set.fa.gz -t 4

########
# Overlaps
#########

#Test overlap (PEAR)
pear -f bamse-test/1-Trimmed/GM1.E31_1.fastq -r bamse-test/1-Trimmed/GM1.E31_2.fastq -o bamse-test/1-Trimmed/GM1.E31_merged.fastq
#Extract headers
grep "^@" bamse-test/1-Trimmed/GM1.E31_merged.fastq.assembled.fastq | cut -d ' ' -f 1 > bamse-test/1-Trimmed/GM1.E31_merged.txt
#Filter reads (BBmap)
filterbyname.sh in=bamse-test/1-Trimmed/GM1.E31_1.fastq in2=bamse-test/1-Trimmed/GM1.E31_2.fastq out=bamse-test/1-Trimmed/GM1.E31_1.subset.fastq out2=bamse-test/1-Trimmed/GM1.E31_2.subset.fastq names=bamse-test/1-Trimmed/GM1.E31_merged.txt include=t substring=t overwrite=t
#Trim reads

head -n4 bamse-test/1-Trimmed/GM1.E31_merged.fastq.assembled.fastq
head -n4 bamse-test/1-Trimmed/GM1.E31_1.subset.fastq
head -n4 bamse-test/1-Trimmed/GM1.E31_2.subset.fastq



seqtk subseq  bamse-test/1-Trimmed/GM1.E31_1.fastq bamse-test/1-Trimmed/GM1.E31_merged.txt  > bamse-test/1-Trimmed/GM1.E31_1.subset.fastq

fastqc --nogroup --extract /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1.fastq
#Per-base quality
perbabasequal=$(sed -n '/^#Base/,$p' /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1_fastqc/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1,2)
#Per-base quality (applying sliding window)
perbabasequalslide=$(echo $perbabasequal | cut -d$'\t' -f2 | awk -v OFS="\t" 'BEGIN{window=5;slide=1} {mod=NR%window; if(NR<=window){count++}else{sum-=array[mod]}sum+=$1;array[mod]=$1;} (NR%slide)==0{print sum/count}')
#Total reads
totalreads=$(grep "Total Sequences" /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1_fastqc/fastqc_data.txt | cut -d$'\t' -f2)
#Per-base reads
perbabasereads=$(sed -n '/^#Length/,$p' /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1_fastqc/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1,2 | awk '{ for (i=1; i<=NF; ++i) {sum[i]+=$i; $i=sum[i] }; print $2}' | awk -v s=${totalreads} '{print s-$0}' | sed '$d')
#Filling rows
startline=$(sed -n '/^#Length/,$p' /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1_fastqc/fastqc_data.txt | sed -n '/>>END_MODULE/q;p' | tail -n +2 | cut -d$'\t' -f1 | head -n1)
startreads=$(echo $perbabasereads | head -n1)
fillingrows=$(printf "${startreads}\n%.0s" {1..$startline})
allrows=$(echo $fillingrows && echo $perbabasereads)
allrowsperc=$(echo $allrows | awk -v s=${totalreads} '{print $0*100/s}')


#Print to file
paste <(echo $perbabasequal) <(echo $perbabasequalslide) <(echo $allrows) <(echo $allrowsperc) > /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31.param.qual1

#Remove directory
rm -rf /Users/anttonalberdi/bamse-test/1-Trimmed/GM1.E31_1_fastqc/




sh /Users/anttonalberdi/github/bamse/bin/bamse-overlapfilter.sh -f bamse-test/1-Trimmed/GM1.E31_1.fastq -r bamse-test/1-Trimmed/GM1.E31_2.fastq -a bamse-test/2-Filtered/GM1.E31_1.fastq -b bamse-test/2-Filtered/GM1.E31_2.fastq -h bamse-test/2-Filtered/GM1.E31_1.trimlengths -j bamse-test/2-Filtered/GM1.E31_2.trimlengths
python /Users/anttonalberdi/github/bamse/bin/bamse-qualitytrim.py -i bamse-test/2-Filtered/GM1.E31_1.fastq -l bamse-test/2-Filtered/GM1.E31_1.trimlengths -o bamse-test/3-Trimmed/GM1.E31_1.fastq



cd /opt/anaconda3/envs/bamse-env/lib
git clone https://github.com/anttonalberdi/bamse.git
cd bamse
#Make it executable
chmod +x bamse
#Add to path
BAMSE_ROOT=`pwd -P`
echo -e "export PATH=${BAMSE_ROOT}:\${PATH}" >> ${HOME}/.bashrc
export PATH=${BAMSE_ROOT}:${PATH}
