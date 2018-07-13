#!/usr/bin/env node

const AWS = require('aws-sdk');
const _ = require('lodash');

const program = require('commander');

program
    .option('--region <region>', 'Default AWS region to use', 'us-east-1')
    .command('describe-active-stage')
    .option('--stack-name <stack-name>', 'CDN Stack name to query', 'sportnumerics-explorer-cdn-prod')
    .action((cmd) => {
        const cloudformation = new AWS.CloudFormation({ region: program.region });

        const StackName = cmd.stackName;

        cloudformation.describeStacks({
            StackName
        }, (err, data) => {
            if (err) {
                console.error(err);
            } else {
                const stack = data.Stacks[0];
                const param_stage = _.find(stack.Parameters, { ParameterKey: "ExplorerStageDeployment"}).ParameterValue;
                const output_stage = _.find(stack.Outputs, { OutputKey: 'ExplorerStageDeployment' }).OutputValue;
                if (param_stage !== output_stage) {
                    console.error(`Active stage under deployment: \x1b[31m${output_stage}\x1b[0m → \x1b[32m${param_stage}\x1b[0m`);
                    process.exit(1);
                } else {
                    console.log(output_stage);
                }
            }
        });
    });

program.parse(process.argv);