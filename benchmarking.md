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
cpu=$1
time ./SequelTools.sh \
    -u subreads.txt \
    -t Q \
    -p a \
    -g a \
    -n ${cpu} \
    -o runSequelT-QC-sub_${cpu}_8-SMRTcells
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
cpu=$1
time ./SequelTools.sh \
    -u subreads.txt \
    -t Q \
    -p a \
    -g a \
    -n ${cpu} \
    -o runSequelT-QC-scr_${cpu}_8-SMRTcells
```

For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-QC-scr.sh $i
done
```


## 2. Benchmarking Filter tool

Filter tool requires both subreads and scraps, so `subreads.txt` and `scraps.txt`, previously created fofn was used to test filtering tool based on (a) Adapters, (b) Passes, and (c) Size. The benchmarking was done similarly as explained above (8 SMRTcells and 4-16 CPUs).

### A. Adapters

The run script was set up as follows (`runSequelT-F_adp.sh`)

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$1
time ./SequelTools.sh \
    -c scraps.txt \
    -u subreads.txt \
    -t F \
    -N \
    -n ${cpu} \
    -o runSequelT-F_adp_${cpu}_8-SMRTcells
rm runSequelT-F_adp_${cpu}_8-SMRTcells/*.sam
```
For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-F_adp.sh $i
done
```

### B. Passes

The run script was set up as follows (`runSequelT-F_pas.sh`)

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$1
time ./SequelTools.sh \
    -c scraps.txt \
    -u subreads.txt \
    -t F \
    -P \
    -n ${cpu} \
    -o runSequelT-F_pas_${cpu}_8-SMRTcells
rm runSequelT-F_pas_${cpu}_8-SMRTcells/*.sam
```
For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-F_pas.sh $i
done
```

### C. Length

Fixed length (1000bp) was used for length filtering. The run script was set up as follows (`runSequelT-F_len.sh`)

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$1
time ./SequelTools.sh \
    -c scraps.txt \
    -u subreads.txt \
    -t F \
    -C \
    -Z 1000
    -n ${cpu} \
    -o runSequelT-F_len_${cpu}_8-SMRTcells
rm runSequelT-F_len_${cpu}_8-SMRTcells/*.sam
```
For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-F_len.sh $i
done
```

## 3. Benchmarking Sub-Sampling tool

For Sub sampling the subreads, we used length based sub-sampling method (select longest subread per CLR). Since it only needs subreads, we used the `subreads.txt` fofn as input. The benchmarking was done similarly as explained above (8 SMRTcells and 4-16 CPUs), using the `runSequelT-S_len.sh` script.

```bash
#!/bin/bash
PATH=$PATH:/ptmp/GIF/arnstrm/sequeltools/SequelTools/Scripts
ml r-devtools samtools python
cpu=$1
time ./SequelTools.sh \
    -u subreads.txt \
    -t S \
    -T l \
    -n ${cpu} \
    -o runSequelT-S_len_${cpu}_8-SMRTcells
rm runSequelT-S_len_${cpu}_8-SMRTcells/*.sam
```
For running it on 4 to 16 CPUs:

```bash
for i in $(seq 4 16); do
  runSequelT-S_len.sh $i
done
```
