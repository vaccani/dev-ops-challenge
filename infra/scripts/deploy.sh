#!/bin/bash

# Build Docker image

docker build -t hello-ruby .


# Push hello-ruby Docker image

aws ecr get-login --no-include-email | sh

IMAGE_REPO=$(aws ecr describe-repositories --repository-names hello-ruby --query 'repositories[0].repositoryUri' --output text)

docker tag hello-ruby:latest $IMAGE_REPO:v1

docker push $IMAGE_REPO:v1


echo "Creating hello-ruby  task definition"

aws cloudformation create-stack --stack-name hello-ruby-task \
    --template-body file://infra/ecs/task.yaml \
    --parameters file://infra/ecs/hello-world-task.json

aws cloudformation wait stack-create-complete --stack-name hello-ruby-task
