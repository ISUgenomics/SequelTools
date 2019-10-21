# SequelTools

_SequelTools_ is a fast and easy to install command-line program that provides a collection of tools for working with multiple SMRTcells of PacBio Sequel raw sequece data containing three tools: the Quality Control (QC) tool, the Read Subsampling tool, and the Read Filtering tool.  The QC tool produces multiple statistics and publication quality plots describing the quality of the data including N50, read length and count statistics, PSR, and ZOR.  The Read Subsampling tool allows the user to subsample their BAM format sequence files by one or more potential criteria: longest subreads per CLR, or random CLR selection. This tool provides the user a filtering functionality and requires both scraps files and subreads files to function. Filtering can be done using one or more of the following criteria: 1) minimum CLR length, 2) having at least one complete pass of the DNA molecule past the polymerase, or 3) Normal adapters for scrap







## Installation

### Dependencies
_SequelQC_ has been tested in a Linux environment and it requires following programs to be in the path
1. Samtools
2. Python (version 2 or 3)
3. R

Both R and Python should be pre-installed if you're using Linux. Samtools can be easily installed from here:
http://www.htslib.org

### SequelQC installation
Once installed, clone the github repository, make the scripts executables and add it to your path like so:

```
git clone https://github.com/ISUgenomics/SequelQC.git
cd SequelQC
chmod +x *.sh *.py
export PATH=$PATH:"$(pwd)"
```
For a more permanent solution, you can add the export path line to your `.bashrc` file

```
PATH=$PATH:/path/to/SequelQC
```

No compilation is required so you are now done with installation! 

## Running SequelQC

For a test data set we recommend using NCBI BioProject PRJNA483067, which can be found at https://www.ncbi.nlm.nih.gov/sra?linkname=bioproject_sra_all&from_uid=483067

The `SequelQC.sh` is the main script to execute. This script will call all other necessary scripts. You can test whether the main script was properly installed by calling the script alone:

```
./SequelQC.sh
```

or 

```
bash SequelQC.sh
```

This should bring up the help menu.

_SequelQC_ has only one required argument, `-u`. The argument `-u` requires a file listing all the locations of the s`u`bread BAM files.  With this argument alone _SequelQC_ will run without scraps files.  _SequelQC_ may also be run with scraps files by including the `-c` parameter which requires a file listing the location of all s`c`raps BAM files.  In each case the format is simply one filename per line.  With scraps files _SequelQC_ takes longer to run, but also creates more plots and provides more information within the same plots regarding continuous long reads (CLRs).

The easy way to generate these files is using the find command:

```
find $(pwd) -name "*subreads.bam"  > subreads.txt
find $(pwd) -name "*scraps.bam"  > scraps.txt
```

Once done, to run _SequelQC_ using all default arguments execute `SequelQC.sh` as follows:

```
./SequelQC.sh -u subreads.txt
```

or 

```
bash SequelQC.sh -u subreads.txt
```

or


```
./SequelQC.sh -u subreads.txt -c scraps.txt
```

or 

```
bash SequelQC.sh -u subreads.txt -c scraps.txt
```

## Other Arguments

_SequelQC_ has many other arguments that are worth considering before running it on your data. You can get an updated and comprehensive summary of these arguments by accessing the help menu.  The help menu will present itself if the user calls _SequelQC_ with no arguments, calls _SequelQC_ with the -h argument, or makes any number of mistakes while running the program.

One important argument is `-n`, which sets the number of threads to use for samtools.  The default is 1, but the more threads used the faster the program will run.  

Another optional argument is `-o`, which sets the directory for outputting all final tables and plots.  The default is to make a folder called SequelQCresults and put the final table and plots there.  If the folder SequelQCresults is already present when you run _SequelQC_, all contents within the folder will be erased before the new results are written there.  For that reason if you plan to run the program on multiple datasets you'll either want to do it in seperate folders or use the `-o` option to create multiple output folders.

The `-v` argument allows the user to get updates on what _SequelQC_ is doing as it does it, and the `-k` argument tells _SequelQC_ to keep all intermediate files.  These files are created in the directory _SequelQC_ is ran in and are normally deleted before the program finishes.  The `-k` parameter is very useful for rerunning _SequelQC_ using different plotting parameters or using a custom R script.  It could also be used to give the user raw data they would not otherwise be given. Along with the `-k` parameter, if the user has already generated intermediate files, the user can comment out the lines in `SequelQC.sh` that call samtools and Python.  This will cut out the large majority of the runtime.  As for using a custom R script for plotting, the user can make their own plotting script or modify ours and then simply replace the name of our R script in `SequelQC.sh` with the name of the user's script.

The `-g` argument allows the user to see fewer groups of reads in the final table and plots.  By default the four groups are the full Continuous Long Read (CLR), CLRs with subreads (referred to as subedCLRs), all subreads, and the longest subreads for each subedCLR.  The default parameter to provide to the `-g` argument is `a` for all.  The user can choose instead to see only subedCLRs and all subreads by providing the parameter `b` for basic.

While the summary statistics table is always produced, the user can request more or fewer plots based on their needs using the `-p` argument. The full suite of plots is barplots of A) N50s, B) L50s, and C) total bases, histograms of D) read lengths, E) subreads per subedCLR, and F) adapters per CLR, boxplots of G) subread and H) subedCLR read lengths with N50s, and I)ZOR and J) PSR plots. The user can also request an intermediate (A,C,G,H,I, & J) or basic (A & C) suite of plots, with the intermediate selection of plots being default. 

### Using alternative R plotting scripts

Some users may want to modify _SequelQC_'s plots and the summary statistics table or to use _SequelQC_'s intermediate files to generate completely different plots.  Such users will need to run _SequelQC_ once using the `-k` argument to generate the indermediate files and retain them at the end of _SequelQC_'s operation.  Next, the user will need to create their custom R script.  If the user wishes to modify _SequelQC_'s plots, rather than generate completely different plots, said user should start by copying and renaming either `plotForSequelQC_wScraps.R` or `plotForSequelQC_noScraps.R` depending on whether said user is running _SequelQC_ with or without scraps files, respectively. 

Next the user will need to modify the copied script as needed.  During the process of writing scripts it is common to run the script several times to test new code as it is being written.  In order to make this process faster for the user we have added a parameter `-s` which will skip the read length calculations with samtools and the statistical calculations with Python which together generate the intermediate files.  Together these steps make up most of the runtime of _SequelQC_, therefore skipping these steps allows for rapid testing of alternative plotting scripts. Whether the user is modifying a _SequelQC_ R plotting script or using one created from scratch, at this time the user will also need to provide the custom plotting script to _SequelQC_.  This can be done by using the `-r` argument followed by the name of the custom script.  Keep in mind that the `-k` argument will remain necessary or else the intermediate files will all be deleted at the end of _SequelQC_'s operation.

An example of running \textit{SequelQC} with an alternative R plotting script with minimal recommended arguments with scraps files:

\indent\code{bash SequelQC.sh -u subFiles.txt -c scrFiles -k -s -r altRscript\_wScraps.R}

and without scraps files:

\indent\code{bash SequelQC.sh -u subFiles.txt -k -s -r altRscript\_noScraps.R}

