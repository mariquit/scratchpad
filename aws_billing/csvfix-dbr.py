#!/usr/bin/env python2.7

import csv
import sys

from printf import printf
    
try:
  if (sys.argv[1] == '-'):
    f = sys.stdin.read().splitlines()
  else:
    filename = sys.argv[1]
    f = open(filename, 'r')
  csv = csv.reader(f)
  data = list(csv)
  for row in data:
    for n in range(len(row)):
      if n < (len(row)-1):
        printf("%s|", (row[n]))
      else:
        print "%s" % (row[n])
except Exception, e:
  print "Error reading from file:"
