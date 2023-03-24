mylambdaZip = lambdaZip == null ? "${module}/lambdas/runner-binaries-syncer/runner-binaries-syncer.zip" : lambdaZip
myrolePath  = rolePath == null ? "/${prefix}/" : rolePath
ghBinaryOsLabel = {
  windows = "win"
  linux   = "linux"
}

resource "syncer" "aws:lambda/function:Function" {
  s3Bucket        = lambdaS3Bucket != null ? lambdaS3Bucket : null
  s3Key           = syncerLambdaS3Key != null ? syncerLambdaS3Key : null
  s3ObjectVersion = syncerLambdaS3ObjectVersion != null ? syncerLambdaS3ObjectVersion : null
  code            = lambdaS3Bucket == null ? mylambdaZip : null
  sourceCodeHash = lambdaS3Bucket == null ? invoke("std:index:filebase64sha256", {
    input = mylambdaZip
  }).result : null
  name          = "${prefix}-syncer"
  role          = syncerLambda.arn
  handler       = "index.handler"
  runtime       = lambdaRuntime
  timeout       = lambdaTimeout
  memorySize    = 256
  architectures = [lambdaArchitecture]
  environment = {
    variables = {
      ENVIRONMENT              = prefix
      GITHUBRUNNERARCHITECTURE = runnerArchitecture
      GITHUBRUNNEROS           = ghBinaryOsLabel[runnerOs]
      LOGLEVEL                 = logLevel
      POWERTOOLSLOGGERLOGEVENT = logLevel == "debug" ? "true" : "false"
      S3BUCKETNAME             = actionDist.id
      S3OBJECTKEY              = actionRunnerDistributionObjectKey
      S3SSEALGORITHM           = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm,null)")
      S3SSEKMSKEYID            = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id,null)")
    }

  }
  tags = tags
}
resource "lambdaKms" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id,null)") != null ? 1 : 0
  }
  name   = "${prefix}-lambda-kms-policy-syncer"
  role   = syncerLambda.id
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-kms.json\",{\nkms_key_arn=var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id\n})")
}
resource "syncerResource" "aws:cloudwatch/logGroup:LogGroup" {
  name            = "/aws/lambda/${syncer.name}"
  retentionInDays = loggingRetentionInDays
  kmsKeyId        = loggingKmsKeyId
  tags            = tags
}
resource "syncerLambda" "aws:iam/role:Role" {
  name                = "${prefix}-action-syncer-lambda-role"
  assumeRolePolicy    = lambdaAssumeRolePolicy.json
  path                = myrolePath
  permissionsBoundary = rolePermissionsBoundary
  tags                = tags
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
resource "lambdaLogging" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-logging-policy-syncer"
  role   = syncerLambda.id
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-cloudwatch.json\",{\nlog_group_arn=aws_cloudwatch_log_group.syncer.arn\n})")
}
resource "lambdaSyncerVpc" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = length(lambdaSubnetIds) > 0 && length(lambdaSecurityGroupIds) > 0 ? 1 : 0
  }
  name = "${prefix}-lambda-syncer-vpc"
  role = syncerLambda.id
  policy = invoke("std:index:file", {
    input = "${module}/policies/lambda-vpc.json"
  }).result
}
resource "syncerResource2" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-syncer-s3-policy"
  role   = syncerLambda.id
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-syncer.json\",{\ns3_resource_arn=\"$${aws_s3_bucket.action_dist.arn}/$${local.action_runner_distribution_object_key}\"\n})")
}
resource "syncerResource3" "aws:cloudwatch/eventRule:EventRule" {
  name               = "${prefix}-syncer-rule"
  scheduleExpression = lambdaScheduleExpression
  tags               = tags
  isEnabled          = enableEventRuleBinariesSyncer
}
resource "syncerResource4" "aws:cloudwatch/eventTarget:EventTarget" {
  rule = syncerResource3.name
  arn  = syncer.arn
}
resource "syncerVpcExecutionRole" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(lambdaSubnetIds) > 0 ? 1 : 0
  }
  role      = syncerLambda.name
  policyArn = "arn:${awsPartition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "syncerResource5" "aws:lambda/permission:Permission" {
  statementId = "AllowExecutionFromCloudWatch"
  action      = "lambda:InvokeFunction"
  function    = syncer.name
  principal   = "events.amazonaws.com"
  sourceArn   = syncerResource3.arn
}
###################################################################################
### Extra trigger to trigger from S3 to execute the lambda after first deployment
###################################################################################

resource "trigger" "aws:s3/bucketObjectv2:BucketObjectv2" {
  bucket = actionDist.id
  key    = "triggers/${syncer.id}-trigger.json"
  source = "${module}/trigger.json"
  etag = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id,null)") == null ? invoke("std:index:filemd5", {
    input = "${module}/trigger.json"
  }).result : null
  kmsKeyId             = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id,null)")
  serverSideEncryption = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm,null)")
}
resource "onDeploy" "aws:s3/bucketNotification:BucketNotification" {
  bucket = actionDist.id
  lambdaFunctions = [{
    lambdaFunctionArn = syncer.arn
    events            = ["s3:ObjectCreated:*"]
    filterPrefix      = "triggers/"
    filterSuffix      = ".json"
  }]
}
current = invoke("aws:index/getCallerIdentity:getCallerIdentity", {})
resource "onDeployResource" "aws:lambda/permission:Permission" {
  statementId   = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function      = syncer.arn
  principal     = "s3.amazonaws.com"
  sourceAccount = current.accountId
  sourceArn     = actionDist.arn
}
