#!/usr/bin/env Rscript
#This script is designed to make all plots for SequelQC
#Created by David E. Hufnagel on Aug 1, 2018



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
groupsDesired = args[3]
plotsDesired = args[4]
verbose = args[5]
outFold = args[6]

SMRTcellStatsFiles = c(); readLensSubFiles = c(); readLensLongSubFiles = c()
readLensSubedClrFiles = c(); clrStatsFiles = c()
SMRTcellStatsFLs = c(); readLensSubFLs = c(); readLensLongSubFLs = c()
readLensSubedClrFLs = c(); clrStatsFLs = c()
numFiles = length(allFiles)
numFilesPerPair = 5
if(groupsDesired == "a"){
    readLensClrFiles = c(); readLensClrFLs = c()
    numFilesPerPair = 6
}
for(i in seq(numFiles)){
    fileInd = i%%numFilesPerPair
    file = allFiles[i]; fileLen = as.numeric(allFileLengths[i])

    #add files and their respective lengths to arrays 
    if(groupsDesired == "a"){
        if (fileInd == 1) {
            SMRTcellStatsFiles = append(SMRTcellStatsFiles, file)
            SMRTcellStatsFLs = append(SMRTcellStatsFLs, fileLen-1) #-1 is to account for header
        }
        else if (fileInd == 2) {
            readLensSubFiles = append(readLensSubFiles, file)
            readLensSubFLs = append(readLensSubFLs, fileLen)
        }
        else if (fileInd == 3) {
            readLensClrFiles = append(readLensClrFiles, file)
            readLensClrFLs = append(readLensClrFLs, fileLen)
        }
        else if (fileInd == 4) {
            readLensSubedClrFiles = append(readLensSubedClrFiles, file)
            readLensSubedClrFLs = append(readLensSubedClrFLs, fileLen)
        }
        else if (fileInd == 5) {
            readLensLongSubFiles = append(readLensLongSubFiles, file)
            readLensLongSubFLs = append(readLensLongSubFLs, fileLen)
        }
        else if (fileInd == 0) {
            clrStatsFiles = append(clrStatsFiles, file)
            clrStatsFLs = append(clrStatsFLs, fileLen-1) #-1 is to account for header
        }
        else {
            print("ERROR: R was given too many parameters")
            stop()
        }
    }
    else if (groupsDesired == "b") {
        if (fileInd == 1) {
            SMRTcellStatsFiles = append(SMRTcellStatsFiles, file)
            SMRTcellStatsFLs = append(SMRTcellStatsFLs, fileLen-1) #-1 is to account for header
        }
        else if (fileInd == 2) {
            readLensSubFiles = append(readLensSubFiles, file)
            readLensSubFLs = append(readLensSubFLs, fileLen)
        }
        else if (fileInd == 3) {
            readLensSubedClrFiles = append(readLensSubedClrFiles, file)
            readLensSubedClrFLs = append(readLensSubedClrFLs, fileLen)
        }
        else if (fileInd == 4) {
            readLensLongSubFiles = append(readLensLongSubFiles, file)
            readLensLongSubFLs = append(readLensLongSubFLs, fileLen)
        }
        else if (fileInd == 0) {
            clrStatsFiles = append(clrStatsFiles, file)
            clrStatsFLs = append(clrStatsFLs, fileLen-1) #-1 is to account for header
        }
        else {
            print("ERROR: R was given too many parameters")
            stop()
        }
    }
}


#Determine names of SMRTcells
pairNames = c()
for(fileName in SMRTcellStatsFiles){
    if (groupsDesired == "a") {
    pairName = strsplit(strsplit(fileName,".SMRTcellStats_wScrapsA.txt")[[1]], "/")[[1]][2]
    }else if (groupsDesired == "b") {
    pairName = strsplit(strsplit(fileName,".SMRTcellStats_wScrapsB.txt")[[1]], "/")[[1]][2]
    }

    pairNames = append(pairNames, pairName)
}

if (verbose=="true"){
    cat("Data sucessfully imported to R\n")
    cat("Storing data in matrices\n")
}


#Import data from files into matrices
##First for SMRTcell stats files
numPairs = length(SMRTcellStatsFiles)
if (groupsDesired == "a") {
    numSMRTcellStats = 21
}else if (groupsDesired == "b") {
    numSMRTcellStats = 11
}

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

