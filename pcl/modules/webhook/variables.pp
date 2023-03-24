config "lambdaSubnetIds" "list(string)" {
  default     = []
  description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
}
config "lambdaSecurityGroupIds" "list(string)" {
  default     = []
  description = "List of security group IDs associated with the Lambda function."
}
config "environment" "string" {
  description = "A name that identifies the environment, used as prefix and for tagging."
}
config "prefix" "string" {
  default     = "github-actions"
  description = "The prefix used for naming resources"
}
config "tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
}
config "runnerConfig" "map(object({arn=string, fifo=bool, id=string, matcherConfig=object({exactMatch=bool, labelMatchers=list(list(string))})}))" {
  description = "SQS queue to publish accepted build events based on the runner type."
}
config "sqsWorkflowJobQueue" "object({arn=string, id=string})" {
  description = "SQS queue to monitor github events."
}
config "lambdaZip" "string" {
  description = "File location of the lambda zip file."
}
config "lambdaTimeout" "number" {
  default     = 10
  description = "Time out of the lambda in seconds."
}
config "rolePermissionsBoundary" "string" {
  description = "Permissions boundary that will be added to the created role for the lambda."
}
config "rolePath" "string" {
  description = "The path that will be added to the role; if not set, the environment name will be used."
}
config "loggingRetentionInDays" "number" {
  default     = 7
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
}
config "loggingKmsKeyId" "string" {
  description = "Specifies the kms key id to encrypt the logs with"
}
config "lambdaS3Bucket" "string" {
  description = "S3 bucket from which to specify lambda functions. This is an alternative to providing local files directly."
}
config "webhookLambdaS3Key" "string" {
  description = "S3 key for webhook lambda function. Required if using S3 bucket to specify lambdas."
}
config "webhookLambdaS3ObjectVersion" "string" {
  description = "S3 object version for webhook lambda function. Useful if S3 versioning is enabled on source bucket."
}
config "webhookLambdaApigatewayAccessLogSettings" "object({destination_arn=string, format=string})" {
  description = "Access log settings for webhook API gateway."
}
config "repositoryWhiteList" "list(string)" {
  default     = []
  description = "List of repositories allowed to use the github app"
}
config "kmsKeyArn" "string" {
  description = "Optional CMK Key ARN to be used for Parameter Store."
}
config "logType" "string" {
  description = "Logging format for lambda logging. Valid values are 'json', 'pretty', 'hidden'. "
}
config "logLevel" "string" {
  default     = "info"
  description = "Logging level for lambda logging. Valid values are  'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
}
config "lambdaRuntime" "string" {
  default     = "nodejs18.x"
  description = "AWS Lambda runtime."
}
config "awsPartition" "string" {
  default     = "aws"
  description = "(optional) partition for the base arn if not 'aws'"
}
config "lambdaArchitecture" "string" {
  default     = "arm64"
  description = "AWS Lambda architecture. Lambda functions using Graviton processors ('arm64') tend to have better price/performance than 'x86_64' functions. "
}
config "githubAppParameters" "object({webhook_secret=map(string)})" {
  description = "Parameter Store for GitHub App Parameters."
}
