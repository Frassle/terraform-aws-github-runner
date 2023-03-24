lambdaAssumeRolePolicy = invoke("aws:iam/getPolicyDocument:getPolicyDocument", {
  statements = [{
    actions = ["sts:AssumeRole"]
    principals = [{
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }]
  }]
})
resource "amiIdSsmParameterRead" "aws:iam/policy:Policy" {
  options {
    range = amiIdSsmParameterName != null ? 1 : 0
  }
  name        = "${prefix}-ami-id-ssm-parameter-read"
  path        = myrolePath
  description = "Allows for reading ${prefix} GitHub runner AMI ID from an SSM parameter"
  policy = "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"ssm:GetParameter\"\n      ],\n      \"Resource\": [\n        \"arn:${awsPartition}:ssm:${awsRegion}:${current.accountId}:parameter/${invoke("std:index:trimprefix", {
    input  = amiIdSsmParameterName
    prefix = "/"
  }).result}\"\n      ]\n    }\n  ]\n}\n"
}