##Then for clr stats files
maxNumCLRstats = 0 
for(FL in clrStatsFLs){
    if (FL > maxNumCLRstats){
        maxNumCLRstats = FL
    }
}

numSubsPerClrMatrix = matrix(data=NA, nrow=numPairs, ncol=maxNumCLRstats)
numAdsPerClrMatrix = matrix(data=NA, nrow=numPairs, ncol=maxNumCLRstats)
i = 1
for(fileName in clrStatsFiles){
    fdSub = as.numeric(as.matrix(read.table(fileName, header=TRUE))[,2])
    fdAd = as.numeric(as.matrix(read.table(fileName, header=TRUE))[,3])
    diff = maxNumCLRstats-length(fdSub) #length(fdSub) = length(fdAd) 
    extra = rep(NA, diff)
    fdSub = append(fdSub, extra) 
    fdAd = append(fdAd, extra)

    numSubsPerClrMatrix[i,] = fdSub
    numAdsPerClrMatrix[i,] = fdAd

    i = i + 1
}
rownames(numSubsPerClrMatrix) = pairNames; rownames(numAdsPerClrMatrix) = pairNames

##Then for read lengths files
subReadLensMatrix = ReadLensFileToMatrix(readLensSubFiles, readLensSubFLs)
subedClrReadLensMatrix = ReadLensFileToMatrix(readLensSubedClrFiles, readLensSubedClrFLs)
longSubReadLensMatrix = ReadLensFileToMatrix(readLensLongSubFiles, readLensLongSubFLs)
if(groupsDesired == "a"){
    clrReadLensMatrix = ReadLensFileToMatrix(readLensClrFiles, readLensClrFLs)
}


#Calculate ZORs and PSRs and store them in arrays
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

if (verbose=="true"){
    cat("Data stored in matrices\n")
    cat("Beginning to make plots\n")
}


#Make N50 and L50 bar plots
subN50s = c(); subedClrN50s = c()
subL50s = c(); subedClrL50s = c()
if (groupsDesired == "a") {
    clrN50s = c(); clrL50s = c()
    longSubN50s = c(); longSubL50s = c()
}
for(i in seq(numPairs)){
    if (groupsDesired == "a") {
        subN50 = SMRTcellStatsMatrix[i,9]    
        clrN50 = SMRTcellStatsMatrix[i,4]
        subedClrN50 = SMRTcellStatsMatrix[i,14]
        longSubN50 = SMRTcellStatsMatrix[i,19]
        subN50s = append(subN50s, subN50)
        clrN50s = append(clrN50s, clrN50)
        subedClrN50s = append(subedClrN50s, subedClrN50)
        longSubN50s = append(longSubN50s, longSubN50)

        subL50 = SMRTcellStatsMatrix[i,10]
        clrL50 = SMRTcellStatsMatrix[i,5]
        subedClrL50 = SMRTcellStatsMatrix[i,15]
        longSubL50 = SMRTcellStatsMatrix[i,20]
        subL50s = append(subL50s, subL50)
        clrL50s = append(clrL50s, clrL50)
        subedClrL50s = append(subedClrL50s, subedClrL50)
        longSubL50s = append(longSubL50s, longSubL50)
    }
    else if (groupsDesired == "b") {
        subN50 = SMRTcellStatsMatrix[i,9]
        subedClrN50 = SMRTcellStatsMatrix[i,4]
        subN50s = append(subN50s, subN50)
        subedClrN50s = append(subedClrN50s, subedClrN50)

        subL50 = SMRTcellStatsMatrix[i,10]
        subedClrL50 = SMRTcellStatsMatrix[i,5]
        subL50s = append(subL50s, subL50)
        subedClrL50s = append(subedClrL50s, subedClrL50)
    }
}

##plot
plotName = sprintf("%s/n50s.pdf",outFold)
pdf(plotName)
par(omi=c(0.8,0.2,0,0), mgp=c(3.5,1,0), mar=c(7.1, 5.1, 4.1, 2.1))
if (groupsDesired == "a") {
    allN50s = rbind(clrN50s, subedClrN50s, subN50s, longSubN50s)
    groupNames=c("CLRs","subedCLRs","subreads","longestSubreads")
    ourColors=c("black", "gray55", "#0276FD", "chartreuse2")
}else if (groupsDesired == "b") {
    allN50s = rbind(subedClrN50s, subN50s)
    groupNames=c("subedCLRs","subreads")
    ourColors=c("gray55", "#0276FD")
}
barplot(allN50s, main="N50 summary", ylab="N50", las=2, beside=TRUE, names.arg=pairNames, col=ourColors, ylim=c(0,max(allN50s)*1.2))
legend("topright", legend=groupNames, pch=15, col=ourColors)
invisible(dev.off())

