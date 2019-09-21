"""
This script is designed to generate statistics from read lengths for both
subreads and scraps and output them in this format with one stat per line: 
clrTotalBases, clrMeanReadLen, clrMedianReadLen, clrN50, clrL50, 
subsTotalBases, subsMeanReadLen, subsMedianReadLen, subsN50, subsL50,
subedClrTotalBases, subedClrMeanReadLen, subedClrMedianReadLen, subedClrN50, 
subedClrL50, longestSubTotalBases, longestSubMeanReadLen, 
longestSubMedianReadLen, longestSubN50, longestSubL50, readsRemoved.  Also 
outputs all read lengths with one data point per line for subreads, clr, and 
clr's containing subreads.  This version expects Python 3
Created By David E. Hufnagel on Mon Jul 23, 2018
Updated on July 30, 2018 to 1) calculate all stats for longest subreads, 2) 
make a an output of format: 
'hole#   #subreads   #adapters'
for all CLRs with subreads, and 3) Changes the script so that it expects a 
3-column scraps input file
Updated on Aug 13, 2018 to take in and use 'groupsDesired'.
"""
import sys

groupsDesired = sys.argv[9]                  #a or b (stands for 'all' or 'basic')
scrapsInp = open(sys.argv[1])                #m#####_######_######.scraps.seqNamesPlus
subsInp = open(sys.argv[2])                  #m#####_######_######.subreads.seqNames
outStat = open(sys.argv[3], "w")             #m#####_######_######.SMRTcellStats_wScrapsA.txt or m#####_######_######.SMRTcellStats_wScrapsB.txt
outReadLensSub = open(sys.argv[4], "w")      #m#####_######_######.readLens.sub.txt
if groupsDesired == "a":
    outReadLensClr = open(sys.argv[5], "w")  #m#####_######_######.readLens.clr.txt
outReadLensSubedClr = open(sys.argv[6], "w") #m#####_######_######.readLens.subedClr.txt
outReadLensLongSub = open(sys.argv[7], "w")  #m#####_######_######.readLens.longSub.txt
holeData = open(sys.argv[8], "w")            #m#####_######_######.clrStats.txt




def SaveIntoDict(key, val, dictX):
    if key not in dictX:
        dictX[key] = [val]
    else:
        dictX[key].append(val)
        
def GetBaseData(coords):
    readLen = 0
    for coord in coords:
        start = int(coord.split("_")[0])
        stop = int(coord.split("_")[1])
        length = stop - start
        readLen += length
                        
    return(readLen)
    
def Mean(listx):
    mn = float(sum(listx)) / float(len(listx))
    return round(mn,0)
    
