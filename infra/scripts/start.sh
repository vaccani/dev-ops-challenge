#!/bin/bash

set -e

# Create VPC 

aws cloudformation create-stack --stack-name leo-vpc \
    --template-body file://infra/vpc/vpc.yaml

aws cloudformation wait stack-create-complete --stack-name leo-vpc

# Create Roles

aws cloudformation create-stack --stack-name leo-iam \
    --template-body file://infra/ecs/iam.yaml \
    --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait stack-create-complete --stack-name leo-iam

# Create ECS cluster and repo

aws cloudformation create-stack --stack-name leo-esc-cluster \
    --template-body file://infra/ecs/ecs-cluster.yaml

aws cloudformation wait stack-create-complete --stack-name leo-esc-cluster


aws ecr create-repository --repository-name hello-ruby

# Create RDS

aws cloudformation create-stack --stack-name hello-rds \
    --template-body file://infra/rds/rds.yaml \
    --parameters file://infra/rds/rds.json

aws cloudformation wait stack-create-complete --stack-name hello-rds

# Get db endpoint

export db_endpoint=$(aws  rds describe-db-instances --output json | jq -r '.DBInstances[] | "\(.Endpoint.Address) " ' | grep "leo")

sed -i "s/\$db_endpoint/$db_endpoint/g" config/database.yml

# Create s3 bucket and upload database.sql file

aws s3api create-bucket --bucket challenge-leo-1234 --region us-east-1

aws s3 cp db/database.sql s3://challenge-leo-1234/

# Create Bastion

aws cloudformation create-stack --stack-name leo-dev-bastion \
    --template-body file://infra/bastion/bastion.yaml \
    --parameters file://infra/bastion/bastion-dev.json \
    --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete --stack-name leo-dev-bastion

echo "DONE"
