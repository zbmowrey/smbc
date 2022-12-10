# smbc

Containerized Python Lambda Hello World

# Running Locally

## Dependencies

### Docker

### Lambda Runtime Interface Emulator

    mkdir -p ~/.aws-lambda-rie
    curl -Lo ~/.aws-lambda-rie/aws-lambda-rie https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie
    chmod +x ~/.aws-lambda-rie/aws-lambda-rie


## Build
    docker build . -t 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest

## Run
    docker run -d -v ~/.aws-lambda-rie:/aws-lambda -p 9000:8080 --entrypoint /aws-lambda/aws-lambda-rie 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest /entry.sh app.handler

## Test 
                                                      JSON Event Goes Here -----------v
    curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'

## Deploy

    docker login -u AWS -p $(aws ecr get-login-password --region us-west-2) 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc
    docker push 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest

## Pull Latest

    docker pull 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest

## Operate

Create a lambda function and point it at 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc container (:latest).