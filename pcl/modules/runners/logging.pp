myrunnerLogFiles = (runnerLogFiles != null ? runnerLogFiles : [{
  "prefix_log_group" = true
  "file_path"        = "/var/log/messages"
  "log_group_name"   = "messages"
  "log_stream_name"  = "{instance_id}"
  }, {
  "log_group_name"   = "user_data"
  "prefix_log_group" = true
  "file_path"        = runnerOs == "windows" ? "C:/UserData.log" : "/var/log/user-data.log"
  "log_stream_name"  = "{instance_id}"
  }, {
  "log_group_name"   = "runner"
  "prefix_log_group" = true
  "file_path"        = runnerOs == "windows" ? "C:/actions-runner/_diag/Runner_*.log" : "/opt/actions-runner/_diag/Runner_**.log"
  "log_stream_name"  = "{instance_id}"
  }, {
  "log_group_name"   = "runner-startup"
  "prefix_log_group" = true
  "file_path"        = runnerOs == "windows" ? "C:/runner-startup.log" : "/var/log/runner-startup.log"
  "log_stream_name"  = "{instance_id}"
  }]
)

logfiles = enableCloudwatchAgent ? [for l in myrunnerLogFiles : {
  "log_group_name"  = l.prefixLogGroup ? "/github-self-hosted-runners/${prefix}/${l.logGroupName}" : "/${l.logGroupName}"
  "log_stream_name" = l.logStreamName
  "file_path"       = l.filePath
}] : []
loggroupsNames = notImplemented("distinct([forlinlocal.logfiles:l.log_group_name])")
resource "cloudwatchAgentConfigRunner" "aws:ssm/parameter:Parameter" {
  options {
    range = enableCloudwatchAgent ? 1 : 0
  }
  name  = "${ssmPaths.root}/${ssmPaths.config}/cloudwatch_agent_config_runner"
  type  = "String"
  value = cloudwatchConfig != null ? cloudwatchConfig : notImplemented("templatefile(\"$${path.module}/templates/cloudwatch_config.json\",{\nlogfiles=jsonencode(local.logfiles)\n})")
  tags  = mytags
}
resource "ghRunners" "aws:cloudwatch/logGroup:LogGroup" {
  options {
    range = length(loggroupsNames)
  }
  name            = loggroupsNames[range.value]
  retentionInDays = loggingRetentionInDays
  kmsKeyId        = loggingKmsKeyId
  tags            = mytags
}
resource "cloudwatch" "aws:iam/rolePolicy:RolePolicy" {
  options {
    range = enableCloudwatchAgent ? 1 : 0
  }
  name   = "CloudWatchLogginAndMetrics"
  role   = runnerResource2.name
  policy = notImplemented("templatefile(\"$${path.module}/policies/instance-cloudwatch-policy.json\",\n{\nssm_parameter_arn=aws_ssm_parameter.cloudwatch_agent_config_runner[0].arn\n}\n)")

}
