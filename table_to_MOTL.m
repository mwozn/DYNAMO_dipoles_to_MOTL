# USAGE: 1. Activate DYNAMO in MATLAB
#        2. Use use these commands to convert table to MOTL

wstable = dread('data/crop.tbl');
wsmotl = dynamo__table2motl(wstable);
dwrite(wsmotl,'allmotl_01.em');