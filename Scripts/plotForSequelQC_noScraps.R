#!/usr/bin/env Rscript
#This script is designed to make all plots for SequelQC
#Created by David E. Hufnagel on Nov 24, 2018




#Define functions
##Take in file and file lengths for read length files and put the data into
##  matrices with one row per SMRTcell
ReadLensFileToMatrix = function(filesLst, FLsLst){
    #Determine max number of read lengths across SMRTcells
    maxNumRLs=0
    for(FL in FLsLst){
        if (FL > maxNumRLs){
            maxNumRLs = FL
        }
    }        

    #Process files
    newMatrix = matrix(data=NA, nrow=numPairs, ncol=maxNumRLs)
    i = 1
    for(fileName in filesLst){
        fd = as.numeric(as.matrix(read.table(fileName))[,1])
        theseNames = names(fd)
        diff = maxNumRLs-length(fd)
        extra = rep(NA, diff)
        fd = append(fd, extra)

        newMatrix[i,] = fd
        i = i + 1

    }
    rownames(newMatrix) = filesLst

    return(newMatrix)
}




#Disallow scientific notation for the purpose of plotting
options(scipen=999)

#Take in files and file lengths and assign them to variables
args = commandArgs(TRUE)
allFiles = strsplit(args[1], ",")[[1]]
allFileLengths = strsplit(args[2], ",")[[1]]
plotsDesired = args[3]
verbose = args[4]
outFold = args[5]

SMRTcellStatsFiles = c(); readLensSubFiles = c(); readLensLongSubFiles = c()
SMRTcellStatsFLs = c(); readLensSubFLs = c(); readLensLongSubFLs = c()
numFiles = length(allFiles)
numFilesPerPair = 3
for(i in seq(numFiles)){
    fileInd = i%%numFilesPerPair
    file = allFiles[i]; fileLen = as.numeric(allFileLengths[i])

    #add files and their respective lengths to arrays 
    if (fileInd == 1) {
        SMRTcellStatsFiles = append(SMRTcellStatsFiles, file)
        SMRTcellStatsFLs = append(SMRTcellStatsFLs, fileLen-1) #-1 is to account for header
    }
    else if (fileInd == 2) {
        readLensSubFiles = append(readLensSubFiles, file)
        readLensSubFLs = append(readLensSubFLs, fileLen)
    }
    else if (fileInd == 0) {
        readLensLongSubFiles = append(readLensLongSubFiles, file)
        readLensLongSubFLs = append(readLensLongSubFLs, fileLen)
    }
    else {
        print("ERROR: R was given too many parameters")
        stop()
    }
}


#Determine names of SMRTcells
pairNames = c()
for(fileName in SMRTcellStatsFiles){
    pairName = strsplit(strsplit(fileName,".SMRTcellStats_noScraps.txt")[[1]], "/")[[1]][2]
    pairNames = append(pairNames, pairName)
}

if (verbose=="true"){
    cat("Data sucessfully imported to R\n")
    cat("Storing data in matrices\n")
}


#Import data from files into matrices
##First for SMRTcell stats files
numPairs = length(SMRTcellStatsFiles)
numSMRTcellStats = 10

SMRTcellStatsMatrix = matrix(data=NA, nrow=numPairs, ncol=numSMRTcellStats)
i = 1
for(fileName in SMRTcellStatsFiles){
    fd = as.matrix(read.table(fileName, header=TRUE))[1,]

    SMRTcellStatsMatrix[i,] = fd
    if (i == 1){
        colnames(SMRTcellStatsMatrix) = names(fd)
    }
    i = i + 1
}
rownames(SMRTcellStatsMatrix) = pairNames


##Then for read length files
subReadLensMatrix = ReadLensFileToMatrix(readLensSubFiles, readLensSubFLs)
longSubReadLensMatrix = ReadLensFileToMatrix(readLensLongSubFiles, readLensLongSubFLs)


#Calculate ZORs and PSRs and store them in arrays
if (plotsDesired != "b") {
    zors = c(); psrs = c()
    for(i in seq(numPairs)){
        #Calculate and store ZOR
        numSubs = readLensSubFLs[i]
        numLongSubs = readLensLongSubFLs[i]
        zor = numLongSubs / numSubs
        zors = append(zors, zor)

        #Calculate and store PSR
        subBases = sum(subReadLensMatrix[i,], na.rm=TRUE)
        longSubBases = sum(longSubReadLensMatrix[i,], na.rm=TRUE)
        psr = longSubBases / subBases
        psrs = append(psrs, psr)
    }
}
if (verbose=="true"){
    cat("Data stored in matrices\n")
    cat("Beginning to make plots\n")
}


