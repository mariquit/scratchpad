#!/bin/sh

# change to /usr/local/bin if you want
TGTDIR=~/bin

echo Creating symlinks to bin ...
ln -fs $PWD/aws-check.sh $TGTDIR/aws-check

echo Fixing exec rights ...
chmod +x $TGTDIR/aws-check

echo Done.
