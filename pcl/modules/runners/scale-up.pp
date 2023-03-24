resource "scaleUp" "aws:lambda/function:Function" {
  s3Bucket        = lambdaS3Bucket != null ? lambdaS3Bucket : null
  s3Key           = runnersLambdaS3Key != null ? runnersLambdaS3Key : null
  s3ObjectVersion = runnersLambdaS3ObjectVersion != null ? runnersLambdaS3ObjectVersion : null
  code            = lambdaS3Bucket == null ? mylambdaZip : null
  sourceCodeHash = lambdaS3Bucket == null ? invoke("std:index:filebase64sha256", {
    input = mylambdaZip
  }).result : null
  name                         = "${prefix}-scale-up"
  role                         = scaleUpResource3.arn
  handler                      = "index.scaleUpHandler"
  runtime                      = lambdaRuntime
  timeout                      = lambdaTimeoutScaleUp
  reservedConcurrentExecutions = scaleUpReservedConcurrentExecutions
  memorySize                   = 512
  tags                         = mytags
  architectures                = [lambdaArchitecture]
  environment = {
    variables = {
      AMIIDSSMPARAMETERNAME      = amiIdSsmParameterName
      DISABLERUNNERAUTOUPDATE    = disableRunnerAutoupdate
      ENABLEEPHEMERALRUNNERS     = enableEphemeralRunners
      ENABLEJOBQUEUEDCHECK       = myenableJobQueuedCheck
      ENABLEORGANIZATIONRUNNERS  = enableOrganizationRunners
      ENVIRONMENT                = prefix
      GHESURL                    = ghesUrl
      INSTANCEALLOCATIONSTRATEGY = instanceAllocationStrategy
      INSTANCEMAXSPOTPRICE       = instanceMaxSpotPrice
      INSTANCETARGETCAPACITYTYPE = instanceTargetCapacityType
      INSTANCETYPES = invoke("std:index:join", {
        separator = ","
        input     = instanceTypes
      }).result
      LAUNCHTEMPLATENAME              = runnerResource.name
      LOGLEVEL                        = logLevel
      MINIMUMRUNNINGTIMEINMINUTES     = notImplemented("coalesce(var.minimum_running_time_in_minutes,local.min_runtime_defaults[var.runner_os])")
      NODETLSREJECTUNAUTHORIZED       = ghesUrl != null && !ghesSslVerify ? 0 : 1
      PARAMETERGITHUBAPPIDNAME        = githubAppParameters.id.name
      PARAMETERGITHUBAPPKEYBASE64NAME = githubAppParameters.keyBase64.name
      POWERTOOLSLOGGERLOGEVENT        = logLevel == "debug" ? "true" : "false"
      RUNNEREXTRALABELS = invoke("std:index:lower", {
        input = runnerExtraLabels
      }).result
      RUNNERGROUPNAME     = runnerGroupName
      RUNNERNAMEPREFIX    = runnerNamePrefix
      RUNNERSMAXIMUMCOUNT = runnersMaximumCount
      SERVICENAME         = "runners-scale-up"
      SSMTOKENPATH        = "${ssmPaths.root}/${ssmPaths.tokens}"
      SUBNETIDS = invoke("std:index:join", {
        separator = ","
        input     = subnetIds
      }).result
    }

  }
}
resource "scaleUpResource" "aws:cloudwatch/logGroup:LogGroup" {
  name            = "/aws/lambda/${scaleUp.name}"
  retentionInDays = loggingRetentionInDays
  kmsKeyId        = loggingKmsKeyId
  tags            = tags
}
resource "scaleUpResource2" "aws:lambda/eventSourceMapping:EventSourceMapping" {
  eventSourceArn = sqsBuildQueue.arn
  functionName   = scaleUp.arn
  batchSize      = 1
}
resource "scaleRunnersLambda" "aws:lambda/permission:Permission" {
  statementId = "AllowExecutionFromSQS"
  action      = "lambda:InvokeFunction"
  function    = scaleUp.name
  principal   = "sqs.amazonaws.com"
  sourceArn   = sqsBuildQueue.arn
}
resource "scaleUpResource3" "aws:iam/role:Role" {
  name                = "${prefix}-action-scale-up-lambda-role"
  assumeRolePolicy    = lambdaAssumeRolePolicy.json
  path                = myrolePath
  permissionsBoundary = rolePermissionsBoundary
  tags                = mytags
}
resource "scaleUpResource4" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-scale-up-policy"
  role   = scaleUpResource3.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-scale-up.json\",{\narn_runner_instance_role=aws_iam_role.runner.arn\nsqs_arn=var.sqs_build_queue.arn\ngithub_app_id_arn=var.github_app_parameters.id.arn\ngithub_app_key_base64_arn=var.github_app_parameters.key_base64.arn\nkms_key_arn=local.kms_key_arn\nami_kms_key_arn=local.ami_kms_key_arn\n})")
}
resource "scaleUpLogging" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-logging"
  role   = scaleUpResource3.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-cloudwatch.json\",{\nlog_group_arn=aws_cloudwatch_log_group.scale_up.arn\n})")
}
resource "serviceLinkedRole" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = createServiceLinkedRoleSpot ? 1 : 0
  }
  name   = "${prefix}-service_linked_role"
  role   = scaleUpResource3.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/service-linked-role-create-policy.json\",{aws_partition=var.aws_partition})")
}
resource "lambdaScaleUpVpc" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = length(lambdaSubnetIds) > 0 && length(lambdaSecurityGroupIds) > 0 ? 1 : 0
  }
  name = "${prefix}-lambda-scale-up-vpc"
  role = scaleUpResource3.id
  policy = invoke("std:index:file", {
    input = "${module}/policies/lambda-vpc.json"
  }).result
}
resource "scaleUpVpcExecutionRole" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(lambdaSubnetIds) > 0 ? 1 : 0
  }
  role      = scaleUpResource3.name
  policyArn = "arn:${awsPartition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "amiIdSsmParameterReadResource" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = amiIdSsmParameterName != null ? 1 : 0
  }
  role      = scaleUpResource3.name
  policyArn = amiIdSsmParameterRead[0].arn
}
