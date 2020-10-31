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



${bamsedir}/bin/bamse-qualprof.sh -s GM4.E27 -f GM4.E27_1.fastq -r GM4.E27_2.fastq -l 440 -q 30 -c sample.yaml -p bamse.yaml
