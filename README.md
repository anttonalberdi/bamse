# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline


### Installation
BAMSE does not require an installation, as it can be directly ran from the repository cloned from github.

1- Go to the directory you want to "install"

```shell
cd /home/user/softwaredir
```

2- Clone the github repository. In Computerome2, load the git module before downloading the repositoru

```shell
modue load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```

3- Remember the bamse path for using it in the future. In this example:
```shell
/home/user/softwaredir/bamse
```

4- To download the latest version, remove the old directory and download it again.

```shell
cd /home/user/softwaredir
rm -r bamse
modue load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```

### Running
For running the core workflow of bamse, use the following code:

```shell
#Declare the bamse directory
bamsedir=/home/user/softwaredir/bamse
#Run the launching script
python ${bamsedir}/bamse.py -f inputdata.txt -d /workdir/ -x /db/taxonomy.db -t 40
```

If working in Computerome2, insert that code in a shell file, and submit a job using qsub.

```shell
echo "python ${bamsedir}/bamse.py -f inputdata.txt -d /workdir/ -x /db/taxonomy.db -t 40" > bamsejob.sh

workdir=/home/user/projectdir/
bamsedir=/home/user/softwaredir/bamse

qsub -V -A ku-cbd -W group_list=ku-cbd -v "workdir=${workdir},bamsedir=${bamsedir}"  -d `pwd` -e ${workdir}/BAMSE.err -o ${workdir}/BAMSE.out -l nodes=1:ppn=40,mem=180gb,walltime=1:00:00:00 -N BAMSE ${workdir}/bamsejob.sh
```
