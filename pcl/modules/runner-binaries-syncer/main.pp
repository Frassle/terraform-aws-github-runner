actionRunnerDistributionObjectKey = "actions-runner-${runnerOs}.${runnerOs == "linux" ? "tar.gz" : "zip"}"
resource "actionDist" "aws:s3/bucketV2:BucketV2" {
  bucket       = distributionBucketName
  forceDestroy = true
  tags         = tags
}
resource "actionDistAcl" "aws:s3/bucketAclV2:BucketAclV2" {
  bucket = actionDist.id
  acl    = "private"
}
resource "bucket-config" "aws:s3/bucketLifecycleConfigurationV2:BucketLifecycleConfigurationV2" {
  bucket = actionDist.id
  rules = [{
    id     = "lifecycle_config"
    status = "Enabled"
    abortIncompleteMultipartUpload = {
      daysAfterInitiation = 7
    }
    transitions = [{
      days         = 35
      storageClass = "INTELLIGENT_TIERING"
    }]
  }]
}
resource "actionDistResource" "aws:s3/bucketServerSideEncryptionConfigurationV2:BucketServerSideEncryptionConfigurationV2" {
  options {
    range = notImplemented("try(var.server_side_encryption_configuration,null)") != null ? 1 : 0
  }
  bucket = actionDist.id
}
resource "actionDistResource2" "aws:s3/bucketPublicAccessBlock:BucketPublicAccessBlock" {
  bucket                = actionDist.id
  blockPublicAcls       = true
  blockPublicPolicy     = true
  ignorePublicAcls      = true
  restrictPublicBuckets = true
}
resource "actionDistLogging" "aws:s3/bucketLoggingV2:BucketLoggingV2" {
  options {
    range = s3LoggingBucket != null ? 1 : 0
  }
  bucket       = actionDist.id
  targetBucket = s3LoggingBucket
  targetPrefix = s3LoggingBucketPrefix != null ? s3LoggingBucketPrefix : distributionBucketName
}
actionDistSsePolicy = [for __index in range(notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default,null)") != null ? 1 : 0) : invoke("aws:iam/getPolicyDocument:getPolicyDocument", {
  statements = [{
    effect = "Deny"
    principals = [{
      type        = "AWS"
      identifiers = ["*"]


    }]
    actions = ["s3:PutObject"]


    resources = ["${actionDist.arn}/*"]


    conditions = [{
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = [serverSideEncryptionConfiguration.rule.applyServerSideEncryptionByDefault.sseAlgorithm]
    }]
  }]
})]
resource "actionDistSsePolicyResource" "aws:s3/bucketPolicy:BucketPolicy" {
  options {
    range = notImplemented("try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default,null)") != null ? 1 : 0
  }
  bucket = actionDist.id
  policy = actionDistSsePolicy[0].json
}
