#!/usr/bin/env bash
# Author: Tony Vattathil
# Build and Packages Lambda Functions

RUNTIME="python3.8"
ZIP_FILE=${LAYER_NAME}.zip 

if [ $# -eq 0 ]; 
  then
    echo "Setting  PATH_TO_LAMBDA_SRC = '.'"
    BUILD_DIR='.'
  else 
    if [ -d "$1" ] 
      then
        echo "Setting  PATH_TO_LAMBDA_SRC = $1"
        BUILD_DIR=$1
      else
        echo "$BUILD_DIR DOES NOT EXISTS!" 
        exit 1
    fi
fi

# Check for requirements file
echo "Looking for python requirements.txt in $BUILD_DIR"
cd $BUILD_DIR
LAYER_NAME=$(basename $PWD)

if [ ! -f requirements.txt ];
  then
    echo "Cannot build lambda function! [requirements.txt not found in $BUILD_DIR]"
    echo "Try something like:"
    echo "    <path-to>/lambda_function_create.sh <lambda_src_dir/<function_src>"
    echo "    _buildtools/lambda_function_create.sh lambda_function/taskcat_lambda"
    exit 1
fi


echo "Run:Build Lambda"

if [ -d "python" ];
  then
    echo "Removing old build dir"
    rm -rf python 
  else 
    echo "Create build dir"
    mkdir -p python
fi 

# Check for docker command
if [ -x "$(command -v docker)" ];
  then
    docker run --rm -v `pwd`:/var/task:z lambci/lambda:build-${RUNTIME} ${RUNTIME} -m pip --isolated install -t python -r requirements.txt
  else
    echo 'Error: docker is not installed.' >&2
    exit 1

fi

# Check for zip command
if [ -x "$(command -v zip)" ];
  then
    echo "Run:Package Function"
    zip -r ${ZIP_FILE} .
  else
    echo 'Error: zip is not installed.' >&2
    exit 1
fi
if [ -x "$(command -v jq)" ];
  then
    LAYER_EXEC_ROLE=$(aws iam get-role --role-name lambda_exec_role| jq -r ".Role.Arn")
  else
    echo 'Error: jq is not installed.' >&2
    exit 1
fi


# Check for aws command (awscli)
if [ -x "$(command -v aws)" ];
  then
    echo "Run:Publish Function"
    aws lambda create-function \
      --function-name ${LAYER_NAME} \
      --zip-file fileb://${ZIP_FILE} \
      --handler 'lambda_function.handler' \
      --role $LAYER_EXEC_ROLE \
      --runtime ${RUNTIME}
  else
    echo 'Error: awscli is not installed.' >&2
    exit 1
fi

echo "Run Cleanup"

rm -rf python
rm -r ${ZIP_FILE}
