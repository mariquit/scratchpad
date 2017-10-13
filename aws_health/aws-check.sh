#!/bin/bash

BADSTACKS=""
STOPPEDSTACKS=""
[ "$1" == "-c" ] && SHOWCLEANUP=1

echo "Finding misconfigured AWS assets.  This might take a few minutes ..."

for region in `aws ec2 describe-regions --output text | cut -f3`
do
  echo -e "Region:\033[33m $region \033[0m"
  for STACK in $(aws cloudformation list-stacks --region $region --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --max-items 1000 | jq -r '.StackSummaries[].StackName')
  do
          INSTANCE=$(aws cloudformation describe-stack-resources --region $region --stack-name $STACK | jq -r '.StackResources[] | select (.ResourceType=="AWS::EC2::Instance")|.PhysicalResourceId')
          if [[ ! -z $INSTANCE  ]]; then
                  STATUS=$(aws ec2 describe-instance-status --region $region --include-all-instances --instance-ids $INSTANCE 2> /dev/null | jq -r '.InstanceStatuses[].InstanceState.Name') 
                  if [[ -z $STATUS  ]]; then
                          BADSTACKS="${BADSTACKS:+$BADSTACKS }$STACK"
                  elif [[ ${STATUS} == "stopped" ]]; then
                          STOPPEDSTACKS="${STOPPEDSTACKS:+$STOPPEDSTACKS }$STACK"
              fi
          fi
  done

  echo -n -e "\033[32m  - CFN with missing EC2:\033[0m"
  [ -n "$SHOWCLEANUP" ] && echo -e "\033[31m(aws cloudformation delete-stack --stack-name)\033[0m"
  [ -n "$SHOWCLEANUP" ] || echo
  [ -n "$BADSTACKS" ] && echo $BADSTACKS

  echo -n -e "\033[32m  - CFN with stopped EC2:\033[0m"
  [ -n "$SHOWCLEANUP" ] && echo -e "\033[31m(aws cloudformation delete-stack --stack-name)\033[0m"
  [ -n "$SHOWCLEANUP" ] || echo
  [ -n "$STOPPEDSTACKS" ] && echo $STOPPEDSTACKS

  echo -n -e "\033[32m  - EC2 instances without \033[33mName\033[32m tag:\033[0m"
  [ -n "$SHOWCLEANUP" ] && echo -e "\033[31m(aws ec2 terminate-instances --instance-ids)\033[0m"
  [ -n "$SHOWCLEANUP" ] || echo
  aws ec2 describe-instances --region $region --query "Reservations[].Instances[].{ID: InstanceId, Tag: Tags[].Key}" --output json | jq -c '.[]' | grep -vi name | jq -r '.ID' | awk -v ORS=' ' '{ print $1  }' | sed 's/ $//'

  echo -n -e "\033[32m  - Unattached EBS volumes:\033[0m"
  [ -n "$SHOWCLEANUP" ] && echo -e "\033[31m(aws ec2 delete-volume --volume-id)\033[0m"
  [ -n "$SHOWCLEANUP" ] || echo
  aws ec2 describe-volumes --region $region --query 'Volumes[?State==`available`].{ID: VolumeId, State: State}' --output json | jq -c '.[]' | jq -r '.ID' | awk -v ORS=' ' '{ print $1  }' | sed 's/ $//'

done
