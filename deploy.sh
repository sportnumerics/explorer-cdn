#!/bin/bash

set -e

./decrypt.sh
source ./env/env.sh
unset AWS_SESSION_TOKEN

if [ "$LAMBCI_BRANCH" = "master" ]; then
  export STAGE=prod
  EXPLORER_STAGE=prodgreen
else
  export STAGE=dev
  EXPLORER_STAGE=dev
fi

REGION="ap-southeast-2"
APP_NAME="sportnumerics-explorer-cloudfront"
STACK_NAME="$APP_NAME-$STAGE"
TEMPLATE_FILE="cloudformation.yml"

aws configure set region $REGION

aws cloudformation deploy --stack-name $STACK_NAME --parameter-overrides "StageParameter=$STAGE" "ExplorerStageParameter=$EXPLORER_STAGE" --template-file $TEMPLATE_FILE || true

CLOUDFRONT_ID=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --query 'Stacks[0].Outputs[?OutputKey==`CloudfrontArn`].OutputValue' --output text)

aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id $CLOUDFRONT_ID --paths / /logo-196.png /logo-180.png /favicon.ico
