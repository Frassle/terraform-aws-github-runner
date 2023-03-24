config "awsRegion" "string" {
  description = "AWS region."
}
config "vpcId" "string" {
  description = "The VPC for the security groups."
}
config "subnetIds" "list(string)" {
  description = "List of subnets in which the action runners will be launched, the subnets needs to be subnets in the `vpc_id`."
}
config "overrides" "map(string)" {
  default = {
    name_runner = ""
    name_sg     = ""
  }
  description = "This map provides the possibility to override some defaults. The following attributes are supported: `name_sg` overrides the `Name` tag for all security groups created by this module. `name_runner_agent_instance` overrides the `Name` tag for the ec2 instance defined in the auto launch configuration. `name_docker_machine_runners` overrides the `Name` tag spot instances created by the runner agent."
}
config "tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name."
}
config "environment" "string" {
  description = "A name that identifies the environment, used as prefix and for tagging."
}
config "prefix" "string" {
  default     = "github-actions"
  description = "The prefix used for naming resources"
}
config "s3RunnerBinaries" "object({arn=string, id=string, key=string})" {
  description = "Bucket details for cached GitHub binary."
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
config "instanceTargetCapacityType" "string" {
  default     = "spot"
  description = "Default lifecyle used runner instances, can be either `spot` or `on-demand`."
}
config "instanceAllocationStrategy" "string" {
  default     = "lowest-price"
  description = "The allocation strategy for spot instances. AWS recommends to use `capacity-optimized` however the AWS default is `lowest-price`."
}
config "instanceMaxSpotPrice" "string" {
  description = "Max price price for spot intances per hour. This variable will be passed to the create fleet as max spot price for the fleet."
}
config "runnerOs" "string" {
  default     = "linux"
  description = "The EC2 Operating System type to use for action runner instances (linux,windows)."
}
config "instanceType" "string" {
  default     = "m5.large"
  description = "[DEPRECATED] See instance_types."
}
config "instanceTypes" "list(string)" {
  description = "List of instance types for the action runner. Defaults are based on runner_os (amzn2 for linux and Windows Server Core for win)."
}
config "amiFilter" "map(list(string))" {
  description = "Map of lists used to create the AMI filter for the action runner AMI."
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
config "enableUserdata" "bool" {
  default     = true
  description = "Should the userdata script be enabled for the runner. Set this to false if you are using your own prebuilt AMI"
}
config "userdataTemplate" "string" {
  description = "Alternative user-data template, replacing the default template. By providing your own user_data you have to take care of installing all required software, including the action runner. Variables userdata_pre/post_install are ignored."
}
config "userdataPreInstall" "string" {
  default     = ""
  description = "User-data script snippet to insert before GitHub action runner install"
}
config "userdataPostInstall" "string" {
  default     = ""
  description = "User-data script snippet to insert after GitHub action runner install"
}
config "sqsBuildQueue" "object({arn=string})" {
  description = "SQS queue to consume accepted build events."
}
config "enableOrganizationRunners" "bool" {
}
config "githubAppParameters" "object({id=map(string), key_base64=map(string)})" {
  description = "Parameter Store for GitHub App Parameters."
}
config "scaleDownScheduleExpression" "string" {
  default     = "cron(*/5 * * * ? *)"
  description = "Scheduler expression to check every x for scale down."
}
config "minimumRunningTimeInMinutes" "number" {
  description = "The time an ec2 action runner should be running at minimum before terminated if non busy. If not set the default is calculated based on the OS."
}
config "runnerBootTimeInMinutes" "number" {
  default     = 5
  description = "The minimum time for an EC2 runner to boot and register as a runner."
}
config "runnerExtraLabels" "string" {
  default     = ""
  description = "Extra labels for the runners (GitHub). Separate each label by a comma"
}
config "runnerGroupName" "string" {
  default     = "Default"
  description = "Name of the runner group."
}
config "lambdaZip" "string" {
  description = "File location of the lambda zip file."
}
config "lambdaTimeoutScaleDown" "number" {
  default     = 60
  description = "Time out for the scale down lambda in seconds."
}
config "scaleUpReservedConcurrentExecutions" "number" {
  default     = 1
  description = "Amount of reserved concurrent executions for the scale-up lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations."
}
config "lambdaTimeoutScaleUp" "number" {
  default     = 60
  description = "Time out for the scale up lambda in seconds."
}
config "rolePermissionsBoundary" "string" {
  description = "Permissions boundary that will be added to the created role for the lambda."
}
config "rolePath" "string" {
  description = "The path that will be added to the role; if not set, the prefix will be used."
}
config "instanceProfilePath" "string" {
  description = "The path that will be added to the instance_profile, if not set the prefix will be used."
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
config "runnerArchitecture" "string" {
  default     = "x64"
  description = "The platform architecture of the runner instance_type."
}
config "idleConfig" "list(object({cron=string, idleCount=number, timeZone=string}))" {
  default     = []
  description = "List of time period that can be defined as cron expression to keep a minimum amount of runners active instead of scaling down to 0. By defining this list you can ensure that in time periods that match the cron expression within 5 seconds a runner is kept idle."
}
config "loggingRetentionInDays" "number" {
  default     = 180
  description = "Specifies the number of days you want to retain log events for the lambda log group. Possible values are: 0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653."
}
config "loggingKmsKeyId" "string" {
  description = "Specifies the kms key id to encrypt the logs with"
}
config "enableSsmOnRunners" "bool" {
  description = "Enable to allow access to the runner instances for debugging purposes via SSM. Note that this adds additional permissions to the runner instances."
}
config "lambdaS3Bucket" "string" {
  description = "S3 bucket from which to specify lambda functions. This is an alternative to providing local files directly."
}
config "runnersLambdaS3Key" "string" {
  description = "S3 key for runners lambda function. Required if using S3 bucket to specify lambdas."
}
config "runnersLambdaS3ObjectVersion" "string" {
  description = "S3 object version for runners lambda function. Useful if S3 versioning is enabled on source bucket."
}
config "createServiceLinkedRoleSpot" "bool" {
  default     = false
  description = "(optional) create the service linked role for spot instances that is required by the scale-up lambda."
}
config "awsPartition" "string" {
  default     = "aws"
  description = "(optional) partition for the base arn if not 'aws'"
}
config "runnerIamRoleManagedPolicyArns" "list(string)" {
  default     = []
  description = "Attach AWS or customer-managed IAM policies (by ARN) to the runner IAM role"
}
config "enableCloudwatchAgent" "bool" {
  default     = true
  description = "Enabling the cloudwatch agent on the ec2 runner instances, the runner contains default config. Configuration can be overridden via `cloudwatch_config`."
}
config "enableManagedRunnerSecurityGroup" "bool" {
  default     = true
  description = "Enabling the default managed security group creation. Unmanaged security groups can be specified via `runner_additional_security_group_ids`."
}
config "cloudwatchConfig" "string" {
  description = "(optional) Replaces the module default cloudwatch log config. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Agent-Configuration-File-Details.html for details."
}
config "runnerLogFiles" "list(object({file_path=string, log_group_name=string, log_stream_name=string, prefix_log_group=bool}))" {
  description = "(optional) List of logfiles to send to CloudWatch, will only be used if `enable_cloudwatch_agent` is set to true. Object description: `log_group_name`: Name of the log group, `prefix_log_group`: If true, the log group name will be prefixed with `/github-self-hosted-runners/<var.prefix>`, `file_path`: path to the log file, `log_stream_name`: name of the log stream."
}
config "ghesUrl" "string" {
  description = "GitHub Enterprise Server URL. DO NOT SET IF USING PUBLIC GITHUB"
}
config "ghesSslVerify" "bool" {
  default     = true
  description = "GitHub Enterprise SSL verification. Set to 'false' when custom certificate (chains) is used for GitHub Enterprise Server (insecure)."
}
config "lambdaSubnetIds" "list(string)" {
  default     = []
  description = "List of subnets in which the lambda will be launched, the subnets needs to be subnets in the `vpc_id`."
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
config "kmsKeyArn" "string" {
  description = "Optional CMK Key ARN to be used for Parameter Store."
}
config "enableRunnerDetailedMonitoring" "bool" {
  default     = false
  description = "Enable detailed monitoring for runners"
}
config "egressRules" "list(object({cidr_blocks=list(string), description=string, from_port=number, ipv6_cidr_blocks=list(string), prefix_list_ids=list(string), protocol=string, security_groups=list(string), self=bool, to_port=number}))" {
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
config "runnerEc2Tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to the launch template instance tag specifications."
}
config "metadataOptions" "map()" {
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
config "enableRunnerBinariesSyncer" "bool" {
  default     = true
  description = "Option to disable the lambda to sync GitHub runner distribution, useful when using a pre-build AMI."
}
config "enableUserDataDebugLogging" "bool" {
  default     = false
  description = "Option to enable debug logging for user-data, this logs all secrets as well."
}
config "ssmPaths" "object({config=string, root=string, tokens=string})" {
  description = "The root path used in SSM to store configuration and secreets."
}
config "runnerNamePrefix" "string" {
  default     = ""
  description = "The prefix used for the GitHub runner name. The prefix will be used in the default start script to prefix the instance name when register the runner in GitHub. The value is availabe via an EC2 tag 'ghr:runner_name_prefix'."
}
