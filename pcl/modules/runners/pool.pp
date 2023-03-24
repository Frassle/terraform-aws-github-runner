component "pool" "./pool" {
  options {
    range = length(poolConfig) == 0 ? 0 : 1
  }
  config = {
    prefix = prefix
    ghes = {
      sslVerify = ghesSslVerify
      url       = ghesUrl
    }
    githubAppParameters        = githubAppParameters
    instanceAllocationStrategy = instanceAllocationStrategy
    instanceMaxSpotPrice       = instanceMaxSpotPrice
    instanceTargetCapacityType = instanceTargetCapacityType
    instanceTypes              = instanceTypes
    kmsKeyArn                  = mykmsKeyArn
    amiKmsKeyArn               = myamiKmsKeyArn
    lambda = {
      logLevel                     = logLevel
      loggingRetentionInDays       = loggingRetentionInDays
      loggingKmsKeyId              = loggingKmsKeyId
      reservedConcurrentExecutions = poolLambdaReservedConcurrentExecutions
      s3Bucket                     = lambdaS3Bucket
      s3Key                        = runnersLambdaS3Key
      s3ObjectVersion              = runnersLambdaS3ObjectVersion
      securityGroupIds             = lambdaSecurityGroupIds
      subnetIds                    = lambdaSubnetIds
      architecture                 = lambdaArchitecture
      runtime                      = lambdaRuntime
      timeout                      = poolLambdaTimeout
      zip                          = mylambdaZip
    }
    pool                    = poolConfig
    rolePath                = myrolePath
    rolePermissionsBoundary = rolePermissionsBoundary
    runner = {
      disableRunnerAutoupdate = disableRunnerAutoupdate
      ephemeral               = enableEphemeralRunners
      bootTimeInMinutes       = runnerBootTimeInMinutes
      extraLabels             = runnerExtraLabels
      launchTemplate          = runnerResource
      groupName               = runnerGroupName
      namePrefix              = runnerNamePrefix
      poolOwner               = poolRunnerOwner
      role                    = runnerResource2
    }
    subnetIds                      = subnetIds
    ssmTokenPath                   = "${ssmPaths.root}/${ssmPaths.tokens}"
    amiIdSsmParameterName          = amiIdSsmParameterName
    amiIdSsmParameterReadPolicyArn = amiIdSsmParameterName != null ? amiIdSsmParameterRead[0].arn : null
    tags                           = mytags
  }

  awsPartition = awsPartition
}
