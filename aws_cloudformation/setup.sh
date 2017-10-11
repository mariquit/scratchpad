#!/bin/sh

# change to /usr/local/bin if you want
TGTDIR=~/bin

echo Creating symlinks to bin ...
ln -fs $PWD/cfn-visualize.sh $TGTDIR/cfn-visualize
ln -fs $PWD/cfviz.py $TGTDIR/cfviz

echo Fixing exec rights ...
chmod +x $TGTDIR/cfn-visualize
chmod +x $TGTDIR/cfviz

echo Done.