def Median(listx):
    sortedLst = sorted(listx)
    if len(sortedLst) % 2: #true when the number of items is odd
        med = sortedLst[len(sortedLst)//2] 
    else:
        first = sortedLst[(len(sortedLst)//2)-1]
        second = sortedLst[len(sortedLst)//2]
        med = Mean([first, second])
        
    return(int(round(med,0)))
    
def GetNvals(readLens):
    sortedRLs = sorted(readLens, reverse=True)
    total = sum(sortedRLs)
    l50 = 0
    tempSum = 0
    for rl in sortedRLs:
        tempSum += rl
        l50 += 1
        
        if tempSum >= float(total) / 2.0:
            n50 = rl
            break
    
    return(n50, l50)
    
    
         
        
#Go through scrapsInp and make a dict of key: hole  val: (coords, szData, scData)
#  and a list of all holes
scrapsDict = {}
holes = []
for line in scrapsInp:
    lineLst = line.strip().split("\t")
    hole = int(lineLst[0].strip().split("/")[1])
    coords = lineLst[0].strip().split("/")[2]
    szData = lineLst[2].strip().strip("sz:")
    scData = lineLst[1].strip().strip("sc:")
    val = (coords, szData, scData)
    SaveIntoDict(hole, val, scrapsDict)
    holes.append(hole)


#Go through subsInp and make a dict of key: hole  val: coords
subsDict = {}
for line in subsInp:
    hole = int(line.strip().split("/")[1])
    coords = line.strip().split("/")[2]
    SaveIntoDict(hole, coords, subsDict)
    holes.append(hole)


#Keep only unique holes and sort the holes list
holes = list(set(holes))
holes.sort()


#Write the title for holeData
#'hole#   #subreads   allSubreadCoords   longestSubreadCoords   #adapters'
newLine = "%s\t%s\t%s\n" % ("ZMW", "numSubreads", "numAdapters")
holeData.write(newLine)


#Go through hole list and collect data from dicts
if groupsDesired == "a":
    clrReadLens = []
subReadLens = []; subedClrReadLens = []; longestSubReadLens = []
removedReads = 0
for hole in holes:
    #gather data from dictionaries
    coords = []
    numAdapters = 0
    subCoords = []
    goodHole = False  #whether this hole has any useable reads at all
    subsHole = False  #whether this hole has any subreads
    if hole in scrapsDict:
        for read in scrapsDict[hole]:
            coord = read[0]
            sz = read[1]
            sc = read[2]
            if sz == "A:N":
                coords.append(coord)
                goodHole = True
            else:
                removedReads += 1
                
            if sc == "A:A":
                numAdapters += 1
                
    if hole in subsDict:
        goodHole = True; subsHole = True
        for coord in subsDict[hole]:
            coords.append(coord)
            subCoords.append(coord)
                      
    #Collect read lengths  
    if goodHole:
        readLen = 0
        for coord in coords:
            start = int(coord.split("_")[0]); stop = int(coord.split("_")[1])
            length = stop - start
            readLen += length

        #output to holeData for non-subedClrs
        if not subsHole:
            newLine = "%s\t%s\t%s\n" % (hole, "0", numAdapters)
            holeData.write(newLine) 
        
        if groupsDesired == "a":
            clrReadLens.append(readLen)            
        
    if subsHole:
        if goodHole:
            #add to subedClrReadLens
            readLen = 0
            for coord in coords:
                start = int(coord.split("_")[0]); stop = int(coord.split("_")[1])
                length = stop - start
                readLen += length                             
            subedClrReadLens.append(readLen)
    
        #add to subReadLens and longestSubReadLens
        longestReadLen = 0
        for coord in subCoords:
            start = int(coord.split("_")[0]); stop = int(coord.split("_")[1])
            length = stop - start
            subReadLens.append(length)
            if length > longestReadLen:
                longestReadLen = length
        else:
            longestSubReadLens.append(longestReadLen)
            
            #output to holeData for subedClrs
            newLine = "%s\t%s\t%s\n" % (hole, len(subCoords), numAdapters)
            holeData.write(newLine)   
            
            
#Calculate all stats from read length lists and output data
###first calculate total, mean, and median read lengths
if groupsDesired == "a":
    clrTotal = sum(clrReadLens)
    longSubTotal = sum(longestSubReadLens)
    
    clrMean = Mean(clrReadLens)
    longSubMean = Mean(longestSubReadLens)
    
    clrMedian = Median(clrReadLens)
    longSubMedian = Median(longestSubReadLens)    
    
subTotal = sum(subReadLens)  
subedClrTotal = sum(subedClrReadLens)

subMean = Mean(subReadLens)
subedClrMean = Mean(subedClrReadLens)

subMedian = Median(subReadLens)
subedClrMedian = Median(subedClrReadLens)

###then calculate N50 and L50
if groupsDesired == "a":
    n50clr, l50clr = GetNvals(clrReadLens)
    n50longSub, l50longSub = GetNvals(longestSubReadLens)
   
n50sub, l50sub = GetNvals(subReadLens)
n50subedClr, l50subedClr = GetNvals(subedClrReadLens)


#Output all read lengths in 4 seperate files (one for subreads, one for clr, 
#  one for subed clr, and one for longest subreads)
if groupsDesired == "a":
    for length in clrReadLens:
        newLine = "%s\n" % (length)
        outReadLensClr.write(newLine)  
        
for length in longestSubReadLens:
    newLine = "%s\n" % (length)
    outReadLensLongSub.write(newLine)
    
for length in subReadLens:
    newLine = "%s\n" % (length)
    outReadLensSub.write(newLine)
    
for length in subedClrReadLens:
    newLine = "%s\n" % (length)
    outReadLensSubedClr.write(newLine)


#Output other stats in stats file
if groupsDesired == "a":
    newLine = "clrTotalBases\tclrMeanReadLen\tclrMedianReadLen\tclrN50\tclrL50\t\
    subsTotalBases\tsubsMeanReadLen\tsubsMedianReadLen\tsubsN50\tsubsL50\t\
    subedClrTotalBases\tsubedClrMeanReadLen\tsubedClrMedianReadLen\tsubedClrN50\t\
    subedClrL50\tlongestSubTotalBases\tlongestSubMeanReadLen\t\
    longestSubMedianReadLen\tlongestSubN50\tlongestSubL50\treadsRemoved\n"
elif groupsDesired == "b":
    newLine = "subedClrTotalBases\tsubedClrMeanReadLen\tsubedClrMedianReadLen\t\
    subedClrN50\tsubedClrL50\tsubsTotalBases\tsubsMeanReadLen\tsubsMedianReadLen\t\
    subsN50\tsubsL50\treadsRemoved\n"  
outStat.write(newLine)

if groupsDesired == "a":
    newLine = "%s\t%.0f\t%s\t%s\t%s\t%s\t%.0f\t%s\t%s\t%s\t%s\t%.0f\t%s\t%s\t%s\t\
    %s\t%.0f\t%s\t%s\t%s\t%s\n" % (clrTotal,clrMean,clrMedian,n50clr,l50clr,subTotal,\
    subMean,subMedian,n50sub,l50sub,subedClrTotal,subedClrMean,subedClrMedian,\
    n50subedClr,l50subedClr,longSubTotal,longSubMean,longSubMedian,n50longSub,\
    l50longSub, removedReads)
elif groupsDesired == "b":
    newLine = "%s\t%.0f\t%s\t%s\t%s\t%s\t%.0f\t%s\t%s\t%s\t%s\n" % (subedClrTotal,\
    subedClrMean,subedClrMedian,n50subedClr,l50subedClr,subTotal,subMean,\
    subMedian,n50sub,l50sub, removedReads) 
outStat.write(newLine)




scrapsInp.close()
subsInp.close()
outStat.close()
outReadLensSub.close()
if groupsDesired == "a":
    outReadLensClr.close()
outReadLensLongSub.close()
outReadLensSubedClr.close()
holeData.close()
