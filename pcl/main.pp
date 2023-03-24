mytags = notImplemented("merge(var.tags,{\n\"ghr:environment\"=var.prefix\n})")
githubAppParameters = {
  id         = ssm.parameters.githubAppId
  key_base64 = ssm.parameters.githubAppKeyBase64
}

defaultRunnerLabels = "self-hosted,${runnerOs},${runnerArchitecture}"
runnerLabels        = runnerExtraLabels != "" ? "${defaultRunnerLabels},${runnerExtraLabels}" : defaultRunnerLabels
ssmRootPath         = ssmPaths.usePrefix ? "/${ssmPaths.root}/${prefix}" : "/${ssmPaths.root}"
resource "random" "random:index/randomString:RandomString" {
  length  = 24
  special = false
  upper   = false
}
denyUnsecureTransport = invoke("aws:iam/getPolicyDocument:getPolicyDocument", {
  statements = [{
    sid    = "DenyUnsecureTransport"
    effect = "Deny"
    principals = [{
      type        = "AWS"
      identifiers = ["*"]
    }]
    actions = ["sqs:*"]


    resources = ["*"]


    conditions = [{
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }]
  }]
})
resource "buildQueuePolicy" "aws:sqs/queuePolicy:QueuePolicy" {
  queueUrl = queuedBuilds.id
  policy   = denyUnsecureTransport.json
}
resource "webhookEventsWorkflowJobQueuePolicy" "aws:sqs/queuePolicy:QueuePolicy" {
  options {
    range = enableWorkflowJobEventsQueue ? 1 : 0
  }
  queueUrl = webhookEventsWorkflowJobQueue[0].id
  policy   = denyUnsecureTransport.json
}
resource "queuedBuilds" "aws:sqs/queue:Queue" {
  name                      = "${prefix}-queued-builds${enableFifoBuildQueue ? ".fifo" : ""}"
  delaySeconds              = delayWebhookEvent
  visibilityTimeoutSeconds  = runnersScaleUpLambdaTimeout
  messageRetentionSeconds   = jobQueueRetentionInSeconds
  fifoQueue                 = enableFifoBuildQueue
  receiveWaitTimeSeconds    = 0
  contentBasedDeduplication = enableFifoBuildQueue
  redrivePolicy = redriveBuildQueue.enabled ? toJSON({
    deadLetterTargetArn = queuedBuildsDlq[0].arn
    maxReceiveCount     = redriveBuildQueue.maxReceiveCount
  }) : null
  sqsManagedSseEnabled         = queueEncryption.sqsManagedSseEnabled
  kmsMasterKeyId               = queueEncryption.kmsMasterKeyId
  kmsDataKeyReusePeriodSeconds = queueEncryption.kmsDataKeyReusePeriodSeconds
  tags                         = tags
}
resource "webhookEventsWorkflowJobQueue" "aws:sqs/queue:Queue" {
  options {
    range = enableWorkflowJobEventsQueue ? 1 : 0
  }
  name                         = "${prefix}-webhook_events_workflow_job_queue"
  delaySeconds                 = workflowJobQueueConfiguration.delaySeconds
  visibilityTimeoutSeconds     = workflowJobQueueConfiguration.visibilityTimeoutSeconds
  messageRetentionSeconds      = workflowJobQueueConfiguration.messageRetentionSeconds
  fifoQueue                    = false
  receiveWaitTimeSeconds       = 0
  contentBasedDeduplication    = false
  redrivePolicy                = null
  sqsManagedSseEnabled         = queueEncryption.sqsManagedSseEnabled
  kmsMasterKeyId               = queueEncryption.kmsMasterKeyId
  kmsDataKeyReusePeriodSeconds = queueEncryption.kmsDataKeyReusePeriodSeconds
  tags                         = tags
}
resource "buildQueueDlqPolicy" "aws:sqs/queuePolicy:QueuePolicy" {
  options {
    range = redriveBuildQueue.enabled ? 1 : 0
  }
  queueUrl = queuedBuilds.id
  policy   = denyUnsecureTransport.json
}
resource "queuedBuildsDlq" "aws:sqs/queue:Queue" {
  options {
    range = redriveBuildQueue.enabled ? 1 : 0
  }
  name                         = "${prefix}-queued-builds_dead_letter${enableFifoBuildQueue ? ".fifo" : ""}"
  sqsManagedSseEnabled         = queueEncryption.sqsManagedSseEnabled
  kmsMasterKeyId               = queueEncryption.kmsMasterKeyId
  kmsDataKeyReusePeriodSeconds = queueEncryption.kmsDataKeyReusePeriodSeconds
  fifoQueue                    = enableFifoBuildQueue
  tags                         = tags
}
component "ssm" "./modules/ssm" {
  kmsKeyArn  = kmsKeyArn
  pathPrefix = "${ssmRootPath}/${ssmPaths.app}"
  githubApp  = githubApp
  tags       = mytags
}
component "webhook" "./modules/webhook" {
  prefix    = prefix
  tags      = mytags
  kmsKeyArn = kmsKeyArn
  runnerConfig = {
    (queuedBuilds.id) = {
      id   = queuedBuilds.id
      arn  = queuedBuilds.arn
      fifo = enableFifoBuildQueue
      matcherConfig = {
        labelMatchers = [invoke("std:index:split", {
          separator = ","
          text      = runnerLabels
        }).result]
        exactMatch = enableRunnerWorkflowJobLabelsCheckAll
      }
    }
  }

  sqsWorkflowJobQueue = length(webhookEventsWorkflowJobQueue) > 0 ? webhookEventsWorkflowJobQueue[0] : null
  githubAppParameters = {
    webhookSecret = ssm.parameters.githubAppWebhookSecret
  }

  lambdaS3Bucket                           = lambdaS3Bucket
  webhookLambdaS3Key                       = webhookLambdaS3Key
  webhookLambdaS3ObjectVersion             = webhookLambdaS3ObjectVersion
  webhookLambdaApigatewayAccessLogSettings = webhookLambdaApigatewayAccessLogSettings
  lambdaRuntime                            = lambdaRuntime
  lambdaArchitecture                       = lambdaArchitecture
  lambdaZip                                = webhookLambdaZip
  lambdaTimeout                            = webhookLambdaTimeout
  loggingRetentionInDays                   = loggingRetentionInDays
  loggingKmsKeyId                          = loggingKmsKeyId
  rolePath                                 = rolePath
  rolePermissionsBoundary                  = rolePermissionsBoundary
  repositoryWhiteList                      = repositoryWhiteList
  lambdaSubnetIds                          = lambdaSubnetIds
  lambdaSecurityGroupIds                   = lambdaSecurityGroupIds
  awsPartition                             = awsPartition
  logLevel                                 = logLevel
}
component "runners" "./modules/runners" {
  awsRegion    = awsRegion
  awsPartition = awsPartition
  vpcId        = vpcId
  subnetIds    = subnetIds
  prefix       = prefix
  tags         = mytags
  ssmPaths = {
    root   = ssmRootPath
    tokens = "${ssmPaths.runners}/tokens"
    config = "${ssmPaths.runners}/config"
  }

  s3RunnerBinaries = enableRunnerBinariesSyncer ? {
    arn = runnerBinaries[0].bucket.arn
    id  = runnerBinaries[0].bucket.id
    key = runnerBinaries[0].runnerDistributionObjectKey
  } : null
  runnerOs                               = runnerOs
  instanceTypes                          = instanceTypes
  instanceTargetCapacityType             = instanceTargetCapacityType
  instanceAllocationStrategy             = instanceAllocationStrategy
  instanceMaxSpotPrice                   = instanceMaxSpotPrice
  blockDeviceMappings                    = blockDeviceMappings
  runnerArchitecture                     = runnerArchitecture
  amiFilter                              = amiFilter
  amiOwners                              = amiOwners
  amiIdSsmParameterName                  = amiIdSsmParameterName
  amiKmsKeyArn                           = amiKmsKeyArn
  sqsBuildQueue                          = queuedBuilds
  githubAppParameters                    = githubAppParameters
  enableOrganizationRunners              = enableOrganizationRunners
  enableEphemeralRunners                 = enableEphemeralRunners
  enableJobQueuedCheck                   = enableJobQueuedCheck
  disableRunnerAutoupdate                = disableRunnerAutoupdate
  enableManagedRunnerSecurityGroup       = enableManagedRunnerSecurityGroup
  enableRunnerDetailedMonitoring         = enableRunnerDetailedMonitoring
  scaleDownScheduleExpression            = scaleDownScheduleExpression
  minimumRunningTimeInMinutes            = minimumRunningTimeInMinutes
  runnerBootTimeInMinutes                = runnerBootTimeInMinutes
  runnerExtraLabels                      = runnerExtraLabels
  runnerAsRoot                           = runnerAsRoot
  runnerRunAs                            = runnerRunAs
  runnersMaximumCount                    = runnersMaximumCount
  idleConfig                             = idleConfig
  enableSsmOnRunners                     = enableSsmOnRunners
  egressRules                            = runnerEgressRules
  runnerAdditionalSecurityGroupIds       = runnerAdditionalSecurityGroupIds
  metadataOptions                        = runnerMetadataOptions
  enableRunnerBinariesSyncer             = enableRunnerBinariesSyncer
  lambdaS3Bucket                         = lambdaS3Bucket
  runnersLambdaS3Key                     = runnersLambdaS3Key
  runnersLambdaS3ObjectVersion           = runnersLambdaS3ObjectVersion
  lambdaRuntime                          = lambdaRuntime
  lambdaArchitecture                     = lambdaArchitecture
  lambdaZip                              = runnersLambdaZip
  lambdaTimeoutScaleUp                   = runnersScaleUpLambdaTimeout
  lambdaTimeoutScaleDown                 = runnersScaleDownLambdaTimeout
  lambdaSubnetIds                        = lambdaSubnetIds
  lambdaSecurityGroupIds                 = lambdaSecurityGroupIds
  loggingRetentionInDays                 = loggingRetentionInDays
  loggingKmsKeyId                        = loggingKmsKeyId
  enableCloudwatchAgent                  = enableCloudwatchAgent
  cloudwatchConfig                       = cloudwatchConfig
  runnerLogFiles                         = runnerLogFiles
  runnerGroupName                        = runnerGroupName
  runnerNamePrefix                       = runnerNamePrefix
  scaleUpReservedConcurrentExecutions    = scaleUpReservedConcurrentExecutions
  instanceProfilePath                    = instanceProfilePath
  rolePath                               = rolePath
  rolePermissionsBoundary                = rolePermissionsBoundary
  enableUserdata                         = enableUserdata
  enableUserDataDebugLogging             = enableUserDataDebugLoggingRunner
  userdataTemplate                       = userdataTemplate
  userdataPreInstall                     = userdataPreInstall
  userdataPostInstall                    = userdataPostInstall
  keyName                                = keyName
  runnerEc2Tags                          = runnerEc2Tags
  createServiceLinkedRoleSpot            = createServiceLinkedRoleSpot
  runnerIamRoleManagedPolicyArns         = runnerIamRoleManagedPolicyArns
  ghesUrl                                = ghesUrl
  ghesSslVerify                          = ghesSslVerify
  kmsKeyArn                              = kmsKeyArn
  logLevel                               = logLevel
  poolConfig                             = poolConfig
  poolLambdaTimeout                      = poolLambdaTimeout
  poolRunnerOwner                        = poolRunnerOwner
  poolLambdaReservedConcurrentExecutions = poolLambdaReservedConcurrentExecutions
}
component "runnerBinaries" "./modules/runner-binaries-syncer" {
  options {
    range = enableRunnerBinariesSyncer ? 1 : 0
  }
  prefix                            = prefix
  tags                              = mytags
  distributionBucketName            = "${prefix}-dist-${random.result}"
  s3LoggingBucket                   = runnerBinariesS3LoggingBucket
  s3LoggingBucketPrefix             = runnerBinariesS3LoggingBucketPrefix
  runnerOs                          = runnerOs
  runnerArchitecture                = runnerArchitecture
  runnerAllowPrereleaseBinaries     = runnerAllowPrereleaseBinaries
  lambdaS3Bucket                    = lambdaS3Bucket
  syncerLambdaS3Key                 = syncerLambdaS3Key
  syncerLambdaS3ObjectVersion       = syncerLambdaS3ObjectVersion
  lambdaRuntime                     = lambdaRuntime
  lambdaArchitecture                = lambdaArchitecture
  lambdaZip                         = runnerBinariesSyncerLambdaZip
  lambdaTimeout                     = runnerBinariesSyncerLambdaTimeout
  loggingRetentionInDays            = loggingRetentionInDays
  loggingKmsKeyId                   = loggingKmsKeyId
  enableEventRuleBinariesSyncer     = enableEventRuleBinariesSyncer
  serverSideEncryptionConfiguration = runnerBinariesS3SseConfiguration
  rolePath                          = rolePath
  rolePermissionsBoundary           = rolePermissionsBoundary
  logLevel                          = logLevel
  lambdaSubnetIds                   = lambdaSubnetIds
  lambdaSecurityGroupIds            = lambdaSecurityGroupIds
  awsPartition                      = awsPartition
  lambdaPrincipals                  = lambdaPrincipals
}
