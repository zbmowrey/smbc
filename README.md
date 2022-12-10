# smbc

Python hello world intended for containerization & ship to lambda.



022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc


docker login -u AWS -p $(aws ecr get-login-password --region us-west-2) 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc


docker build . -t 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest

docker push 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest

docker pull 022017851643.dkr.ecr.us-east-2.amazonaws.com/smbc:latest