#!/bin/sh

# change to /usr/local/bin if you want
TGTDIR=~/bin

echo Creating symlinks to bin ...
ln -fs $PWD/aws-ri-pricing.sh $TGTDIR/aws-ri-pricing
ln -fs $PWD/csvfix-dbr.py $TGTDIR/csvfix-dbr
ln -fs $PWD/csvfix-pricing-ec2.py $TGTDIR/csvfix-pricing-ec2

echo Fixing exec rights ...
chmod +x $TGTDIR/aws-ri-pricing
chmod +x $TGTDIR/csvfix-dbr
chmod +x $TGTDIR/csvfix-pricing-ec2

echo Done.
