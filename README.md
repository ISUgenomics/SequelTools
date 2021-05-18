# SequelTools

For more information please read our paper found at https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03751-8.  Whenever using this software or presenting data generated from this software you are obligated to cite this paper.  This work is protected by an open source GNU general public liscence.

_SequelTools_ is a fast and easy to install command-line program that provides a collection of tools for working with multiple SMRTcells of BAM format PacBio Sequel raw sequece data.  _SequelTools_ contains three tools: the Quality Control (QC) tool, the Read Subsampling tool, and the Read Filtering tool.  The QC tool produces multiple statistics and publication quality plots describing the quality of the data including N50, read length and count statistics, PSR, and ZOR.  The Read Subsampling tool allows the user to subsample their sequence files by one or more potential criteria: longest subreads per continuous long read (CLR), or random CLR selection. This tool provides the user a filtering functionality and requires both scraps files and subreads files to function. Filtering can be done using one or more of the following criteria: 1) minimum CLR length, 2) having at least one complete pass of the DNA molecule past the polymerase, or 3) Normal adapters for scraps reads.

## Installation

### Dependencies
_SequelTools_ has been tested in Linux and Mac environments and requires the following programs to be in the path
1. Samtools
2. Python (version 2 or 3)
3. R

Both R and Python should be pre-installed if you're using Linux. Python comes pre-installed on Macs, but R is not. 
Samtools can be easily installed from here:
http://www.htslib.org

R can be easily installed from here:
https://cran.r-project.org/bin/macosx/

### SequelTools installation
Once installed, clone the github repository, make the script executables, and add it to your path like so:

```
git clone https://github.com/ISUgenomics/SequelTools.git
cd SequelTools/Scripts
chmod +x *.sh *.py *.R
export PATH=$PATH:"$(pwd)"
```
For a more permanent solution, you can add the export path line to the `.bashrc` file in your home directory for Linux.  For Mac users use `.bash_profile` instead of `.bashrc`.

```
PATH=$PATH:/path/to/SequelTools
```

No compilation is required, and only standard R packages and Python libraries are used so you are now done with installation! 

## Running SequelTools

For a test data set we recommend using the same data set as we used in the paper, XXXXXXXXXXXXX.  Running _SequelTools_' QC tool with all groups and plots will create the figures in the "Figures" folder on this GitHub page.

The `SequelTools.sh` is the main script to execute. This script will call all other necessary scripts. You can test whether the main script was properly installed by calling the script alone:

```
./SequelTools.sh
```

or 

```
bash SequelTools.sh
```

This should bring up the help menu.

For the QC tool and Read Subsampling tools _SequelTools_ has only two required arguments, `-t` and `-u`. The argument `-t` specifies which tool is being used, and the argument `-u` identifies a file listing all the locations of the subread BAM files.  The Read Filtering tool, unlike the QC and Read Subsampling tools, requires scraps files in addition to subreads files and therefore requires the additional parameter `-c`, which identifies a file listing all the locations of the scraps BAM files.

While the QC and Read Subsampling tools do not require scraps files, these tools can also be run with scraps files by including the `-c` parameter.  In the case of `-u` and `-c` the format is a file of filenames, in other words, simply one BAM filename per line.  With scraps files _SequelTools_ takes longer to run, but scraps files provide additional functionality for the Read Subsampling tool, and for the QC tool more plots are created and more information is provided within the same plots regarding CLRs.

The easy way to generate these files is using the find command:

```
find $(pwd) -name "*subreads.bam"  > subFiles.txt
find $(pwd) -name "*scraps.bam"  > scrFiles.txt
```

### The QC tool

Once these files are created, to run _SequelTools_' QC tool using all default arguments, with scraps files, execute `SequelTools.sh` as follows:

```
./SequelTools.sh -t Q -u subFiles.txt -c scrFiles.txt
```

or 

```
bash SequelTools.sh -t Q -u subFiles.txt -c scrFiles.txt
```

and without scraps files:

```
./SequelTools.sh -t Q -u subFiles.txt
```

or 

```
bash SequelTools.sh -t Q -u subFiles.txt
```

### The Read Subsampling tool

The `-T` argument is how the user chooses by which criteria _SequelTools_' Read Subsampling tool will subsample.  The options for criteria are `l` for longestt subreads and `r` for random CLR subsampling. 

When using the random CLR subsampling option, although a default (0.1) is provided, it is recommended that the user provide a value from 0 to 1 which specifies the proportion of CLRs to be retained in random CLR subsampling.  This can be done using the argument `-R`

To run _SequelTools_' Read Subsampling tool in its simplest construction, subsampling using both criteria with scraps files, execute `SequelTools.sh` as follows:

```
./SequelTools.sh -t S -u subFiles.txt -c scrapsFiles.txt -T lr
```

or

```
bash SequelTools.sh -t S -u subFiles.txt -c scrapsFiles.txt -T lr
```

and without scraps files:

```
./SequelTools.sh -t S -u subFiles.txt -T lr
```

or

```
bash SequelTools.sh -t S -u subFiles.txt -T lr
```

### The Read Filtering tool

