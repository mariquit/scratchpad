#!/usr/bin/env python2.7

import csv
import sys
import re

try:
  if (sys.argv[1] == '-'):
    f = sys.stdin.read().splitlines()
  else:
    filename = sys.argv[1]
    f = open(filename, 'r')
  csv = csv.reader(f)
  data = list(csv)
  for row in data:
    r = row[5-1]
    t = row[19-1]
    
    # remove leading text from description
    r = re.sub('\$.* per On Demand ','',r)
    r = re.sub('USD .* per ','',r)
    
    # remove instance name from description
    r = re.sub('\),',')',r)
    r = re.sub(' '+t+' .*','',r)

    print "%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s" % ( row[1-1],row[2-1],row[4-1],r,row[6-1],row[9-1],row[10-1],row[13-1],row[17-1],row[19-1],row[20-1],row[36-1],row[38-1],row[39-1],row[52-1],row[68-1])
except Exception, e:
  print "Error reading from file:"
