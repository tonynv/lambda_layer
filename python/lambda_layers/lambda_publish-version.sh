./package_python3.8.0.sh

aws lambda publish-layer-version \
     --layer-name taskcat-layer \
     --description "taskcat layer" \
     --license-info "Apache 2.0" \
     --zip-file fileb://taskcat_lambda_layer.zip \
     --compatible-runtimes python3.8
