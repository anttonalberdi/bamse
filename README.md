# BAMSE

**B**acterial **AM**plicon **Se**quencing data processing pipeline


### Installation
BAMSE does not require an installation, as it can be directly ran from the repository cloned from github.

1- Go to the directory you want to "install"

```
cd /home/user/softwaredir
```

2- Clone the github repository. In Computerome2, load the git module before downloading the repositoru

```
modue load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```

3- Remember the bamse path for using it in the future. In this example:
```
/home/user/softwaredir/bamse
```

4- To download the latest version, remove the old directory and download it again.

```
cd /home/user/softwaredir
rm -r bamse
modue load git/2.4.4
git clone https://github.com/anttonalberdi/bamse.git
```

### Running

```
python bamse.py -f inputdata.txt -d /workdir/ -x /db/taxonomy.db -t 40
```
