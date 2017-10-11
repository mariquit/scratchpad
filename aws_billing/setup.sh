#!/bin/sh

# change to /usr/local/bin if you want
TGTDIR=~/bin

echo Creating symlinks to bin ...
ln -fs $PWD/csvfix-dbr.py $TGTDIR/csvfix-dbr

echo Fixing exec rights ...
chmod +x $TGTDIR/csvfix-dbr

echo Done.