if (plotsDesired == "a"){
    plotName = sprintf("%s/l50s.pdf",outFold)
    pdf(plotName)
    par(omi=c(0.8,0,0,0), mgp=c(3.8,1,0), mar=c(7.1, 5.1, 4.1, 2.1))
    if (groupsDesired == "a") {
        allL50s = rbind(clrN50s, subedClrN50s, subN50s, longSubN50s)
    }else if (groupsDesired == "b") {
        allL50s = rbind(subedClrN50s, subN50s)
    }
    barplot(allL50s, main="L50 summary", ylab="L50", las=2, beside=TRUE, names.arg=pairNames, col=ourColors, ylim=c(0,max(allL50s)*1.4))
    legend("topright", legend=groupNames, pch=15, col=ourColors)
    invisible(dev.off())
}

#Make data table with total bases, number of reads, mean and median read 
#  length, N50, and L50 for the following groups: subreads, longest subreads,
#  clrs, and clrs with subreads, as well as PSR, and ZOR. Also build total 
#  bases arrays and min, max, and mean values for longest subread lengths for future use.
plotName = sprintf("%s/summaryTable.txt",outFold)
sink(plotName)
totalBasesSubedClrAr = c(); totalBasesSubAr = c()
if (groupsDesired == "a") {
    cat("SMRTcell\tnumReadsCLR\tnumReadsSubedCLR\tnumReadsSubread\tnumReadsLongestSub\ttotalBasesCLR\ttotalBasesSubedCLR\ttotalBasesSubread\ttotalBasesLongestSub\tmeanReadLenCLR\tmeanReadLenSubedCLR\tmeanReadLenSubread\tmeanReadLenLongestSub\tmedianReadLenCLR\tmedianReadLenSubedCLR\tmedianReadLenSubread\tmedianReadLenLongestSub\tn50CLR\tn50SubedCLR\tn50Subread\tn50LongestSub\tl50CLR\tl50SubedCLR\tl50Subread\tl50LongestSub\tPSR\tZOR\n")
    totalBasesClrAr = c(); totalBasesLongSubAr = c()
    minLongSubRLs = c(); maxLongSubRLs = c(); meanLongSubRLs = c()
}else if (groupsDesired == "b") {
    cat("SMRTcell\tnumReadsSubedCLR\tnumReadsSubread\ttotalBasesSubedCLR\ttotalBasesSubread\tmeanReadLenSubedCLR\tmeanReadLenSubread\tmedianReadLenSubedCLR\tmedianReadLenSubread\tn50SubedCLR\tn50Subread\tl50SubedCLR\tl50Subread\tPSR\tZOR\n")
}
for(i in seq(numPairs)){
    #Gather data
    pairName = pairNames[i]
    numSubedClrReads = readLensSubedClrFLs[i]
    numSubreads = readLensSubFLs[i]

    totalSubedClrBases = sum(subedClrReadLensMatrix[i,][!is.na(subedClrReadLensMatrix[i,])])
    totalSubBases = sum(subReadLensMatrix[i,][!is.na(subReadLensMatrix[i,])])
    totalBasesSubedClrAr = append(totalBasesSubedClrAr, totalSubedClrBases)
    totalBasesSubAr = append(totalBasesSubAr, totalSubBases)

    subN50 = subN50s[i]
    subedClrN50 = subedClrN50s[i]

    subL50 = subL50s[i]
    subedClrL50 = subedClrL50s[i]

    if (groupsDesired == "a") {
        numClrReads = readLensClrFLs[i]
        numLongSubs = readLensLongSubFLs[i]

        totalClrBases = sum(clrReadLensMatrix[i,][!is.na(clrReadLensMatrix[i,])])
        totalLongSubBases = sum(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
        totalBasesClrAr = append(totalBasesClrAr, totalClrBases)
        totalBasesLongSubAr = append(totalBasesLongSubAr, totalLongSubBases)

        meanClrRL = SMRTcellStatsMatrix[i,2]
        meanSubedClrRL = SMRTcellStatsMatrix[i,12]
        meanSubreadRL = SMRTcellStatsMatrix[i,7]
        meanLongSubRL = SMRTcellStatsMatrix[i,17]

        minLongSubRL = min(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
        maxLongSubRL = max(longSubReadLensMatrix[i,][!is.na(longSubReadLensMatrix[i,])])
        minLongSubRLs = append(minLongSubRLs, minLongSubRL)
        maxLongSubRLs = append(maxLongSubRLs, maxLongSubRL)
        meanLongSubRLs = append(meanLongSubRLs, meanLongSubRL)

        medianClrRL = SMRTcellStatsMatrix[i,3]
        medianSubedClrRL = SMRTcellStatsMatrix[i,13]
        medianSubreadRL = SMRTcellStatsMatrix[i,8]
        medianLongSubRL = SMRTcellStatsMatrix[i,18]

        clrN50 = clrN50s[i]
        longSubN50 = longSubN50s[i]

        clrL50 = clrL50s[i]
        longSubL50 = longSubL50s[i]
    }else if (groupsDesired == "b") {
        meanSubedClrRL = SMRTcellStatsMatrix[i,2]
        meanSubreadRL = SMRTcellStatsMatrix[i,7]

        medianSubedClrRL = SMRTcellStatsMatrix[i,3]
        medianSubreadRL = SMRTcellStatsMatrix[i,8]
    }

    psr = psrs[i]
    zor = zors[i]

    #Output the data to a summary table
    if (groupsDesired == "a") {
        toOut = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", pairName, numClrReads, numSubedClrReads, numSubreads, numLongSubs, totalClrBases, totalSubedClrBases, totalSubBases, totalLongSubBases, meanClrRL, meanSubedClrRL, meanSubreadRL, meanLongSubRL, medianClrRL, medianSubedClrRL, medianSubreadRL, medianLongSubRL, clrN50, subedClrN50, subN50, longSubN50, clrL50, subedClrL50, subL50, longSubL50, sprintf("%.3f", round(psr, 3)), sprintf("%.3f", round(zor, 3)))
    }else if (groupsDesired == "b") {
        toOut = sprintf("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", pairName, numSubedClrReads, numSubreads, totalSubedClrBases, totalSubBases, meanSubedClrRL, meanSubreadRL, medianSubedClrRL, medianSubreadRL, subedClrN50, subN50, subedClrL50, subL50, sprintf("%.3f", round(psr, 3)), sprintf("%.3f", round(zor, 3)))
    }
    cat(toOut)
}
sink()


#Make read length histograms for all the same groups for each SMRTcell
if (plotsDesired == "a") {
    for(i in seq(numPairs)){
        #Gather data
        subRLs = subReadLensMatrix[i,]
        subedClrRLs = subedClrReadLensMatrix[i,]

        #Create strings to use for plotting
        histName = sprintf("%s.readLenHists.pdf", pairNames[i])
        subTitle = sprintf("Histogram of subread read lengths for %s", pairNames[i])
        subedClrTitle = sprintf("Histogram of subed-Clr read lengths for %s", pairNames[i])

        #Determine the number of breaks to use
        subBreaks = round((max(subRLs, na.rm=TRUE) / 1000), 0)
        subedClrBreaks = round((max(subedClrRLs, na.rm=TRUE) / 1000), 0)

        if (groupsDesired == "a") {
            #Gather data
            clrRLs = clrReadLensMatrix[i,]
            longSubRLs = longSubReadLensMatrix[i,]

            #Create strings to use for plotting
            clrTitle = sprintf("Histogram of CLR read lengths for %s", pairNames[i])
            longSubTitle = sprintf("Histogram of longest subread read lengths for %s", pairNames[i])
    
            #Determine the number of breaks to use
            clrBreaks = round((max(clrRLs, na.rm=TRUE) / 1000), 0)
            longSubBreaks = round((max(longSubRLs, na.rm=TRUE) / 1000), 0)

            #Determin the xlim to use
            topVal = max(clrRLs, subedClrRLs, subRLs, longSubRLs, na.rm=TRUE)
            cutoff = topVal*0.8

            #Plot
            pdf(histName); par(lwd=1.5, mfrow=c(4,1))

            hist(clrRLs, xlab="Read Length (bp)", main=clrTitle, breaks=clrBreaks, col="black", xlim=c(0,cutoff), border="white", lwd=0.2)
            hist(subedClrRLs, xlab="Read Length (bp)", main=subedClrTitle, breaks=subedClrBreaks, col="gray55", xlim=c(0,cutoff))
            hist(subRLs, xlab="Read Length (bp)", main=subTitle, breaks=subBreaks, col="#0276FD", xlim=c(0,cutoff))
            hist(longSubRLs, xlab="Read Length (bp)", main=longSubTitle, breaks=longSubBreaks, col="chartreuse2", xlim=c(0,cutoff))
            invisible(dev.off())
        }else if (groupsDesired == "b") {
            #Determin the xlim to use
            topVal = max(subedClrRLs, subRLs, na.rm=TRUE)
            cutoff = topVal*0.8

            #Plot
            pdf(histName); par(lwd=1.5, mfrow=c(2,1))

            hist(subedClrRLs, xlab="Read Length (bp)", main=subedClrTitle, breaks=subedClrBreaks, col="gray55", xlim=c(0,cutoff))
            hist(subRLs, xlab="Read Length (bp)", main=subTitle, breaks=subBreaks, col="#0276FD", xlim=c(0,cutoff))
            invisible(dev.off())
        }
    }
}


#Make a barplot of total bases for all the same groups for each SMRTcell
plotName = sprintf("%s/totalBasesBarplot.pdf",outFold)
pdf(plotName)
par(omi=c(1.2,0,0,0), mgp=c(3.6,1,0), mar=c(7.1, 5.1, 4.1, 2.1))
if (groupsDesired == "a") {
    totalBasesArray = rbind(totalBasesClrAr, totalBasesSubedClrAr, totalBasesSubAr, totalBasesLongSubAr)
}else if (groupsDesired == "b") {
    totalBasesArray = rbind(totalBasesSubedClrAr, totalBasesSubAr)
}

barplot(totalBasesArray/1000000, main="Total Bases Barplot", ylab="Total Bases (Mb)", las=2, beside=TRUE, names.arg=pairNames, col=ourColors, ylim=c(0,max(totalBasesArray)*1.15/1000000))
legend("topright", legend=groupNames, pch=15, col=ourColors)
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


#Make adapters and subreads per CLR plots
if (plotsDesired == "a") {
    ##Make frequency plots of subreads/CLR
    if (groupsDesired == "a") {
        for(i in seq(numPairs)){
            plotName = sprintf("%s.subsPerClr.pdf", pairNames[i])
            pdf(plotName); par(lwd=1.5, mgp=c(2.2,1,0))
            
            #Make "histogram" manually as a line plot to avoid binning 0 and 1 together
            zero = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==0])
            one = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==1])
            two = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==2])
            three = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==3])
            four = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==4])
            five = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]==5])
            sixPlus = length(numSubsPerClrMatrix[i,][numSubsPerClrMatrix[i,]>5])

            x = c(0,1,2,3,4,5,6)
            y = c(zero, one, two, three, four, five, sixPlus)/1000

            plot(x,y, type="b", pch=16, main="Subreads per CLR Frequencies", xlab="Subreads per CLR", ylab="Frequency / 1000")
            invisible(dev.off())
        }
    }

    ##Make frequency plots of adapters/CLR
    if (groupsDesired == "a") {
        for(i in seq(numPairs)){
            plotName = sprintf("%s.adsPerClr.pdf", pairNames[i])
            pdf(plotName); par(lwd=1.5)

            #Make "histogram" manually as a line plot to avoid binning 0 and 1 together                   
            zero = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==0])                            
            one = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==1])                             
            two = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==2])                             
            three = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==3])                           
            four = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==4])                            
            five = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]==5])                            
            sixPlus = length(numAdsPerClrMatrix[i,][numAdsPerClrMatrix[i,]>5])                          

            x = c(0,1,2,3,4,5,6)                                                                                    
            y = c(zero, one, two, three, four, five, sixPlus)/1000                                        

            plot(x,y, type="b", pch=16, main="Adapters per CLR Frequencies", xlab="Adapters per CLR", ylab="Frequency / 1000")
            invisible(dev.off())
        }
    }
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

    ##Make boxplots of subedClr sizes with N50 shown 
    plotName = sprintf("%s/subedClrSizesBoxplots.pdf",outFold)
    pdf(plotName)
    par(omi=c(1.2,0,0,0), mgp=c(2.55,1,0))
    boxplot(t(subedClrReadLensMatrix)/1000, names=pairNames, ylab="Read Length (kb)", main="Boxplots of SubedCLR Sizes with N50", las=2)
    points(subedClrN50s/1000, pch=18, col="#0276FD", cex=2)
    invisible(dev.off())
}





