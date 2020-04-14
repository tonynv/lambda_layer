#!/usr/bin/env bash
# Author: Tony Vattathil
# Build and Packages Lambda Layers

RUNTIME="python3.8"
LICENSE="Apache 2.0"
DESCRIPTION="taskcat layer"
ZIP_FILE=${LAYER_NAME}.zip 

if [ $# -eq 0 ]; 
  then
    echo "Setting  PATH_TO_LAYER_SRC = '.'"
    BUILD_DIR='.'
  else 
    if [ -d "$1" ] 
      then
        echo "Setting  PATH_TO_LAYER_SRC = $1"
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
    echo "Cannot build lambda layer! [requirements.txt not found in $BUILD_DIR]"
    echo "Try something like:"
    echo "    <path-to>/lambda_layer_publish_version.sh <lambda_layers_src_dir/<layer_src>"
    echo "    _buildtools/lambda_layer_publish_version.sh lambda_layers/taskcat_layer"
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
    echo "Run:Package Layer"
    zip -r ${ZIP_FILE} .
  else
    echo 'Error: zip is not installed.' >&2
    exit 1
fi


# Check for aws command (awscli)
if [ -x "$(command -v aws)" ];
  then
    echo "Run:Publish Layer"
    aws lambda publish-layer-version \
      --layer-name ${LAYER_NAME} \
      --zip-file fileb://${ZIP_FILE} \
      --compatible-runtimes ${RUNTIME}
  else
    echo 'Error: awscli is not installed.' >&2
    exit 1
fi

echo "Run Cleanup"

rm -rf python
rm -r ${ZIP_FILE}
