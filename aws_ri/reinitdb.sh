#!/bin/sh

function dbexec {
  echo "Executing \033[33m$1\033[0m ..."
  psql -d dbr -f $1 -q
}

if [ -e "../aws_billing/reinitdb.sh" ] 
then
  cd ../aws_billing
  ./reinitdb.sh
  cd - >/dev/null
fi

echo "\033[32m$PWD\033[0m"
dbexec 5.pricing.ec2.sql
dbexec 5.pricing.rds.sql
dbexec 6.ri_analysis.sql
