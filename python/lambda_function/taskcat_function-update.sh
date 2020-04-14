./package_function.sh

 aws lambda update-function-code --function-name taskcat_lambda_function --zip-file fileb://taskcat_function.zip
