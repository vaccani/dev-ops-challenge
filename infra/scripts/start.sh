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

# Get db endpoint

# export db_endpoint=$(aws  rds describe-db-instances --output json | jq -r '.DBInstances[] | "\(.Endpoint.Address) " ' | grep "leo")

# sed -i "s/\$db_endpoint/$db_endpoint/g" config/database.yml


echo "Creating s3 bucket and uploading database.sql file"

aws s3api create-bucket --bucket challenge-leo-12345 --region us-east-1

aws s3 cp db/database.sql s3://challenge-leo-12345/

echo "Creating Bastion ec2 instance"

echo "Keypair "leo-ssh-keypair.pem" must be created before on your account"

# if you have the proper rights you can use the command: 
# 
# aws lightsail create-key-pair --key-pair-name leo-ssh-keypair.pem

aws cloudformation create-stack --stack-name leo-dev-bastion \
    --template-body file://infra/bastion/bastion.yaml \
    --parameters file://infra/bastion/bastion-dev.json \
    --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete --stack-name leo-dev-bastion

echo "DONE"
