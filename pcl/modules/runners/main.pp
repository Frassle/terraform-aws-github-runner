mytags = notImplemented("merge(\n{\n\"Name\"=format(\"%s-action-runner\",var.prefix)\n},\n{\n\"ghr:ssm_config_path\"=\"$${var.ssm_paths.root}/$${var.ssm_paths.config}\"\n},\nvar.tags,\n)")

nameSg                       = overrides["name_sg"] == "" ? mytags["Name"] : overrides["name_sg"]
nameRunner                   = overrides["name_runner"] == "" ? mytags["Name"] : overrides["name_runner"]
myrolePath                   = rolePath == null ? "/${prefix}/" : rolePath
myinstanceProfilePath        = instanceProfilePath == null ? "/${prefix}/" : instanceProfilePath
mylambdaZip                  = lambdaZip == null ? "${module}/lambdas/runners/runners.zip" : lambdaZip
myuserdataTemplate           = userdataTemplate == null ? defaultUserdataTemplate[runnerOs] : userdataTemplate
mykmsKeyArn                  = kmsKeyArn != null ? kmsKeyArn : ""
s3LocationRunnerDistribution = enableRunnerBinariesSyncer ? "s3://${s3RunnerBinaries.id}/${s3RunnerBinaries.key}" : ""
defaultAmi = {
  "windows" = {
    name = ["Windows_Server-2022-English-Core-ContainersLatest-*"]
  }
  "linux" = runnerArchitecture == "arm64" ? {
    name = ["amzn2-ami-kernel-5.*-hvm-*-arm64-gp2"]
    } : {
    name = ["amzn2-ami-kernel-5.*-hvm-*-x86_64-gp2"]
  }
}

defaultUserdataTemplate = {
  "windows" = "${module}/templates/user-data.ps1"
  "linux"   = "${module}/templates/user-data.sh"
}

userdataInstallRunner = {
  "windows" = "${module}/templates/install-runner.ps1"
  "linux"   = "${module}/templates/install-runner.sh"
}

userdataStartRunner = {
  "windows" = "${module}/templates/start-runner.ps1"
  "linux"   = "${module}/templates/start-runner.sh"
}

myamiKmsKeyArn         = amiKmsKeyArn != null ? amiKmsKeyArn : ""
myamiFilter            = notImplemented("coalesce(var.ami_filter,local.default_ami[var.runner_os])")
myenableJobQueuedCheck = enableJobQueuedCheck == null ? !enableEphemeralRunners : enableJobQueuedCheck
runner = invoke("aws:ec2/getAmi:getAmi", {
  mostRecent = "true"
  owners     = amiOwners
})
resource "runnerResource" "aws:ec2/launchTemplate:LaunchTemplate" {
  name = "${prefix}-action-runner"
  monitoring = {
    enabled = enableRunnerDetailedMonitoring
  }
  iamInstanceProfile = {
    name = runnerResource3.name
  }
  instanceInitiatedShutdownBehavior = "terminate"
  imageId                           = runner.id
  keyName                           = keyName
  vpcSecurityGroupIds               = notImplemented("compact(concat(\nvar.enable_managed_runner_security_group?[aws_security_group.runner_sg[0].id]:[],\nvar.runner_additional_security_group_ids,\n))")
  tagSpecifications = [{
    resourceType = "instance"
    tags         = notImplemented("merge(\nlocal.tags,\n{\n\"Name\"=format(\"%s\",local.name_runner)\n},\n{\n\"ghr:runner_name_prefix\"=var.runner_name_prefix\n},\nvar.runner_ec2_tags\n)")

    }, {
    resourceType = "volume"
    tags         = notImplemented("merge(\nlocal.tags,\n{\n\"Name\"=format(\"%s\",local.name_runner)\n},\n{\n\"ghr:runner_name_prefix\"=var.runner_name_prefix\n},\nvar.runner_ec2_tags\n)")

  }]
  userData = enableUserdata ? invoke("std:index:base64encode", {
    input = notImplemented("templatefile(local.userdata_template,{\nenable_debug_logging=var.enable_user_data_debug_logging\ns3_location_runner_distribution=local.s3_location_runner_distribution\npre_install=var.userdata_pre_install\ninstall_runner=templatefile(local.userdata_install_runner[var.runner_os],{\nS3_LOCATION_RUNNER_DISTRIBUTION=local.s3_location_runner_distribution\nRUNNER_ARCHITECTURE=var.runner_architecture\n})\npost_install=var.userdata_post_install\nstart_runner=templatefile(local.userdata_start_runner[var.runner_os],{\nmetadata_tags=var.metadata_options!=null?var.metadata_options.instance_metadata_tags:\"enabled\"\n})\nghes_url=var.ghes_url\nghes_ssl_verify=var.ghes_ssl_verify\n\n## retain these for backwards compatibility\nenvironment=var.prefix\nenable_cloudwatch_agent=var.enable_cloudwatch_agent\nssm_key_cloudwatch_agent_config=var.enable_cloudwatch_agent?aws_ssm_parameter.cloudwatch_agent_config_runner[0].name:\"\"\n})")
  }).result : ""
  tags                 = mytags
  updateDefaultVersion = true
}
resource "runnerSg" "aws:ec2/securityGroup:SecurityGroup" {
  options {
    range = enableManagedRunnerSecurityGroup ? 1 : 0
  }
  namePrefix  = "${prefix}-github-actions-runner-sg"
  description = "Github Actions Runner security group"
  vpcId       = vpcId
  tags        = notImplemented("merge(\nlocal.tags,\n{\n\"Name\"=format(\"%s\",local.name_sg)\n},\n)")

}
