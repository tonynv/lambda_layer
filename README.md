# Setup Dev Enviorment
# Pre Requisite
Install and configure pyenv (not covered here)

pyenv install 3.8.0

pyenv shell 3.8.0
mkvirtualenv --python=`pyenv which python` lambda_layer

which python
/Users/tonynv/.virtualenvs/lambda_layer/bin/python

mkdir lambda_layer

pip install taskcat -t lambda_layers/python/lib/python3.8/site-packages/
zip -r taskcat_lambda_layer.zip *


aws lambda publish-layer-version \
    --layer-name taskcat-layer \
    --description "taskcat layer" \
    --license-info "Apache 2.0" \
    --content S3Bucket=tonynv-lambda,S3Key=taskcat_lambda_layer.zip \
    --compatible-runtimes python3.8
