#tests

#Transfer

python bamse/bamse.py -f bamse/workflows/inputfile.txt -d /home/projects/ku-cbd/people/antalb/bamse2/ -x sdf -t 1


#Trimming

python bamse/bin/bamse-trimming.py -i1 /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile1_1.fastq -i2 /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile1_2.fastq -o1 /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile1_1.fastq -o2 /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile1_2.fastq -p1 CTANGGGNNGCANCAG -p2 GACTACNNGGGTATCTAAT

python bamse/bin/bamse-trimming.py -i1 /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile2_1.fastq -i2 /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile2_2.fastq -o1 /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile2_1.fastq -o2 /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile2_2.fastq -p1 CTANGGGNNGCANCAG -p2 GACTACNNGGGTATCTAAT


-e 0.15 -g ^GACTACNNGGGTATCTAAT -G ^CTANGGGNNGCANCAG --trimmed-only -o /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile2_1.fastq_b -p /home/projects/ku-cbd/people/antalb/bamse2/1-Trimmed/Datafile2_2.fastq_b /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile2_1.fastq /home/projects/ku-cbd/people/antalb/bamse2/0-Data/Datafile2_1.fastq
