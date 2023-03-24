resource "pool" "aws:lambda/function:Function" {
  s3Bucket        = config.lambda.s3Bucket != null ? config.lambda.s3Bucket : null
  s3Key           = config.lambda.s3Key != null ? config.lambda.s3Key : null
  s3ObjectVersion = config.lambda.s3ObjectVersion != null ? config.lambda.s3ObjectVersion : null
  code            = config.lambda.s3Bucket == null ? config.lambda.zip : null
  sourceCodeHash = config.lambda.s3Bucket == null ? invoke("std:index:filebase64sha256", {
    input = config.lambda.zip
  }).result : null
  name                         = "${config.prefix}-pool"
  role                         = poolResource2.arn
  handler                      = "index.adjustPool"
  architectures                = [config.lambda.architecture]
  runtime                      = config.lambda.runtime
  timeout                      = config.lambda.timeout
  reservedConcurrentExecutions = config.lambda.reservedConcurrentExecutions
  memorySize                   = 512
  tags                         = config.tags
  environment = {
    variables = {
      AMIIDSSMPARAMETERNAME      = config.amiIdSsmParameterName
      DISABLERUNNERAUTOUPDATE    = config.runner.disableRunnerAutoupdate
      ENABLEEPHEMERALRUNNERS     = config.runner.ephemeral
      ENVIRONMENT                = config.prefix
      GHESURL                    = config.ghes.url
      INSTANCEALLOCATIONSTRATEGY = config.instanceAllocationStrategy
      INSTANCEMAXSPOTPRICE       = config.instanceMaxSpotPrice
      INSTANCETARGETCAPACITYTYPE = config.instanceTargetCapacityType
      INSTANCETYPES = invoke("std:index:join", {
        separator = ","
        input     = config.instanceTypes
      }).result
      LAUNCHTEMPLATENAME              = config.runner.launchTemplate.name
      LOGLEVEL                        = config.lambda.logLevel
      NODETLSREJECTUNAUTHORIZED       = config.ghes.url != null && !config.ghes.sslVerify ? 0 : 1
      PARAMETERGITHUBAPPIDNAME        = config.githubAppParameters.id.name
      PARAMETERGITHUBAPPKEYBASE64NAME = config.githubAppParameters.keyBase64.name
      POWERTOOLSLOGGERLOGEVENT        = config.lambda.logLevel == "debug" ? "true" : "false"
      RUNNERBOOTTIMEINMINUTES         = config.runner.bootTimeInMinutes
      RUNNEREXTRALABELS               = config.runner.extraLabels
      RUNNERGROUPNAME                 = config.runner.groupName
      RUNNERNAMEPREFIX                = config.runner.namePrefix
      RUNNEROWNER                     = config.runner.poolOwner
      SERVICENAME                     = "runners-pool"
      SSMTOKENPATH                    = config.ssmTokenPath
      SUBNETIDS = invoke("std:index:join", {
        separator = ","
        input     = config.subnetIds
      }).result
    }

  }
}
resource "poolResource" "aws:cloudwatch/logGroup:LogGroup" {
  name            = "/aws/lambda/${pool.name}"
  retentionInDays = config.lambda.loggingRetentionInDays
  kmsKeyId        = config.lambda.loggingKmsKeyId
  tags            = config.tags
}
resource "poolResource2" "aws:iam/role:Role" {
  name                = "${config.prefix}-action-pool-lambda-role"
  assumeRolePolicy    = lambdaAssumeRolePolicy.json
  path                = config.rolePath
  permissionsBoundary = config.rolePermissionsBoundary
  tags                = config.tags
}
resource "poolResource3" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${config.prefix}-lambda-pool-policy"
  role   = poolResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-pool.json\",{\narn_runner_instance_role=var.config.runner.role.arn\ngithub_app_id_arn=var.config.github_app_parameters.id.arn\ngithub_app_key_base64_arn=var.config.github_app_parameters.key_base64.arn\nkms_key_arn=var.config.kms_key_arn\nami_kms_key_arn=var.config.ami_kms_key_arn\n})")
}
resource "poolLogging" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${config.prefix}-lambda-logging"
  role   = poolResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/../policies/lambda-cloudwatch.json\",{\nlog_group_arn=aws_cloudwatch_log_group.pool.arn\n})")
}
resource "lambdaPoolVpc" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = length(config.lambda.subnetIds) > 0 && length(config.lambda.securityGroupIds) > 0 ? 1 : 0
  }
  name = "${config.prefix}-lambda-pool-vpc"
  role = poolResource2.id
  policy = invoke("std:index:file", {
    input = "${module}/../policies/lambda-vpc.json"
  }).result
}
resource "poolVpcExecutionRole" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(config.lambda.subnetIds) > 0 ? 1 : 0
  }
  role      = poolResource2.name
  policyArn = "arn:${awsPartition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
lambdaAssumeRolePolicy = invoke("aws:iam/getPolicyDocument:getPolicyDocument", {
  statements = [{
    actions = ["sts:AssumeRole"]
    principals = [{
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }]
  }]
})
# per config object one trigger is created to trigger the lambda.
resource "poolResource4" "aws:cloudwatch/eventRule:EventRule" {
  options {
    range = length(config.pool)
  }
  name               = "${config.prefix}-pool-${range.value}-rule"
  scheduleExpression = config.pool[range.value].scheduleExpression
  tags               = config.tags
}
resource "poolResource5" "aws:cloudwatch/eventTarget:EventTarget" {
  options {
    range = length(config.pool)
  }
  input = toJSON({
    poolSize = config.pool[range.value].size
  })
  rule = poolResource4[range.value].name
  arn  = pool.arn
}
resource "poolResource6" "aws:lambda/permission:Permission" {
  options {
    range = length(config.pool)
  }
  statementId = "AllowExecutionFromCloudWatch-${range.value}"
  action      = "lambda:InvokeFunction"
  function    = pool.name
  principal   = "events.amazonaws.com"
  sourceArn   = poolResource4[range.value].arn
}
resource "amiIdSsmParameterRead" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = config.amiIdSsmParameterName != null ? 1 : 0
  }
  role      = poolResource2.name
  policyArn = config.amiIdSsmParameterReadPolicyArn
}
