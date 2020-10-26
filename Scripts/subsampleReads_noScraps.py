#!/usr/bin/python
"""
This script is designed to take a SAM format Pacbio Sequel subreads sequence 
files, and potentially scraps files, and sumsample the reads in up to two
possible ways: by longest subreads and/or by random CLR selection, and output 
the result in SAM format.  This script is a part of SequelTools and assumes
the lack of scraps files.
Created By David E. Hufnagel on Thu Sep  13, 2019
"""

import sys, random

inp = open(sys.argv[1])
outName = "%s_spl.subreads.sam" % (sys.argv[1].split(".subreads.sam")[0])
out = open(outName, "w")
subSampLongSub = sys.argv[2]     #whether to subsample longest subreads  (true or false)
subSampCLRrand = sys.argv[3]     #whether to subsample by random CLR (true or false)
subSampCLRrandProp = float(sys.argv[4]) #the proportion of CLRs to retain for rondomly subsampling CLRs

#Convert subSampLongSub and subSampCLRrand to true booleans
if subSampLongSub == "true":
    subSampLongSub = True
elif subSampLongSub == "false":
    subSampLongSub = False
else:
    print("ERROR: Improper value for subSampLongSub")
    sys.exit()
    
if subSampCLRrand == "true":
    subSampCLRrand = True
elif subSampCLRrand == "false":
    subSampCLRrand = False
else:
    print("ERROR: Improper value for subSampCLRrand")
    sys.exit()
    


def SaveIntoDict(key, val, dictX):
    if key not in dictX:
        dictX[key] = [val]
    else:
        dictX[key].append(val)
        
#Finds the maximum numeric element in a list.  When there is a tie, the winner
#  is chosen randomly.  The index, rather than the value, is returned.
def Max(listx):
    #determine the max item the simple way
    top = max(listx)

    #look for duplicates
    inds = []
    cnt = 0
    for item in listx:
        if item == top:
            inds.append(cnt)
        cnt += 1
        
    #If duplicates are found, select one randomly and return it's index
    return(random.choice(inds))                
        
        
        
#If subsampling longest subreads, go through input file and make a dict of 
#  key: CLRid val: list of tuples of (coord, seqName) for each sequence.  If
#  also subsampling CLRs randomly also make a list of CLRids
if subSampCLRrand:
    CLRids = []
if subSampLongSub:
    coordDict = {}
    for line in inp:
        if not line.startswith("@"):
            seqName = line.split()[0]
            CLRid = seqName.split("/")[1]
            coord = seqName.split("/")[2]
            val = (coord, seqName)
            SaveIntoDict(CLRid, val, coordDict)
            
            if subSampCLRrand:
                CLRids.append(CLRid)
                
                
#If subsampling by CLRs randomly alone go through inpSubs to make a list of 
#   CLRids
elif subSampCLRrand:        
    for line in inp:
        if not line.startswith("@"):
            seqName = line.split()[0]
            CLRid = seqName.split("/")[1]
            CLRids.append(CLRid)    
            

#If subsampling subreads, go through coordDict and make a list of the sequence 
#  names associated with the longest subreads per CLR.
if subSampLongSub:
    longestSubs = []
    for CLRid, val in coordDict.items():
        lengths = []
        names = []
        for read in val:
            start = int(read[0].split("_")[0])
            stop = int(read[0].split("_")[1])
            name = read[1]
            length = stop-start+1
            lengths.append(length)
            names.append(name)
    
        longestInd = Max(lengths)
        longestSub = names[longestInd]
        longestSubs.append(longestSub)
        
        
#If subsampling by CLRs randomly select CLRids to keep from the CLRid list
if subSampCLRrand: 
    newNumCLRs = int(len(CLRids) * subSampCLRrandProp)
    newCLRids = random.sample(CLRids, newNumCLRs)


#Go through input files again and output lines associated with longest subreads
#  and/or subsampled reads
inp.seek(0)
for line in inp:
    if not line.startswith("@"):
        seqName = line.split()[0]
        CLRid = seqName.split("/")[1]
        if subSampLongSub:
            if subSampCLRrand: 
                if seqName in longestSubs and CLRid in newCLRids:
                    out.write(line)
            else:
                if seqName in longestSubs:
                    out.write(line)
        elif subSampCLRrand: 
            if CLRid in newCLRids:
                out.write(line)
        else:
            out.write(line)
    else:
        out.write(line)
        





inp.close()
out.close()
