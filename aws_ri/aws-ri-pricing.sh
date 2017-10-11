#!/bin/sh

GREP_OPTS="-e Singapore -e Oregon -e Virginia -e Ireland"

EC2_SRC=/tmp/pricing.ec2
EC2_CSV=/tmp/ec2.csv
EC2_HEADER=$EC2_SRC.header.csv

[ -e "$EC2_SRC" ] || echo "\033[33mPulling EC2 pricing ...\033[0m"
[ -e "$EC2_SRC" ] || wget --quiet --show-progress https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.csv -O $EC2_SRC

[ -e "$EC2_HEADER" ] || echo "\033[33mExtracting header ...\033[0m"
[ -e "$EC2_HEADER" ] || cat $EC2_SRC | head -6 | tail -1 > $EC2_HEADER

[ -e "$EC2_CSV" ] || echo "\033[33mTrimming EC2 price list ...\033[0m"
[ -e "$EC2_CSV" ] || cat $EC2_SRC | grep -e "Compute Instance" -e "Product Family" | grep $GREP_OPTS -e "serviceCode" | grep -v -e "3yr" -e " [GM]bps per" | csvfix-pricing-ec2 - | tee $EC2_CSV | wc -l

#[ -e "/tmp/pricing.rds" ] || echo Pulling RDS pricing ...
#[ -e "/tmp/pricing.rds" ] || wget https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonRDS/current/index.csv -O /tmp/pricing.rds
#[ -e "/tmp/rds.csv" ] || echo Trimming RDS price list ...
#[ -e "/tmp/rds.csv" ] || cat $EC2_SRC | grep $GREP_OPTS -e "serviceCode" | grep -v -e "3yr" > /tmp/rds.csv

echo "\033[32mDone.\033[0m"