resource "webhookResource4" "aws:lambda/function:Function" {
  s3Bucket        = lambdaS3Bucket != null ? lambdaS3Bucket : null
  s3Key           = webhookLambdaS3Key != null ? webhookLambdaS3Key : null
  s3ObjectVersion = webhookLambdaS3ObjectVersion != null ? webhookLambdaS3ObjectVersion : null
  code            = lambdaS3Bucket == null ? mylambdaZip : null
  sourceCodeHash = lambdaS3Bucket == null ? invoke("std:index:filebase64sha256", {
    input = mylambdaZip
  }).result : null
  name          = "${prefix}-webhook"
  role          = webhookLambda.arn
  handler       = "index.githubWebhook"
  runtime       = lambdaRuntime
  timeout       = lambdaTimeout
  architectures = [lambdaArchitecture]
  environment = {
    variables = {
      ENVIRONMENT                     = prefix
      LOGLEVEL                        = logLevel
      POWERTOOLSLOGGERLOGEVENT        = logLevel == "debug" ? "true" : "false"
      PARAMETERGITHUBAPPWEBHOOKSECRET = githubAppParameters.webhookSecret.name
      REPOSITORYWHITELIST             = toJSON(repositoryWhiteList)
      RUNNERCONFIG                    = toJSON([for k, v in runnerConfig : v])
      SQSWORKFLOWJOBQUEUE             = notImplemented("try(var.sqs_workflow_job_queue,null)") != null ? sqsWorkflowJobQueue.id : ""
    }

  }
  tags = tags
}
resource "webhookResource5" "aws:cloudwatch/logGroup:LogGroup" {
  name            = "/aws/lambda/${webhookResource4.name}"
  retentionInDays = loggingRetentionInDays
  kmsKeyId        = loggingKmsKeyId
  tags            = tags
}
resource "webhookResource6" "aws:lambda/permission:Permission" {
  statementId = "AllowExecutionFromAPIGateway"
  action      = "lambda:InvokeFunction"
  function    = webhookResource4.name
  principal   = "apigateway.amazonaws.com"
  sourceArn   = "${webhook.executionArn}/*/*/${webhookEndpoint}"
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
resource "webhookLambda" "aws:iam/role:Role" {
  name                = "${prefix}-action-webhook-lambda-role"
  assumeRolePolicy    = lambdaAssumeRolePolicy.json
  path                = myrolePath
  permissionsBoundary = rolePermissionsBoundary
  tags                = tags
}
resource "webhookLogging" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-logging-policy"
  role   = webhookLambda.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-cloudwatch.json\",{\nlog_group_arn=aws_cloudwatch_log_group.webhook.arn\n})")
}
resource "webhookVpcExecutionRole" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(lambdaSubnetIds) > 0 ? 1 : 0
  }
  role      = webhookLambda.name
  policyArn = "arn:${awsPartition}:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "webhookSqs" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-webhook-publish-sqs-policy"
  role   = webhookLambda.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-publish-sqs-policy.json\",{\nsqs_resource_arns=jsonencode([fork,vinvar.runner_config:v.arn])\n})")
}
resource "webhookWorkflowJobSqs" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = sqsWorkflowJobQueue != null ? 1 : 0
  }
  name   = "${prefix}-lambda-webhook-publish-workflow-job-sqs-policy"
  role   = webhookLambda.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-publish-sqs-policy.json\",{\nsqs_resource_arns=jsonencode([var.sqs_workflow_job_queue.arn])\n})")
}
resource "webhookSsm" "aws:iam/rolePolicy:RolePolicy" {
  name   = "${prefix}-lambda-webhook-publish-ssm-policy"
  role   = webhookLambda.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/lambda-ssm.json\",{\ngithub_app_webhook_secret_arn=var.github_app_parameters.webhook_secret.arn,\nkms_key_arn=var.kms_key_arn!=null?var.kms_key_arn:\"\"\n})")
}
