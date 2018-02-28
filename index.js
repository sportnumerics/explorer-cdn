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
                const stage = _.find(data.Stacks[0].Outputs, { OutputKey: 'ExplorerStageDeployment' }).OutputValue;
                console.log(stage);
            }
        });
    });

program.parse(process.argv);