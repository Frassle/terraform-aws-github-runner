resource "runnerConfigRunAs" "aws:ssm/parameter:Parameter" {
  name  = "${ssmPaths.root}/${ssmPaths.config}/run_as"
  type  = "String"
  value = runnerAsRoot ? "root" : runnerRunAs
  tags  = mytags
}
resource "runnerAgentMode" "aws:ssm/parameter:Parameter" {
  name  = "${ssmPaths.root}/${ssmPaths.config}/agent_mode"
  type  = "String"
  value = enableEphemeralRunners ? "ephemeral" : "persistent"
  tags  = mytags
}
resource "runnerEnableCloudwatch" "aws:ssm/parameter:Parameter" {
  name  = "${ssmPaths.root}/${ssmPaths.config}/enable_cloudwatch"
  type  = "String"
  value = enableCloudwatchAgent
  tags  = mytags
}
resource "tokenPath" "aws:ssm/parameter:Parameter" {
  name  = "${ssmPaths.root}/${ssmPaths.config}/token_path"
  type  = "String"
  value = "${ssmPaths.root}/${ssmPaths.tokens}"
  tags  = mytags
}
