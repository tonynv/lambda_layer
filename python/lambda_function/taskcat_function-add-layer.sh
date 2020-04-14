#!/bin/bash
TASKCAT_LAYER = $(aws lambda list-layer-versions --layer-name taskcat-layer --query 'LayerVersions[0].LayerVersionArn')
aws lambda update-function-configuration --function-name "taskcat_lambda_function" --layers $TASKCAT_LAYER