#Make N50 and L50 bar plots
subN50s = c();longSubN50s = c()
subL50s = c(); longSubL50s = c()
for(i in seq(numPairs)){
    subN50 = SMRTcellStatsMatrix[i,4]    
    longSubN50 = SMRTcellStatsMatrix[i,9]
    subN50s = append(subN50s, subN50)
    longSubN50s = append(longSubN50s, longSubN50)

    subL50 = SMRTcellStatsMatrix[i,5]
    longSubL50 = SMRTcellStatsMatrix[i,10]
    subL50s = append(subL50s, subL50)
    longSubL50s = append(longSubL50s, longSubL50)
}


##plot
plotName = sprintf("%s/n50s.pdf",outFold)
pdf(plotName)
par(omi=c(0.8,0.2,0,0), mgp=c(3.5,1,0), mar=c(7.1, 4.3, 4.1, 2.1))
allN50s = rbind(subN50s,longSubN50s)
groupNames=c("subreads","longestSubs")

barplot(allN50s, main="N50 summary", ylab="N50", las=2, beside=TRUE, names.arg=pairNames, col=c("#0276FD","chartreuse2"), ylim=c(0,max(allN50s)*1.2))
legend("topright", legend=groupNames, pch=15, col=c("#0276FD","chartreuse2"))
invisible(dev.off())

if (plotsDesired == "a") {
    plotName = sprintf("%s/l50s.pdf",outFold)
    pdf(plotName)
    par(omi=c(0.8,0,0,0), mgp=c(3.9,1,0), mar=c(7.1, 5.1, 4.1, 2.1))
    allL50s = rbind(subL50s,longSubL50s)

    barplot(allL50s, main="L50 summary", ylab="L50", las=2, beside=TRUE, names.arg=pairNames, col=c("#0276FD","chartreuse2"), ylim=c(0,max(allL50s)*1.4))
    legend("topright", legend=groupNames, pch=15, col=c("#0276FD","chartreuse2"))
    invisible(dev.off())
}


