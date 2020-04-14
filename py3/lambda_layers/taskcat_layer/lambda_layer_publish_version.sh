#!/usr/bin/env bash

LAYER_NAME=$(basename $PWD)
RUNTIME="python3.8"
LICENSE="Apache 2.0"
DESCRIPTION="taskcat layer"
ZIP_FILE=${LAYER_NAME}.zip 


echo "Run Pre-Build"
rm -rf python && mkdir -p python

echo "Run Build"
docker run --rm -v `pwd`:/var/task:z lambci/lambda:build-${RUNTIME} ${RUNTIME} -m pip --isolated install -t python -r requirements.txt

echo "Run Package"
zip -r ${ZIP_FILE} .

echo "Run Publish"
aws lambda publish-layer-version \
  --layer-name ${LAYER_NAME} \
  --zip-file fileb://${ZIP_FILE} \
  --compatible-runtimes ${RUNTIME}

echo "Run Clean"
rm -rf python
rm -r ${ZIP_FILE}
