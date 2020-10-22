# BAMSE

**B**acterial **AM**plicon **Se**quencing processing pipeline


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

3- Remember the bamse path. In this example:
```
/home/user/softwaredir/bamse
```

### Running

```
python bamse.py -f inputdata.txt -d /workdir/ -x /db/taxonomy.db -t 40
```
