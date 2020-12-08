#!/bin/bash

set -e

aws cloudformation delete-stack --stack-name hello-ruby-task 

aws cloudformation wait stack-delete-complete --stack-name hello-ruby-task

aws cloudformation delete-stack --stack-name leo-dev-bastion

aws cloudformation wait stack-delete-complete --stack-name leo-dev-bastion

aws cloudformation delete-stack --stack-name hello-rds 

aws cloudformation wait stack-delete-complete --stack-name hello-rds


aws cloudformation delete-stack --stack-name leo-esc-cluster 

aws cloudformation wait stack-delete-complete --stack-name leo-esc-cluster


aws cloudformation delete-stack --stack-name leo-iam 

aws cloudformation wait stack-delete-complete --stack-name leo-iam


aws cloudformation delete-stack --stack-name leo-vpc

aws cloudformation wait stack-delete-complete --stack-name leo-vpc

aws ecr delete-repository --repository-name hello-ruby --force

aws s3 rb s3://challenge-leo-12345 --force

echo "DONE"