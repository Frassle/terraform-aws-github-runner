current = invoke("aws:index/getCallerIdentity:getCallerIdentity", {})
resource "runnerResource2" "aws:iam/role:Role" {
  name                = "${prefix}-runner-role"
  assumeRolePolicy    = notImplemented("templatefile(\"$${path.module}/policies/instance-role-trust-policy.json\",{})")
  path                = myrolePath
  permissionsBoundary = rolePermissionsBoundary
  tags                = mytags
}
resource "runnerResource3" "aws:iam/instanceProfile:InstanceProfile" {
  name = "${prefix}-runner-profile"
  role = runnerResource2.name
  path = myinstanceProfilePath
}
resource "runnerSessionManagerAwsManaged" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = enableSsmOnRunners ? 1 : 0
  }
  name   = "runner-ssm-session"
  role   = runnerResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/instance-ssm-policy.json\",{})")
}
resource "ssmParameters" "aws:iam/rolePolicy:RolePolicy" {
  name   = "runner-ssm-parameters"
  role   = runnerResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/instance-ssm-parameters-policy.json\",\n{\narn_ssm_parameters_path_tokens=\"arn:$${var.aws_partition}:ssm:$${var.aws_region}:$${data.aws_caller_identity.current.account_id}:parameter$${var.ssm_paths.root}/$${var.ssm_paths.tokens}\"\narn_ssm_parameters_path_config=\"arn:$${var.aws_partition}:ssm:$${var.aws_region}:$${data.aws_caller_identity.current.account_id}:parameter$${var.ssm_paths.root}/$${var.ssm_paths.config}\"\n}\n)")

}
resource "distBucket" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = enableRunnerBinariesSyncer ? 1 : 0
  }
  name   = "distribution-bucket"
  role   = runnerResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/instance-s3-policy.json\",\n{\ns3_arn=\"$${var.s3_runner_binaries.arn}/$${var.s3_runner_binaries.key}\"\n}\n)")

}
resource "describeTags" "aws:iam/rolePolicy:RolePolicy" {
  name = "runner-describe-tags"
  role = runnerResource2.name
  policy = invoke("std:index:file", {
    input = "${module}/policies/instance-describe-tags-policy.json"
  }).result
}
resource "managedPolicies" "aws:iam/rolePolicyAttachment:RolePolicyAttachment" {
  options {
    range = length(runnerIamRoleManagedPolicyArns)
  }
  role      = runnerResource2.name
  policyArn = notImplemented("element(var.runner_iam_role_managed_policy_arns,count.index)")
}
resource "ec2" "aws:iam/rolePolicy:RolePolicy" {
  name   = "ec2"
  role   = runnerResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/instance-ec2.json\",{})")
}
