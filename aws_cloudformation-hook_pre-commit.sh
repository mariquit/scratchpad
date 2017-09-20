#!/bin/bash
#

# A git hook script to find and fix trailing whitespace
# in your commits. Bypass it with the --no-verify option
# to git-commit
#
# usage: make a soft link to this file: 
#     ln -s ~/git/scratchpad/aws_cloudformation-hook_pre-commit.sh ~/some_project/.git/hooks/pre-commit

# list of file extensions to be checked
EXT="template"
CNT=0


# run CFN validator for each of the files
for f in `git diff --check --cached | sed '/^[+-]/d' | awk -F : '{print $1}'`
do
  ext=`echo "$f" | awk -F . '{print $NF}'`
  for i in $EXT
  do
    if [ "$i" != "$ext" ]
    then
      echo Skipping $f
    else
      echo -n "Parsing $f ... "
      aws cloudformation validate-template --template-body file://$f >/dev/null 2>&1
      if [ $? -eq 0 ]
      then
        echo -e "\033[32mOK\033[0m"
      else
        echo -e "\033[1;31mFAIL\033[0m" 
        (( CNT++ ))
      fi
    fi
  done
done

if [ $CNT -gt 0 ]
then
  exit 1
else
  exit 0
fi