#Make data table with total bases, number of reads, mean and median read 
#  length, N50, and L50 for the following groups: subreads, longest subreads,
#  as well as PSR, and ZOR. Also build total bases arrays and min, max, and 
#  mean values for longest subread lengths for future use.
plotName = sprintf("%s/summaryTable.txt",outFold)
sink(plotName)
cat("SMRTcell\tnumReadsSubread\tnumReadsLongestSub\ttotalBasesSubread\ttotalBasesLongestSub\tmeanReadLenSubread\tmeanReadLenLongestSub\tmedianReadLenSubread\tmedianReadLenLongestSub\tn50Subread\tn50LongestSub\tl50Subread\tl50LongestSub\tPSR\tZOR\n")
totalBasesSubAr = c(); totalBasesLongSubAr = c()
minLongSubRLs = c(); maxLongSubRLs = c(); meanLongSubRLs = c()
for(i in seq(numPairs)){
    #Gather data
    pairName = pairNames[i]
    numSubreads = readLensSubFLs[i]

    totalSubBases = sum(subReadLensMatrix[i,][!is.na(subReadLensMatrix[i,])])
    totalBasesSubAr = append(totalBasesSubAr, totalSubBases)

    subN50 = subN50s[i]
    subL50 = subL50s[i]

    numLongSubs = readLensLongSubFLs[i]

    totalLongSubBases = sum(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
    totalBasesLongSubAr = append(totalBasesLongSubAr, totalLongSubBases)

    meanSubreadRL = SMRTcellStatsMatrix[i,2]
    meanLongSubRL = SMRTcellStatsMatrix[i,7]

    minLongSubRL = min(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
    maxLongSubRL = max(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
    minLongSubRLs = append(minLongSubRLs, minLongSubRL)
    maxLongSubRLs = append(maxLongSubRLs, maxLongSubRL)
    meanLongSubRLs = append(meanLongSubRLs, meanLongSubRL)

    medianSubreadRL = SMRTcellStatsMatrix[i,3]
    medianLongSubRL = SMRTcellStatsMatrix[i,8]

    longSubN50 = longSubN50s[i]
    longSubL50 = longSubL50s[i]

    psr = psrs[i]
    zor = zors[i]

    #Output the data to a summary table
    toOut = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", pairName, numSubreads, numLongSubs, totalSubBases, totalLongSubBases, meanSubreadRL, meanLongSubRL, medianSubreadRL, medianLongSubRL, subN50, longSubN50, subL50, longSubL50, sprintf("%.3f", round(psr, 3)), sprintf("%.3f", round(zor, 3)))
    cat(toOut)
}
sink()


#Make read length histograms for all the same groups for each SMRTcell
if (plotsDesired == "a") {
    for(i in seq(numPairs)){
        #Gather data
        subRLs = subReadLensMatrix[i,]
        longSubRLs = longSubReadLensMatrix[i,]

        #Create strings to use for plotting
        histName = sprintf("%s.readLenHists.pdf", pairNames[i])
        subTitle = sprintf("Histogram of subread read lengths for %s", pairNames[i])
        longSubTitle = sprintf("Histogram of longest subread read lengths for %s", pairNames[i])

        #Determine the number of breaks to use
        subBreaks = round((max(subRLs, na.rm=TRUE) / 1000), 0)
        longSubBreaks = round((max(longSubRLs, na.rm=TRUE) / 1000), 0)

        #Determin the xlim to use
        topVal = max(subRLs,longSubRLs, na.rm=TRUE)
        cutoff = topVal*0.8

        #Plot
        pdf(histName); par(lwd=1.5, mfrow=c(2,1))
        hist(subRLs, xlab="Read Length (bp)", main=subTitle, breaks=subBreaks, col="#0276FD", xlim=c(0,cutoff))
        hist(longSubRLs, xlab="Read Length (bp)", main=longSubTitle, breaks=longSubBreaks, col="chartreuse2", xlim=c(0,cutoff))
        invisible(dev.off())
    }
}


#Make a barplot of total bases for all the same groups for each SMRTcell
plotName = sprintf("%s/totalBasesBarplot.pdf",outFold)
pdf(plotName)
par(omi=c(1.2,0,0,0), mgp=c(3.6,1,0), mar=c(5.1, 5.1, 4.1, 2.1))
totalBasesArray = rbind(totalBasesSubAr, totalBasesLongSubAr)

barplot(totalBasesArray/1000000, main="Total Bases Barplot", ylab="Total Bases (Mb)", las=2, beside=TRUE, names.arg=pairNames, col=c("#0276FD","chartreuse2"), ylim=c(0,max(totalBasesArray)*1.15/1000000))
legend("topright", legend=groupNames, pch=15, col=c("#0276FD","chartreuse2"))
invisible(dev.off())


#Make ZOR and PSR plots
if (plotsDesired != "b") {
    plotName = sprintf("%s/zors.pdf",outFold)
    pdf(plotName, height=2.5)
    par(mar=c(2.5,1,9,1))
    xStart = min(zors)-0.01 #Determine xlims for ZORs 
    xStop = max(zors)+0.01
    if (xStart < 0) {
	xStart = 0
    }
    if (xStop > 1.0) {
	xStop = 1.0
    }
    plot(-1,-1, xlim=c(xStart,xStop), ylim=c(0,1.0), xaxt="n", yaxt="n", ylab="", xlab="") #Start with an empty plot
    abline(v=zors, lwd=1.5, col="black") #Then attach vertical lines for ZORs
    axis(1, at=seq(0,1,0.01))
    for(i in seq(numPairs)){ #Then add SMRTcell labels
        mtext(pairNames[i], side=3, at=c(zors[i],1.1), las=2, cex=0.79, line=0.2)
    }
    title("ZORs", line=7.9) #Finally add the title
    invisible(dev.off())

    plotName = sprintf("%s/psrs.pdf",outFold)
    pdf(plotName, height=2.5)
    par(mar=c(2.5,1,9,1))
    xStart = min(psrs)-0.01 #Determine xlims for ZORs 
    xStop = max(psrs)+0.01
    if (xStart < 0) {
        xStart = 0
    }
    if (xStop > 1.0) {
        xStop = 1.0
    }
    plot(-1,-1, xlim=c(xStart,xStop), ylim=c(0,1), xaxt="n", yaxt="n", ylab="", xlab="") #Start with an empty plot
    abline(v=psrs, lwd=1.5, col="black") #Then attach vertical lines for PSRs
    axis(1, at=seq(0,1,0.01))
    for(i in seq(numPairs)){ #Then add SMRTcell labels
        mtext(pairNames[i], side=3, at=c(psrs[i],1.1), las=2, cex=0.79, line=0.2)
    }
    title("PSRs", line=7.9) #Finally add the title
    invisible(dev.off())
}


#Make boxplots
if (plotsDesired != "b") {
    ##Make boxplots of subread sizes with N50 shown 
    plotName = sprintf("%s/subreadSizesBoxplots.pdf",outFold)
    pdf(plotName)
    par(omi=c(1.2,0,0,0), mgp=c(2.55,1,0))
    boxplot(t(subReadLensMatrix)/1000, names=pairNames, ylab="Read Length (kb)", main="Boxplots of Subread Sizes with N50", las=2)
    points(subN50s/1000, pch=18, col="#0276FD", cex=2)
    invisible(dev.off())
}





