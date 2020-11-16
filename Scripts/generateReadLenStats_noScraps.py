#!/usr/bin/env python
"""
This script is designed to generate statistics from read lengths for subreads  
and output them in this format with one stat per line: subsTotalBases, 
subsMeanReadLen, subsMedianReadLen, subsN50, subsL50, longestSubTotalBases, 
longestSubMeanReadLen, longestSubMedianReadLen, longestSubN50, longestSubL50.  
Also outputs all read lengths with one data point per line for subreads.
This version expects Python 3
Created By David E. Hufnagel on Mon Nov 24, 2018
"""
import sys

subsInp = open(sys.argv[1])                  #m#####_######_######.subreads.seqNames
outStat = open(sys.argv[2], "w")             #m#####_######_######.SMRTcellStats_noScraps.txt
outReadLensSub = open(sys.argv[3], "w")      #m#####_######_######.readLens.sub.txt
outReadLensLongSub = open(sys.argv[4], "w")  #m#####_######_######.readLens.longSub.txt



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



#Go through subsInp and make a dict of key: hole  val: coords
subsDict = {}
holes = []
for line in subsInp:
    hole = int(line.strip().split("/")[1])
    coords = line.strip().split("/")[2]
    SaveIntoDict(hole, coords, subsDict)
    holes.append(hole)


#Keep only unique holes and sort the holes list
holes = list(set(holes))
holes.sort()

#Go through hole list and collect data from dicts
subReadLens = []; longestSubReadLens = []
for hole in holes:
    #gather data from dictionaries
    coords = []
    for coord in subsDict[hole]:
        coords.append(coord)
                      
    #Collect read lengths  
    readLen = 0
    longestReadLen = 0
    for coord in coords:
        start = int(coord.split("_")[0]); stop = int(coord.split("_")[1])
        length = stop - start
        readLen += length
        subReadLens.append(length)
        if length > longestReadLen:
            longestReadLen = length  
                   
    longestSubReadLens.append(longestReadLen)
            
            
#Calculate all stats from read length lists and output data
###first calculate total, mean, and median read lengths
subTotal = sum(subReadLens)  
subMean = Mean(subReadLens)
subMedian = Median(subReadLens)

longSubTotal = sum(longestSubReadLens)
longSubMean = Mean(longestSubReadLens)
longSubMedian = Median(longestSubReadLens)    
    

###then calculate N50 and L50
n50sub, l50sub = GetNvals(subReadLens)
n50longSub, l50longSub = GetNvals(longestSubReadLens)


#Output all read lengths in 2 seperate files (one for subreads and one for longest subreads)    
for length in subReadLens:
    newLine = "%s\n" % (length)
    outReadLensSub.write(newLine)
    
for length in longestSubReadLens:
    newLine = "%s\n" % (length)
    outReadLensLongSub.write(newLine)
    

#Output other stats in stats file
newLine = "subsTotalBases\tsubsMeanReadLen\tsubsMedianReadLen\tsubsN50\t\
subsL50\tlongestSubTotalBases\tlongestSubMeanReadLen\t\
longestSubMedianReadLen\tlongestSubN50\tlongestSubL50\n" 
outStat.write(newLine)

newLine = "%s\t%.0f\t%s\t%s\t%s\t%s\t%.0f\t%s\t%s\t%s\n" % \
(subTotal,subMean,subMedian,n50sub,l50sub,longSubTotal,longSubMean,\
longSubMedian,n50longSub,l50longSub)
outStat.write(newLine)




subsInp.close()
outStat.close()
outReadLensSub.close()
outReadLensLongSub.close()
