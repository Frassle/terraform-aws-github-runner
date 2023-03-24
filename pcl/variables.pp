config "awsRegion" "string" {
  description = "AWS region."
}
config "vpcId" "string" {
  description = "The VPC for security groups of the action runners."
}
config "subnetIds" "list(string)" {
  description = "List of subnets in which the action runner instances will be launched. The subnets need to exist in the configured VPC (`vpc_id`), and must reside on different availability zones (see https://github.com/philips-labs/terraform-aws-github-runner/issues/2904)"
}
config "tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
}
config "environment" "string" {
  description = "DEPRECATED, no longer used. See `prefix`"
}
config "prefix" "string" {
  default     = "github-actions"
  description = "The prefix used for naming resources"
}
config "enableOrganizationRunners" "bool" {
  default     = false
  description = "Register runners to organization, instead of repo level"
}
config "githubApp" "object({id=string, key_base64=string, webhook_secret=string})" {
  description = "GitHub app parameters, see your github app. Ensure the key is the base64-encoded `.pem` file (the output of `base64 app.private-key.pem`, not the content of `private-key.pem`)."
}
config "scaleDownScheduleExpression" "string" {
  default     = "cron(*/5 * * * ? *)"
  description = "Scheduler expression to check every x for scale down."
}
config "minimumRunningTimeInMinutes" "number" {
  description = "The time an ec2 action runner should be running at minimum before terminated if not busy."
}
config "runnerBootTimeInMinutes" "number" {
  default     = 5
  description = "The minimum time for an EC2 runner to boot and register as a runner."
}
config "runnerExtraLabels" "string" {
  default     = ""
  description = "Extra (custom) labels for the runners (GitHub). Separate each label by a comma. Labels checks on the webhook can be enforced by setting `enable_workflow_job_labels_check`. GitHub read-only labels should not be provided."
}
config "runnerGroupName" "string" {
  default     = "Default"
  description = "Name of the runner group."
}
config "scaleUpReservedConcurrentExecutions" "number" {
  default     = 1
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
}
config "webhookLambdaZip" "string" {
  description = "File location of the webhook lambda zip file."
}
config "webhookLambdaTimeout" "number" {
  default     = 10
  description = "Time out of the webhook lambda in seconds."
}
config "runnersLambdaZip" "string" {
  description = "File location of the lambda zip file for scaling runners."
}
config "runnersScaleUpLambdaTimeout" "number" {
  default     = 30
  description = "Time out for the scale up lambda in seconds."
}
config "runnersScaleDownLambdaTimeout" "number" {
  default     = 60
  description = "Time out for the scale down lambda in seconds."
}
config "runnerBinariesSyncerLambdaZip" "string" {
  description = "File location of the binaries sync lambda zip file."
}
config "runnerBinariesSyncerLambdaTimeout" "number" {
  default     = 300
  description = "Time out of the binaries sync lambda in seconds."
}
config "runnerBinariesS3SseConfiguration" "object({rule=object({apply_server_side_encryption_by_default=object({sse_algorithm=string})})})" {
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  description = "Map containing server-side encryption configuration for runner-binaries S3 bucket."
}
config "runnerBinariesS3LoggingBucket" "string" {
  description = "Bucket for action runner distribution bucket access logging."
}
config "runnerBinariesS3LoggingBucketPrefix" "string" {
  description = "Bucket prefix for action runner distribution bucket access logging."
}
config "rolePermissionsBoundary" "string" {
  description = "Permissions boundary that will be added to the created roles."
}
config "rolePath" "string" {
  description = "The path that will be added to role path for created roles, if not set the environment name will be used."
}
config "instanceProfilePath" "string" {
  description = "The path that will be added to the instance_profile, if not set the environment name will be used."
}
config "runnerAsRoot" "bool" {
  default     = false
  description = "Run the action runner under the root user. Variable `runner_run_as` will be ignored."
}
config "runnerRunAs" "string" {
  default     = "ec2-user"
  description = "Run the GitHub actions agent as user."
}
config "runnersMaximumCount" "number" {
  default     = 3
  description = "The maximum number of runners that will be created."
}
config "kmsKeyArn" "string" {
  description = "Optional CMK Key ARN to be used for Parameter Store. This key must be in the current account."
}
config "enableRunnerDetailedMonitoring" "bool" {
  default     = false
  description = "Should detailed monitoring be enabled for the runner. Set this to true if you want to use detailed monitoring. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-cloudwatch-new.html for details."
}
config "enableUserdata" "bool" {
  default     = true
  description = "Should the userdata script be enabled for the runner. Set this to false if you are using your own prebuilt AMI."
}
config "userdataTemplate" "string" {
  description = "Alternative user-data template, replacing the default template. By providing your own user_data you have to take care of installing all required software, including the action runner. Variables userdata_pre/post_install are ignored."
}
config "userdataPreInstall" "string" {
  default     = ""
  description = "Script to be ran before the GitHub Actions runner is installed on the EC2 instances"
}
config "userdataPostInstall" "string" {
  default     = ""
  description = "Script to be ran after the GitHub Actions runner is installed on the EC2 instances"
}
config "idleConfig" "list(object({cron=string, idleCount=number, timeZone=string}))" {
  default     = []
  description = "List of time period that can be defined as cron expression to keep a minimum amount of runners active instead of scaling down to 0. By defining this list you can ensure that in time periods that match the cron expression within 5 seconds a runner is kept idle."
}
config "enableSsmOnRunners" "bool" {
  default     = false
  description = "Enable to allow access the runner instances for debugging purposes via SSM. Note that this adds additional permissions to the runner instances."
}
config "loggingRetentionInDays" "number" {
  default     = 180
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
}
config "loggingKmsKeyId" "string" {
  description = "Specifies the kms key id to encrypt the logs with"
}
config "runnerAllowPrereleaseBinaries" "bool" {
  description = "(Deprecated, no longer used), allow the runners to update to prerelease binaries."
}
config "blockDeviceMappings" "list(object({delete_on_termination=bool, device_name=string, encrypted=bool, iops=number, kms_key_id=string, snapshot_id=string, throughput=number, volume_size=number, volume_type=string}))" {
  default = [{
    delete_on_termination = true
    device_name           = "/dev/xvda"
    encrypted             = true
    iops                  = null
    kms_key_id            = null
    snapshot_id           = null
    throughput            = null
    volume_size           = 30
    volume_type           = "gp3"
  }]
  description = "The EC2 instance block device configuration. Takes the following keys: `device_name`, `delete_on_termination`, `volume_type`, `volume_size`, `encrypted`, `iops`, `throughput`, `kms_key_id`, `snapshot_id`."
}
config "amiFilter" "map(list(string))" {
  description = "List of maps used to create the AMI filter for the action runner AMI. By default amazon linux 2 is used."
}
config "amiOwners" "list(string)" {
  default     = ["amazon"]
  description = "The list of owners used to select the AMI of action runner instances."
}
config "amiIdSsmParameterName" "string" {
  description = "Externally managed SSM parameter (of data type aws:ec2:image) that contains the AMI ID to launch runner instances from. Overrides ami_filter"
}
config "amiKmsKeyArn" "string" {
  description = "Optional CMK Key ARN to be used to launch an instance from a shared encrypted AMI"
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
config "webhookLambdaS3Key" "string" {
  description = "S3 key for webhook lambda function. Required if using S3 bucket to specify lambdas."
}
config "webhookLambdaS3ObjectVersion" "string" {
  description = "S3 object version for webhook lambda function. Useful if S3 versioning is enabled on source bucket."
}
config "webhookLambdaApigatewayAccessLogSettings" "object({destination_arn=string, format=string})" {
}
config "runnersLambdaS3Key" "string" {
  description = "S3 key for runners lambda function. Required if using S3 bucket to specify lambdas."
}
config "runnersLambdaS3ObjectVersion" "string" {
  description = "S3 object version for runners lambda function. Useful if S3 versioning is enabled on source bucket."
}
config "createServiceLinkedRoleSpot" "bool" {
  default     = false
  description = "(optional) create the serviced linked role for spot instances that is required by the scale-up lambda."
}
config "runnerIamRoleManagedPolicyArns" "list(string)" {
  default     = []
  description = "Attach AWS or customer-managed IAM policies (by ARN) to the runner IAM role"
}
config "enableCloudwatchAgent" "bool" {
  default     = true
  description = "Enabling the cloudwatch agent on the ec2 runner instances, the runner contains default config. Configuration can be overridden via `cloudwatch_config`."
}
config "cloudwatchConfig" "string" {
  description = "(optional) Replaces the module default cloudwatch log config. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html for details."
}
config "runnerLogFiles" "list(object({file_path=string, log_group_name=string, log_stream_name=string, prefix_log_group=bool}))" {
  description = "(optional) Replaces the module default cloudwatch log config. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html for details."
}
config "ghesUrl" "string" {
  description = "GitHub Enterprise Server URL. Example: https://github.internal.co - DO NOT SET IF USING PUBLIC GITHUB"
}
config "ghesSslVerify" "bool" {
  default     = true
  description = "GitHub Enterprise SSL verification. Set to 'false' when custom certificate (chains) is used for GitHub Enterprise Server (insecure)."
}
config "lambdaSubnetIds" "list(string)" {
  default     = []
  description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
}
config "lambdaSecurityGroupIds" "list(string)" {
  default     = []
  description = "List of security group IDs associated with the Lambda function."
}
config "keyName" "string" {
  description = "Key pair name"
}
config "runnerAdditionalSecurityGroupIds" "list(string)" {
  default     = []
  description = "(optional) List of additional security groups IDs to apply to the runner"
}
config "instanceTargetCapacityType" "string" {
  default     = "spot"
  description = "Default lifecycle used for runner instances, can be either `spot` or `on-demand`."
}
config "instanceAllocationStrategy" "string" {
  default     = "lowest-price"
  description = "The allocation strategy for spot instances. AWS recommends to use `price-capacity-optimized` however the AWS default is `lowest-price`."
}
config "instanceMaxSpotPrice" "string" {
  description = "Max price price for spot intances per hour. This variable will be passed to the create fleet as max spot price for the fleet."
}
config "instanceTypes" "list(string)" {
  default     = ["m5.large", "c5.large"]
  description = "List of instance types for the action runner. Defaults are based on runner_os (amzn2 for linux and Windows Server Core for win)."
}
config "repositoryWhiteList" "list(string)" {
  default     = []
  description = "List of repositories allowed to use the github app"
}
config "delayWebhookEvent" "number" {
  default     = 30
  description = "The number of seconds the event accepted by the webhook is invisible on the queue before the scale up lambda will receive the event."
}
config "jobQueueRetentionInSeconds" "number" {
  default     = 86400
  description = "The number of seconds the job is held in the queue before it is purged"
}
config "runnerEgressRules" "list(object({cidr_blocks=list(string), description=string, from_port=number, ipv6_cidr_blocks=list(string), prefix_list_ids=list(string), protocol=string, security_groups=list(string), self=bool, to_port=number}))" {
  default = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = null
    from_port        = 0
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = null
    protocol         = "-1"
    security_groups  = null
    self             = null
    to_port          = 0
  }]
  description = "List of egress rules for the GitHub runner instances."
}
config "logType" "string" {
  description = "Logging format for lambda logging. Valid values are 'json', 'pretty', 'hidden'. "
}
config "logLevel" "string" {
  default     = "info"
  description = "Logging level for lambda logging. Valid values are  'silly', 'trace', 'debug', 'info', 'warn', 'error', 'fatal'."
}
config "enableRunnerWorkflowJobLabelsCheckAll" "bool" {
  default     = true
  description = "If set to true all labels in the workflow job must match the GitHub labels (os, architecture and `self-hosted`). When false if __any__ label matches it will trigger the webhook."
}
config "runnerEc2Tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to the launch template instance tag specifications."
}
config "runnerMetadataOptions" "map()" {
  default = {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "enabled"
  }
  description = "Metadata options for the ec2 runner instances. By default, the module uses metadata tags for bootstrapping the runner, only disable `instance_metadata_tags` when using custom scripts for starting the runner."
}
config "enableEphemeralRunners" "bool" {
  default     = false
  description = "Enable ephemeral runners, runners will only be used once."
}
config "enableJobQueuedCheck" "bool" {
  description = "Only scale if the job event received by the scale up lambda is is in the state queued. By default enabled for non ephemeral runners and disabled for ephemeral. Set this variable to overwrite the default behavior."
}
config "enableManagedRunnerSecurityGroup" "bool" {
  default     = true
  description = "Enabling the default managed security group creation. Unmanaged security groups can be specified via `runner_additional_security_group_ids`."
}
config "runnerOs" "string" {
  default     = "linux"
  description = "The EC2 Operating System type to use for action runner instances (linux,windows)."
}
config "lambdaPrincipals" "list(object({identifiers=list(string), type=string}))" {
  default     = []
  description = "(Optional) add extra principals to the role created for execution of the lambda, e.g. for local testing."
}
config "enableFifoBuildQueue" "bool" {
  default     = false
  description = "Enable a FIFO queue to remain the order of events received by the webhook. Suggest to set to true for repo level runners."
}
config "redriveBuildQueue" "object({enabled=bool, maxReceiveCount=number})" {
  default = {
    enabled         = false
    maxReceiveCount = null
  }
  description = "Set options to attach (optional) a dead letter queue to the build queue, the queue between the webhook and the scale up lambda. You have the following options. 1. Disable by setting `enabled` to false. 2. Enable by setting `enabled` to `true`, `maxReceiveCount` to a number of max retries."
}
config "runnerArchitecture" "string" {
  default     = "x64"
  description = "The platform architecture of the runner instance_type."
}
config "poolLambdaTimeout" "number" {
  default     = 60
  description = "Time out for the pool lambda in seconds."
}
config "poolRunnerOwner" "string" {
  description = "The pool will deploy runners to the GitHub org ID, set this value to the org to which you want the runners deployed. Repo level is not supported."
}
config "poolLambdaReservedConcurrentExecutions" "number" {
  default     = 1
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
}
config "poolConfig" "list(object({schedule_expression=string, size=number}))" {
  default     = []
  description = "The configuration for updating the pool. The `pool_size` to adjust to by the events triggered by the `schedule_expression`. For example you can configure a cron expression for week days to adjust the pool to 10 and another expression for the weekend to adjust the pool to 1."
}
config "awsPartition" "string" {
  default     = "aws"
  description = "(optiona) partition in the arn namespace to use if not 'aws'"
}
config "disableRunnerAutoupdate" "bool" {
  default     = false
  description = "Disable the auto update of the github runner agent. Be-aware there is a grace period of 30 days, see also the [GitHub article](https://github.blog/changelog/2022-02-01-github-actions-self-hosted-runners-can-now-disable-automatic-updates/)"
}
config "lambdaRuntime" "string" {
  default     = "nodejs18.x"
  description = "AWS Lambda runtime."
}
config "lambdaArchitecture" "string" {
  default     = "arm64"
  description = "AWS Lambda architecture. Lambda functions using Graviton processors ('arm64') tend to have better price/performance than 'x86_64' functions. "
}
config "enableWorkflowJobEventsQueue" "bool" {
  default     = false
  description = "Enabling this experimental feature will create a secondory sqs queue to wich a copy of the workflow_job event will be delivered."
}
config "workflowJobQueueConfiguration" "object({delay_seconds=number, message_retention_seconds=number, visibility_timeout_seconds=number})" {
  default = {
    delay_seconds              = null
    message_retention_seconds  = null
    visibility_timeout_seconds = null
  }
  description = "Configuration options for workflow job queue which is only applicable if the flag enable_workflow_job_events_queue is set to true."
}
config "enableRunnerBinariesSyncer" "bool" {
  default     = true
  description = "Option to disable the lambda to sync GitHub runner distribution, useful when using a pre-build AMI."
}
config "enableEventRuleBinariesSyncer" "bool" {
  default     = true
  description = "Option to disable EventBridge Lambda trigger for the binary syncer, useful to stop automatic updates of binary distribution"
}
config "queueEncryption" "object({kms_data_key_reuse_period_seconds=number, kms_master_key_id=string, sqs_managed_sse_enabled=bool})" {
  default = {
    kms_data_key_reuse_period_seconds = null
    kms_master_key_id                 = null
    sqs_managed_sse_enabled           = true
  }
  description = "Configure how data on queues managed by the modules in ecrypted at REST. Options are encryped via SSE, non encrypted and via KMSS. By default encryptes via SSE is enabled. See for more details the Terraform `aws_sqs_queue` resource https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue."
}
config "enableUserDataDebugLoggingRunner" "bool" {
  default     = false
  description = "Option to enable debug logging for user-data, this logs all secrets as well."
}
config "ssmPaths" "object({app=string, root=string, runners=string, use_prefix=bool})" {
  default = {
    app        = "app"
    root       = "github-action-runners"
    runners    = "runners"
    use_prefix = true
  }
  description = "The root path used in SSM to store configuration and secreets."
}
config "runnerNamePrefix" "string" {
  default     = ""
  description = "The prefix used for the GitHub runner name. The prefix will be used in the default start script to prefix the instance name when register the runner in GitHub. The value is availabe via an EC2 tag 'ghr:runner_name_prefix'."
}
