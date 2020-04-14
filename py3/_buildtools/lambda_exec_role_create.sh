#!/usr/bin/env bash
# Author: Tony Vattathil
# Create Lambda Exec Role

if [ $# -eq 0 ];
  then
    echo "Setting  ROLE_NAME to = 'lambda_exec_role'"
    ROLE_NAME='lambda_exec_role'
  else
    ROLE_NAME=$1
fi

# Check for aws command (awscli)
if ! [ -x "$(command -v aws)" ];
then
    echo 'Error: awscli is not installed.' >&2
    exit 1
fi


IAM_ROLE='{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Principal": {
			"Service": "lambda.amazonaws.com"
		},
		"Action": "sts:AssumeRole"
	}]
}'

aws iam get-role  --role-name "${ROLE_NAME}" &>/dev/null
ROLE_EXISTS=$?

if ! [ ${ROLE_EXISTS} = 0 ];
then
  aws iam create-role --role-name "${ROLE_NAME}" --assume-role-policy-document "${IAM_ROLE}" >>/dev/null
else 
  echo "$ROLE_NAME exists! To remove use run:"
  aws iam get-role  --role-name $ROLE_NAME
  echo "   aws iam delete-role --role-name=$ROLE_NAME"
  exit 
fi

# Verify role creation
aws iam wait role-exists --role-name $ROLE_NAME && aws iam get-role  --role-name $ROLE_NAME
