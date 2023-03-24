config "tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
}
config "environment" "string" {
  description = "A name that identifies the environment, used as prefix and for tagging."
}
config "prefix" "string" {
  default     = "github-actions"
  description = "The prefix used for naming resources"
}
config "distributionBucketName" "string" {
  description = "Bucket for storing the action runner distribution."
}
config "s3LoggingBucket" "string" {
  description = "Bucket for action runner distribution bucket access logging."
}
config "s3LoggingBucketPrefix" "string" {
  description = "Bucket prefix for action runner distribution bucket access logging."
}
config "enableEventRuleBinariesSyncer" "bool" {
  default     = true
  description = "Option to disable EventBridge Lambda trigger for the binary syncer, useful to stop automatic updates of binary distribution"
}
config "lambdaScheduleExpression" "string" {
  default     = "cron(27 * * * ? *)"
  description = "Scheduler expression for action runner binary syncer."
}
config "lambdaZip" "string" {
  description = "File location of the lambda zip file."
}
config "lambdaTimeout" "number" {
  default     = 300
  description = "Time out of the lambda in seconds."
}
config "rolePermissionsBoundary" "string" {
  description = "Permissions boundary that will be added to the created role for the lambda."
}
config "rolePath" "string" {
  description = "The path that will be added to the role, if not set the environment name will be used."
}
config "runnerOs" "string" {
  default     = "linux"
  description = "The EC2 Operating System type to use for action runner instances (linux,windows)."
}
config "runnerArchitecture" "string" {
  default     = "x64"
  description = "The platform architecture of the runner instance_type."
}
config "loggingRetentionInDays" "number" {
  default     = 7
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
}
config "loggingKmsKeyId" "string" {
  description = "Specifies the kms key id to encrypt the logs with"
}
config "runnerAllowPrereleaseBinaries" "bool" {
  description = "(Deprecated, no longer used), allow the runners to update to prerelease binaries."
}
config "lambdaS3Bucket" "string" {
  description = "S3 bucket from which to specify lambda functions. This is an alternative to providing local files directly."
}
config "syncerLambdaS3Key" "string" {
  description = "S3 key for syncer lambda function. Required if using S3 bucket to specify lambdas."
}
config "syncerLambdaS3ObjectVersion" "string" {
  description = "S3 object version for syncer lambda function. Useful if S3 versioning is enabled on source bucket."
}
config "lambdaSubnetIds" "list(string)" {
  default     = []
  description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
}
config "lambdaSecurityGroupIds" "list(string)" {
  default     = []
  description = "List of security group IDs associated with the Lambda function."
}
config "awsPartition" "string" {
  default     = "aws"
  description = "(optional) partition for the base arn if not 'aws'"
}
config "logType" "string" {
  description = "Logging format for lambda logging. Valid values are 'json', 'pretty', 'hidden'. "
}
config "logLevel" "string" {
  default     = "info"
  description = "Logging level for lambda logging. Valid values are  'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
}
config "serverSideEncryptionConfiguration" "object({rule=object({apply_server_side_encryption_by_default=object({sse_algorithm=string})})})" {
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  description = "Map containing server-side encryption configuration."
}
config "lambdaPrincipals" "list(object({identifiers=list(string), type=string}))" {
  default     = []
  description = "(Optional) add extra principals to the role created for execution of the lambda, e.g. for local testing."
}
config "lambdaRuntime" "string" {
  default     = "nodejs18.x"
  description = "AWS Lambda runtime."
}
config "lambdaArchitecture" "string" {
  default     = "arm64"
  description = "AWS Lambda architecture. Lambda functions using Graviton processors ('arm64') tend to have better price/performance than 'x86_64' functions. "
}
