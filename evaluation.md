# Assembling subreads after processing through SequelTools

The raw data was downloaded from the PacBio ftp site, that provides public accessible PacBio Sequel II dataset for many genomes. We used _Arabidopsis thaliana_ dataset for assembly.

```bash
wget https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/SequenceData/3_C01_customer/m54113_160914_092411.scraps.bam
wget https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/SequenceData/3_C01_customer/m54113_160914_092411.subreads.bam
wget https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/SequenceData/1_A01_customer/m54113_160913_184949.scraps.bam
wget https://downloads.pacbcloud.com/public/SequelData/ArabidopsisDemoData/SequenceData/1_A01_customer/m54113_160913_184949.subreads.bam
```

List of input files were generated as follows:

```bash
ls *.scraps.bam > scraps.fofn
ls *.subreads.bam > subreads.fofn
```

## Assembling the raw dataset without filtering

Canu was used to assemble the subreads as-is. First the reads were converted to fasta format and then a config file was created with the canu parameters.

```bash
samtools fasta --threads 16 m54113_160914_092411.subreads.bam > m54113_160914_092411.subreads.fasta
samtools fasta --threads 16 m54113_160913_184949.subreads.bam > m54113_160913_184949.subreads.fasta
cat *.subreads.fasta > subreads-raw.fa
```

The config file for the raw dataset was as follows:


```
genomeSize=135m
useGrid=true
gridEngine=slurm
gridEngineResourceOption="--time=4:00:00 -N 1 --cpus-per-task=THREADS --mem-per-cpu=MEMORY"
gridOptionsCNS="--time=8:00:00 -N 1 -p freefat --cpus-per-task=8 --mem-per-cpu=40GB"
```

Canu was executed as follows:

```bash
source /work/LAS/mhufford-lab/shared_dir/minconda/20181213/etc/profile.d/conda.sh
conda activate denovo_asm
tdate=$(date '+%Y%m%d')
aname=athal_raw
cfg=athal.cfg
fq="subreads-raw.fa"
canu \
   -p $aname \
   -d "canu-${tdate}" \
   -s $cfg \
   -pacbio-raw $fq
```

The stats were calculated using the Assemblathon Script:

```
Assumed genome size (Mbp)     135.00

        Number of scaffolds        555
    Total size of scaffolds  124850704
Total scaffold length as percentage of assumed genome size      92.5%
           Longest scaffold    4243121
          Shortest scaffold       2357
Number of scaffolds > 1K nt        555 100.0%
Number of scaffolds > 10K nt        528  95.1%
Number of scaffolds > 100K nt        219  39.5%
Number of scaffolds > 1M nt         30   5.4%
Number of scaffolds > 10M nt          0   0.0%
         Mean scaffold size     224956
       Median scaffold size      65852
        N50 scaffold length     699106
         L50 scaffold count         46
       NG50 scaffold length     637854
        LG50 scaffold count         54
N50 scaffold - NG50 scaffold length difference      61252
                scaffold %A      31.80
                scaffold %C      18.18
                scaffold %G      18.20
                scaffold %T      31.82
                scaffold %N       0.00
        scaffold %non-ACGTN       0.00
Number of scaffold non-ACGTN nt          0
```

The job summary stats (MaxRSS, runtime, CPUtime) were calculated using the standard `slurm` command `sacct`

```
sacct --format JobId,JobName,ReqCPUS,ReqMem,ReqNodes,Elapsed,SystemCPU,CPUTime,MaxRSS,MaxVMSize,State,Start,End -u arnstrm
```

## Assembling the PacBio dataset after filtering for CLRs >= 5Kb

Canu was used for assembly, but the reads were first processed using SequelTools. After processing, the reads were converted to fasta.

Filtering using SequelTools:

```bash
module purge
PATH=$PATH:/ptmp/LAS/arnstrm/sequelqc
ml r-devtools samtools python
SequelTools.sh -c scraps.txt -u subreads.txt -t F -C -Z 5000 -n 16 -o runSequelT-F_len
```

```bash
cd runSequelT-F_len
samtools fasta --threads 16 m54113_160913_184949.subSampledSubs.sam > m54113_160913_184949.subSampledSubs.fasta
samtools fasta --threads 16 m54113_160914_092411.subSampledSubs.sam > m54113_160914_092411.subSampledSubs.fasta
cat *.subSampledSubs.fasta > subSampledSubs5kb.fa
```

The config file for the raw dataset was as follows:


```
genomeSize=135m
useGrid=true
gridEngine=slurm
gridEngineResourceOption="--time=4:00:00 -N 1 --cpus-per-task=THREADS --mem-per-cpu=MEMORY"
gridOptionsCNS="--time=8:00:00 -N 1 -p freefat --cpus-per-task=8 --mem-per-cpu=40GB"
```

Canu was executed as follows:

```bash
source /work/LAS/mhufford-lab/shared_dir/minconda/20181213/etc/profile.d/conda.sh
conda activate denovo_asm
tdate=$(date '+%Y%m%d')
aname=athal_l5kb
cfg=athal.cfg
fq="subSampledSubs5kb.fa"
canu \
   -p $aname \
   -d "canu-${tdate}" \
   -s $cfg \
   -pacbio-l5kb $fq
```

The stats were calculated using the Assemblathon Script:

```
Assumed genome size (Mbp)     135.00

      Number of scaffolds        659
  Total size of scaffolds  126349435
Total scaffold length as percentage of assumed genome size      93.6%
         Longest scaffold    4243141
        Shortest scaffold       6520
Number of scaffolds > 1K nt        659 100.0%
Number of scaffolds > 10K nt        649  98.5%
Number of scaffolds > 100K nt        253  38.4%
Number of scaffolds > 1M nt         24   3.6%
Number of scaffolds > 10M nt          0   0.0%
       Mean scaffold size     191729
     Median scaffold size      62543
      N50 scaffold length     576605
       L50 scaffold count         60
     NG50 scaffold length     493763
      LG50 scaffold count         68
N50 scaffold - NG50 scaffold length difference      82842
              scaffold %A      31.80
              scaffold %C      18.20
              scaffold %G      18.22
              scaffold %T      31.77
              scaffold %N       0.00
      scaffold %non-ACGTN       0.00
Number of scaffold non-ACGTN nt          0
```

The job summary stats (MaxRSS, runtime, CPUtime) were calculated using the standard `slurm` command `sacct`

```
sacct --format JobId,JobName,ReqCPUS,ReqMem,ReqNodes,Elapsed,SystemCPU,CPUTime,MaxRSS,MaxVMSize,State,Start,End -u arnstrm
```
