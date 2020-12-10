#!/bin/bash

set -e

echo "Removing task definition..."

aws cloudformation delete-stack --stack-name hello-ruby-task 

aws cloudformation wait stack-delete-complete --stack-name hello-ruby-task

echo "Removing Bastion Server"

aws cloudformation delete-stack --stack-name leo-dev-bastion

aws cloudformation wait stack-delete-complete --stack-name leo-dev-bastion

echo "Removing RDS"

aws cloudformation delete-stack --stack-name hello-rds 

aws cloudformation wait stack-delete-complete --stack-name hello-rds

echo "Removing ECS cluster"

aws cloudformation delete-stack --stack-name leo-esc-cluster 

aws cloudformation wait stack-delete-complete --stack-name leo-esc-cluster

echo "Removing Roles"

aws cloudformation delete-stack --stack-name leo-iam 

aws cloudformation wait stack-delete-complete --stack-name leo-iam

echo "Removing VPC"

aws cloudformation delete-stack --stack-name leo-vpc

aws cloudformation wait stack-delete-complete --stack-name leo-vpc

echo "Removing ECR"

aws ecr delete-repository --repository-name hello-ruby --force

# echo "Removing S3 bucket"

# aws s3 rb s3://challenge-leo-12345 --force

echo "Removing keypair"

aws ec2 delete-key-pair --key-name leo-ssh-keypair

yes | rm leo-ssh-keypair.pem

echo "DONE"