When using _SequelTools_' Read Filtering tool The user must choose one or more criteria for filtering.  The `-C` argument filters by minimum CLR length, the `-P` tool filters by number of complete passes of the DNA template, and the `-N` filters by normal scraps adapters defined as having a ZMW classification annotation of 'N' for 'normal' and a scrap region-type annotation of 'A' for 'adapter'.

When filtering by CLR minimum length, the minimum length threshold for retaining each CLR must be provided using the argument `-Z`.

To run _SequelTools_' Read Filtering tool in its simplest construction using  all three  possible  filtering  criteria  and  using  1000  base  pairs  as  the  minimum  CLR length execute `SequelTools.sh` as follows:

```
./SequelTools.sh -t F -u smallSubs.txt -c smallScraps.txt -C -P -N -Z 1000
```

or

```
bash SequelTools.sh -t F -u smallSubs.txt -c smallScraps.txt -C -P -N -Z 1000
```

## Other Arguments

_SequelTools_ has many other arguments that are worth considering before running it on your data. You can get an updated and comprehensive summary of these arguments by accessing the help menu.  The help menu will present itself if the user calls _SequelTools_ with no arguments, calls _SequelTools_ with the -h argument, or makes any number of mistakes while running the program.

One important argument is `-n`, which sets the number of threads to use for samtools.  The default is 1, but the more threads used the faster the program will run.  

Another optional argument is `-o`, which sets the directory for outputting all final tables and plots.  The default is to make a folder called SequelToolsResults and put the final table and plots there.  If the folder SequelToolsResults is already present when you run _SequelTools_, all contents within the folder will be erased before the new results are written there.  For that reason if you plan to run the program on multiple datasets you'll either want to do it in seperate folders or use the `-o` option to create multiple output folders.

The `-v` argument allows the user to get more detailed updates on what _SequelTools_ is doing as it runs.

### QC Tool arguments
The `-k` argument tells _SequelTools_ to keep all intermediate QC files.  These files are created in the output folder and are normally deleted before the program finishes.  The `-k` parameter is very useful for rerunning _SequelTools_' QC Tool multiple times using different plotting parameters or using a custom R script.  It could also be used to give the user raw data they would not otherwise be given. 

The `-g` argument allows the user to see fewer groups of reads in the final table and plots.  By default the four groups are the full CLRs, CLRs with subreads (referred to as subedCLRs), all subreads, and the longest subreads for each subedCLR.  The default parameter to provide to the `-g` argument is `a` for all.  The user can choose instead to see only subedCLRs and all subreads by providing the parameter `b` for basic.

While the summary statistics table is always produced, the user can request more or fewer plots based on their needs using the `-p` argument. The full suite of plots is barplots of A) N50s, B) L50s, and C) total bases, histograms of D) read lengths, E) subreads per subedCLR, and F) adapters per CLR, boxplots of G) subread and H) subedCLR read lengths with N50s, and I)ZOR and J) PSR plots. The user can also request an intermediate (A,C,G,H,I, & J) or basic (A & C) suite of plots, with the intermediate selection of plots being default. 

#### Using alternative R plotting scripts

Some users may want to modify _SequelTools_' QC plots and the summary statistics table or to use _SequelTools_' intermediate QC files to generate completely different plots.  Such users will need to run _SequelTools_' QC tool once using the `-k` argument to generate the indermediate files and retain them at the end of _SequelTools_' operation.  Next, the user will need to create their custom R script.  If the user wishes to modify _SequelTools_' QC plots, rather than generate completely different plots, said user should start by copying and renaming either `plotForSequelQC_wScraps.R` or `plotForSequelQC_noScraps.R` depending on whether said user is running the QC tool with or without scraps files, respectively. 

Next the user will need to modify the copied script as needed.  During the process of writing scripts it is common to run the script several times to test new code as it is being written.  In order to make this process faster for the user we have added a parameter `-s` which will skip the read length calculations with samtools and the statistical calculations with Python which together generate the QC intermediate files.  Together these steps make up most of the runtime of _SequelTools_' QC Tool, therefore skipping these steps allows for rapid testing of alternative plotting scripts. Whether the user is modifying a _SequelTools_ R QC plotting script or using one created from scratch, at this time the user will also need to provide the custom plotting script to _SequelTools_.  This can be done by using the `-r` argument followed by the name of the custom script.  Keep in mind that the `-k` argument will remain necessary or else the intermediate files will all be deleted at the end of _SequelTools_' operation.

An example of running _SequelTools_ with an alternative R plotting script with minimal recommended arguments with scraps files:

```
./SequelTools.sh -t Q -u subFiles.txt -c scrFiles -k -s -r altRscript_wScraps.R
```

or

```
bash SequelTools.sh -t Q -u subFiles.txt -c scrFiles -k -s -r altRscript_wScraps.R
```

and without scraps files:

```
./SequelTools.sh -t Q -u subFiles.txt -k -s -r altRscript_noScraps.R
```

or

```
bash SequelTools.sh -t Q -u subFiles.txt -k -s -r altRscript_noScraps.R
```

### The Read Subsampling and Read Filtering Tool formatting argument

The `-f` argument allows the user to choose the format of the results files.  The options for this argument are `s` for SAM format, `b` for BAM format, and `2` for both formats.


