#!/bin/sh

function dbexec {
  echo "Executing \033[33m$1\033[0m ..."
  psql -d dbr -f $1 -q
}

echo "\033[32m$PWD\033[0m"
dbexec 1.lookup.sql
[ -e "2.lookup.sql.do_not_push" ] && dbexec 2.lookup.sql.do_not_push
dbexec 2.ec2.sql
dbexec 3.rds.sql
dbexec 4.services.sql
