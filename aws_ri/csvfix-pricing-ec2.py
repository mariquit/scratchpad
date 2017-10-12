#!/usr/bin/env python2.7

import csv
import sys
import re

from printf import printf

a = [1,2,4,5,6,9,10,13,17,19,20,36,38,39,52,68]

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
    r = re.sub('\$.* per On Demand ', '', r)
    r = re.sub('USD .* per ', '', r)

    # remove instance name from description
    r = re.sub('\),', ')', r)
    r = re.sub(' ' + t + ' .*', '', r)

    for n in range(len(row)):
      if (n+1) in a:
        if (n+1) == 68:
            print "%s" % (row[n])
        else:
          if (n+1) == 5:
              printf("%s|", (r))
          else:
              printf("%s|", (row[n]))
except Exception, e:
  print "Error reading from file:"
