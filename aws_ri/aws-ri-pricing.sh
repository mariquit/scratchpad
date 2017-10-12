#!/bin/sh

GREP_OPTS="-e Singapore -e Oregon -e Virginia -e Ireland"

EC2_SRC=/tmp/pricing.ec2
EC2_CSV=/tmp/ec2.csv
EC2_HEADER=$EC2_SRC.header.csv

RDS_SRC=/tmp/pricing.rds
RDS_CSV=/tmp/rds.csv
RDS_HEADER=$RDS_SRC.header.csv

[ -e "$EC2_SRC" ] || echo "\033[33mPulling \033[31mEC2\033[0m pricing ..."
[ -e "$EC2_SRC" ] || wget --quiet --show-progress https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.csv -O $EC2_SRC
[ -e "$EC2_HEADER" ] || echo "\033[33mExtracting\033[0m header ..."
[ -e "$EC2_HEADER" ] || cat $EC2_SRC | head -6 | tail -1 > $EC2_HEADER
[ -e "$EC2_CSV" ] || echo "\033[33mTrimming\033[0m price list ..."
[ -e "$EC2_CSV" ] || cat $EC2_SRC | grep -e "Compute Instance" -e "Product Family" | grep $GREP_OPTS -e "serviceCode" | grep -v -e "3yr" -e " [GM]bps per" | csvfix-pricing-ec2 - | tee $EC2_CSV | wc -l

[ -e "$RDS_SRC" ] || echo "\033[33mPulling \033[31mRDS\033[0m pricing ..."
[ -e "$RDS_SRC" ] || wget --quiet --show-progress https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonRDS/current/index.csv -O $RDS_SRC
[ -e "$RDS_HEADER" ] || echo "\033[33mExtracting\033[0m header ..."
[ -e "$RDS_HEADER" ] || cat $RDS_SRC | head -6 | tail -1 > $RDS_HEADER
[ -e "$RDS_CSV" ] || echo "\033[33mTrimming\033[0m price list ..."
[ -e "$RDS_CSV" ] || cat $RDS_SRC | grep $GREP_OPTS -e "serviceCode" | grep -v -e "3yr" -e " per [GMT]B " | csvfix-pricing-rds - | tee $RDS_CSV | wc -l

echo "\033[32mDone.\033[0m"
