# Benchmarking SequelTools


We used Maize line NC358 data to benchmark all tools of `SequelTools`. Specifically, eight SMRTcells of PacBio Reads were used (both scraps and subreads).

```
m54138_180610_050652.scraps.bam		 m54138_180610_050652.subreads.bam
m54138_180610_152029.scraps.bam		 m54138_180610_152029.subreads.bam
m54138_180619_053104.scraps.bam		 m54138_180619_053104.subreads.bam
m54138_180620_123320.scraps.bam		 m54138_180620_123320.subreads.bam
m54138_180620_225343.scraps.bam		 m54138_180620_225343.subreads.bam
m54138_180621_091000.scraps.bam		 m54138_180621_091000.subreads.bam
m54138_180627_120814.scraps.bam		 m54138_180627_120814.subreads.bam
m54138_180627_222429.scraps.bam		 m54138_180627_222429.subreads.bam
```




## 1. Benchmarking QC tool

### A. With subreads only

A file of file names (fofn) was generated for subreads (one per line) labelled `subreads.txt`. A run script (bash) was used to test QC tool on various number of processors (`runSequelT-QC-sub.sh`).

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$2
echo "subread"
time ./SequelTools.sh -u subreads.txt -t Q -p a -g a -n ${cpu} -o runSequelT-QC-sub_${cpu}_8-SMRTcells
```

For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-QC-sub.sh $i
done
```

### B. With scraps only

A file of file names (fofn) was generated for subreads (one per line) labelled `scraps.txt`. A run script (bash) was used to test QC tool on various number of processors (`runSequelT-QC-scr.sh`).

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$2
echo "subread"
time ./SequelTools.sh -c scraps.txt -t Q -p a -g a -n ${cpu} -o runSequelT-QC-scr_${cpu}_8-SMRTcells
```

For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-QC-scr.sh $i
done
```


## 2. Benchmarking QC tool
