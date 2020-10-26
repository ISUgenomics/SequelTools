#!/usr/bin/python
"""
This script is designed to filter SAM PacBio Sequel data files by minimum
CLR length and/or having at least one complete pass of the DNA molecule past 
the polymerase and/or normal adapters for scraps.  This script is a part of 
SequelTools.
Created By David E. Hufnagel on Fri Sep  6, 2019
"""

import sys

inpSubs = open(sys.argv[1])
inpScraps = open(sys.argv[2])
clrMinLen = sys.argv[3]            #true or false.  Whether or not to filter by CLR minimum Length
numPasses = sys.argv[4]            #true or false.  Whether or not to filter by number of passes
normScraps = sys.argv[5]           #true or false.  Whether or not to filter by normal scraps files
clrMinLenThresh = int(sys.argv[6]) #The minimum length in bp for CLRs
outSubsName = "%s_flt.subreads.sam" % (sys.argv[1].split(".subreads.sam")[0])
outSubs = open(outSubsName, "w")
outScrapsName = "%s_flt.scraps.sam" % (sys.argv[2].split(".scraps.sam")[0])
outScraps = open(outScrapsName, "w")


#Convert string booleans to true booleans
if clrMinLen == "true":
    clrMinLen = True
elif clrMinLen == "false":
    clrMinLen = False
else:
    print("ERROR!: improper clrMinLen input")
    
if numPasses == "true":
    numPasses = True
elif numPasses == "false":
    numPasses = False
else:
    print("ERROR!: improper numPasses input")
    
if normScraps == "true":
    normScraps = True
elif normScraps == "false":
    normScraps = False
else:
    print("ERROR!: improper normScraps input")



def SaveIntoDict(key, val, dictX):
    if key not in dictX:
        dictX[key] = [val]
    else:
        dictX[key].append(val)
        
        
        
#Go through scrapsInp and make a dict of key: CLRname  val: coords
#  and a list of all CLRnames
scrapsDict = {}
CLRnames = []
for line in inpScraps:
    if not line.startswith("@"):
        lineLst = line.strip().split("\t")
        CLRname = lineLst[0].strip().split("/")[1]
        coords = lineLst[0].strip().split("/")[2]
        SaveIntoDict(CLRname, coords, scrapsDict)
        CLRnames.append(CLRname)


#Go through subsInp and make a dict of key: CLRname  val: coords
subsDict = {}
for line in inpSubs:
    if not line.startswith("@"):
        lineLst = line.strip().split("\t")
        CLRname = lineLst[0].strip().split("/")[1]
        coords = lineLst[0].strip().split("/")[2]
        SaveIntoDict(CLRname, coords, subsDict)
        CLRnames.append(CLRname)


#Keep only unique CLRs and sort the CLRnames list
CLRnames = list(set(CLRnames))
CLRnames.sort()


#If filtering by CLR length go through CLRname list, collect coord data from 
#  dicts, merge CLRs, calculate CLR length, and make a bad list of too short CLRs
badLst = []
if clrMinLen:
    clrReadLens = []
    for CLRname in CLRnames:
        #Gather subreads and scraps coordinates
        allCoords = []
        subCoords = "NA"
        if CLRname in subsDict:
            subCoords = subsDict[CLRname]
            for coord in subCoords:
                allCoords.append(coord)
        
        scrapsCoords = "NA"
        if CLRname in scrapsDict:
            scrapsCoords = scrapsDict[CLRname]
            for coord in scrapsCoords:
                allCoords.append(coord)
                
                
        #Go through coordinates and make a list of tuples of (coord, start/stop)
        tupList = []
        for coordPair in allCoords:
            start = int(coordPair.split("_")[0])
            stop = int(coordPair.split("_")[1])
            tupA = (start, "start")
            tupB = (stop, "stop")
            tupList.append(tupA)
            tupList.append(tupB)
            

        #Sort the tuple list, and where coords are identical merge the tuples
        #  like so [(3, start),(5,stop),(5, start),(7, stop)] --> 
        #  [(3, [start]),(5, [stop, start]),(7, [stop])]
        tupList.sort()
        lastCoord = -9
        tupList2 = []
        for tup in tupList:
            coord = tup[0]
            if coord == lastCoord:
                tupList2[-1][1].append(tup[1])
            else:
                newTup = (coord,[tup[1],])
                tupList2.append(newTup)
                
            lastCoord = coord
                        
            
        #Go through tuple List, merge CLRs, and calculate merged CLR length
        startScore = 0 #The number starts - stops
        CLRlen = 0
        CLRcoords = []
        for tup in tupList2: 
            for state in tup[1]:
                if state == "start":
                    startScore += 1
                elif state == "stop":
                    startScore -= 1
                else:
                    print("ERROR: tuple parsing failure!")
                    sys.exit()
               
            #When the startScore returns to 0 a CLR has been found, calculate CLR length
            if not startScore:
                CLRcoords.append(tup[0])
                Chunklen = max(CLRcoords)-min(CLRcoords)
                CLRlen += Chunklen
                CLRcoords = []
            else:  #Otherwise add to CLRcoords
                CLRcoords.append(tup[0])
            
        if CLRlen < clrMinLenThresh:
            badLst.append(CLRname)


#Go through subsInp and output lines that do not contain CLRnames in the bad list
inpSubs.seek(0)
for line in inpSubs:
    if not line.startswith("@"):
        lineLst = line.split()
        CLRname = lineLst[0].strip().split("/")[1]
        if CLRname not in badLst:
            outSubs.write(line)
    else:
        outSubs.write(line)


#Go through scrapsInp and output lines that pass all chosen thresholds
inpScraps.seek(0)
for line in inpScraps:
    if not line.startswith("@"):
        lineLst = line.split()
        CLRname = lineLst[0].strip().split("/")[1]
        if CLRname not in badLst:
            szData = lineLst[21]
            scData = lineLst[20]
            npData = lineLst[12]
            if (not numPasses) and (not normScraps): #No num passes or norm filt
                outScraps.write(line)                
            elif numPasses and normScraps:           #Both num passes and norm filt
                if szData == "sz:A:N" and scData == "sc:A:L" and npData == "np:i:1":
                    outScraps.write(line)
            elif numPasses:                          #Just num passes filt
                if npData == "np:i:1":
                    outScraps.write(line)
            elif normScraps:                         #Just norm filt
                if szData == "sz:A:N" and scData == "sc:A:L":
                    outScraps.write(line)
            else:
                print("ERROR: numPasses andnormScraps failure!")
                sys.exit()
    else:
        outScraps.write(line)

                


inpSubs.close()
inpScraps.close()
outSubs.close()
outScraps.close()
