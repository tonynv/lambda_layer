./package_function.sh

aws lambda create-function \
    --function-name taskcat_lambda_function \
    --runtime python3.8 \
    --zip-file fileb://taskcat_function.zip \
    --handler lambda_function.handler \
    --role arn:aws:iam::536065598225:role/taskcat_lambda_role
