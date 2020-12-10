#!/bin/bash

set -e

echo "Creating VPC and subnets" 

aws cloudformation create-stack --stack-name leo-vpc \
    --template-body file://infra/vpc/vpc.yaml

aws cloudformation wait stack-create-complete --stack-name leo-vpc

echo "Creating ecs Role and policies needed for task definition"

aws cloudformation create-stack --stack-name leo-iam \
    --template-body file://infra/ecs/iam.yaml \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name leo-iam

echo "Creating ECS cluster and repo"

aws cloudformation create-stack --stack-name leo-esc-cluster \
    --template-body file://infra/ecs/ecs-cluster.yaml

aws cloudformation wait stack-create-complete --stack-name leo-esc-cluster


aws ecr create-repository --repository-name hello-ruby

echo "Creating RDS"

aws cloudformation create-stack --stack-name hello-rds \
    --template-body file://infra/rds/rds.yaml \
    --parameters file://infra/rds/rds.json

aws cloudformation wait stack-create-complete --stack-name hello-rds


#Note:
# In order to import database from bastion we have two ways to get the database.sql file
# Creating an "s3 bucket" and uploading the file on this script and then downloading from the bastion userdata script
# Or running a "wget" from bastion userdata script.
#In this case we are using "wget" since it takes too long to delete the "s3 bucket" and we need to test this pipeline several times 

#If we want to go with the s3 solution, we can uncomment the next lines and do the same on bastion cloudformation on line 196 and also in delete.sh lines 45 to 47 :

# echo "Creating s3 bucket and uploading database.sql file"

# aws s3api create-bucket --bucket challenge-leo-12345 --region us-east-1

# aws s3 cp db/database.sql s3://challenge-leo-12345/

echo "Creating Bastion ec2 instance"

aws ec2 create-key-pair --key-name leo-ssh-keypair --query 'KeyMaterial' --output text > leo-ssh-keypair.pem && chmod 400 leo-ssh-keypair.pem

aws cloudformation create-stack --stack-name leo-dev-bastion \
    --template-body file://infra/bastion/bastion.yaml \
    --parameters file://infra/bastion/bastion-dev.json \
    --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete --stack-name leo-dev-bastion

echo "DONE"
