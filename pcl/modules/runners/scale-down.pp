# Windows Runners can take their sweet time to do anything
minRuntimeDefaults = {
  "windows" = 15
  "linux"   = 5
}
# Windows Runners can take their sweet time to do anything

resource "scaleDown" "aws:lambda/function:Function" {
  s3Bucket        = lambdaS3Bucket != null ? lambdaS3Bucket : null
  s3Key           = runnersLambdaS3Key != null ? runnersLambdaS3Key : null
  s3ObjectVersion = runnersLambdaS3ObjectVersion != null ? runnersLambdaS3ObjectVersion : null
  code            = lambdaS3Bucket == null ? mylambdaZip : null
  sourceCodeHash = lambdaS3Bucket == null ? invoke("std:index:filebase64sha256", {
    input = mylambdaZip
  }).result : null
  name          = "${prefix}-scale-down"
  role          = scaleDownResource5.arn
  handler       = "index.scaleDownHandler"
  runtime       = lambdaRuntime
  timeout       = lambdaTimeoutScaleDown
  tags          = mytags
  memorySize    = 512
  architectures = [lambdaArchitecture]
  environment = {
    variables = {
      ENVIRONMENT                     = prefix
      GHESURL                         = ghesUrl
      LOGLEVEL                        = logLevel
      MINIMUMRUNNINGTIMEINMINUTES     = notImplemented("coalesce(var.minimum_running_time_in_minutes,local.min_runtime_defaults[var.runner_os])")
      NODETLSREJECTUNAUTHORIZED       = ghesUrl != null && !ghesSslVerify ? 0 : 1
      PARAMETERGITHUBAPPIDNAME        = githubAppParameters.id.name
      PARAMETERGITHUBAPPKEYBASE64NAME = githubAppParameters.keyBase64.name
      POWERTOOLSLOGGERLOGEVENT        = logLevel == "debug" ? "true" : "false"
      RUNNERBOOTTIMEINMINUTES         = runnerBootTimeInMinutes
      SCALEDOWNCONFIG                 = toJSON(idleConfig)
      SERVICENAME                     = "runners-scale-up"
    }

  }
}
resource "scaleDownResource" "aws:cloudwatch/logGroup:LogGroup" {
  name            = "/aws/lambda/${scaleDown.name}"
  retentionInDays = loggingRetentionInDays
  kmsKeyId        = loggingKmsKeyId
  tags            = tags
}
resource "scaleDownResource2" "aws:cloudwatch/eventRule:EventRule" {
  name               = "${prefix}-scale-down-rule"
  scheduleExpression = scaleDownScheduleExpression
  tags               = tags
}
resource "scaleDownResource3" "aws:cloudwatch/eventTarget:EventTarget" {
  rule = scaleDownResource2.name
  arn  = scaleDown.arn
}
resource "scaleDownResource4" "aws:lambda/permission:Permission" {
  statementId = "AllowExecutionFromCloudWatch"
  action      = "lambda:InvokeFunction"
  function    = scaleDown.name
  principal   = "events.amazonaws.com"
  sourceArn   = scaleDownResource2.arn
}
resource "scaleDownResource5" "aws:iam/role:Role" {
  name                = "${prefix}-action-scale-down-lambda-role"
  assumeRolePolicy    = lambdaAssumeRolePolicy.json
  path                = myrolePath
  permissionsBoundary = rolePermissionsBoundary
  tags                = mytags
}
resource "scaleDownResource6" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-scale-down-policy"
  role   = scaleDownResource5.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-scale-down.json\",{\ngithub_app_id_arn=var.github_app_parameters.id.arn\ngithub_app_key_base64_arn=var.github_app_parameters.key_base64.arn\nkms_key_arn=local.kms_key_arn\n})")
}
resource "scaleDownLogging" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-logging"
  role   = scaleDownResource5.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-cloudwatch.json\",{\nlog_group_arn=aws_cloudwatch_log_group.scale_down.arn\n})")
}
resource "lambdaScaleDownVpc" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = length(lambdaSubnetIds) > 0 && length(lambdaSecurityGroupIds) > 0 ? 1 : 0
  }
  name = "${prefix}-lambda-scale-down-vpc"
  role = scaleDownResource5.id
  policy = invoke("std:index:file", {
    input = "${module}/policies/lambda-vpc.json"
  }).result
}
resource "scaleDownVpcExecutionRole" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(lambdaSubnetIds) > 0 ? 1 : 0
  }
  role      = scaleDownResource5.name
  policyArn = "arn:${awsPartition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
