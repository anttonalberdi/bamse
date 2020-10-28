#tests

rm -rf bamse
git clone https://anttonalberdi:Ss7679Bd@github.com/anttonalberdi/bamse.git


#Transfer

python bamse/bamse.py -i bamse/inputfile.txt -d /home/projects/ku-cbd/people/antalb/bamse3/ -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/ku-cbd/people/antalb/databases/silva_nr_v132_train_set.fa.gz -t 1

#Computerome Job


# PREPARE reference genome
workdir=/home/projects/ku-cbd/people/antalb/bamse3
bamsedir=/home/projects/ku-cbd/people/antalb/bamse
qsub -V -A ku-cbd -W group_list=ku-cbd -v "workdir=${workdir},bamsedir=${bamsedir}"  -d `pwd` -e ${workdir}/BAMSE.err -o ${workdir}/BAMSE.out -l nodes=1:ppn=40,mem=180gb,walltime=0:06:00:00 -N BAMSE ${workdir}/bamse.sh

#bamse.sh
python bamse/bamse.py -i ${workdir}/inputfile.txt -d ${workdir} -f CTANGGGNNGCANCAG -r GACTACNNGGGTATCTAAT -a 440 -x /home/projects/ku-cbd/people/antalb/databases/silva_nr_v132_train_set.fa.gz -t 1
