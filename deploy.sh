#!/bin/bash

set -e

./decrypt.sh
source ./env/env.sh
unset AWS_SESSION_TOKEN

pip install --user awscli

if [ "$LAMBCI_BRANCH" = "master" ]; then
  export STAGE=prod
  EXPLORER_STAGE=prodblue
else
  export STAGE=dev
  EXPLORER_STAGE=dev
fi

APP_NAME="sportnumerics-explorer-cdn"
STACK_NAME="$APP_NAME-$STAGE"
TEMPLATE_FILE="cloudformation.yml"

aws configure set region $AWS_DEFAULT_REGION

aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --parameter-overrides \
    "StageParameter=$STAGE" \
    "ExplorerStageDeployment=$EXPLORER_STAGE" \
  --template-file $TEMPLATE_FILE \
  --no-fail-on-empty-changeset

CLOUDFRONT_ID=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey==`CloudfrontArn`].OutputValue' --output text)

aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths / /logo-196.png /logo-180.png /favicon.ico /app.js
