# Use this python3 script to create sym links to files at paths in filesCropSubTOM.csv
# ####.rec ordered by subTOM index (ordered 0001-#### in ascending order of Dynamo index)
# Michael Wozny 2020

import numpy as np
import os, shutil, csv

# path to filesCropSubTOM.csv
srcFile = 'filesCropSubTOM.csv'
srcDir = os.getcwd()

# read in output.txt as dataList array, keep header separate
fileObj = open(srcFile)
dataList= []
header = fileObj.readline().splitlines()

# remove \t from header and fileObj
for k in header:
    header = k.split('\t')

for line in fileObj:
    data = line.split('\t')
    dataList.append(data)

# dataList as array, strip \n
dataList = np.asarray(dataList)
dataList = np.char.strip(dataList)

# create sym link named by indexSubTOM to volumePath
for k in range(len(dataList)):
    volumePath = dataList[k,0]
    indexSubTOM = dataList[k,6]
    tomoSymLnk = str(indexSubTOM).zfill(4) + '.rec'
    # skip any indices == 0, these were not used for cropping
    if int(indexSubTOM) == 0:
        continue
    tomoSymLnk = srcDir + '/' + tomoSymLnk
    os.symlink(volumePath,tomoSymLnk)