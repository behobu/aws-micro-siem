# This GitHub repository contains a minimal amount of Terraform code to stand up a demonstration micro-SIEM using the AWS services CloudTrail, EventBridge, SNS Topics, and Chatbot.

### NOTE: This repo requires that you either have an AWS config file with credentials stored in it or have an active AWS CLI session for a user/role with appropriate permissions.

variables.tf contains all of the items that must be changed when implemented in your own environment.

cloudtrail.tf, s3.tf, and kms.tf contain suggested settings, but can be customized to whatever is required for your environment

eventbridge.tf contains the one rule this demo provides
### NOTE: the aws.signin service only functions in the us-east-1 region, so unless you're creating a cross-region event bus instead of using the default event bus for EventBridge, you'll need your EventBridge rule running in us-east-1 as well as configuring your CloudTrail for that region.

sns.tf has a topic and policy for this demo, which would need to be added to or customized for your use cases
chatbot.tf contains dummy Slack channel and workspace IDs and will need to be customized to your environment settings

## To Implement
1. At a minimum, the account ID in variables.tf will need to be updated to reflect your AWS target account ID
2. You must log into the AWS Console for your target account with a user/role that has sufficient permission to enable the Chatbot service AND by a person who also has sufficient permission to link the AWS Chatbot service to your Slack Workspace
3. Change the channel ID and workspace ID in chatbot.tf
4. Run `terraform init` where you've cloned this repo
5. Run `terraform plan` just to make sure you have the correct permissions and there are no errors that need to be dealt with
6. When everything is ready (no more errors, all settings the way you want them), run `terraform apply` (optionally with the -auto-approve flag)
7. Try to trigger your rule!  Remember, it takes about 15 seconds for the rule trigger to filter down to the Slack channel for notification