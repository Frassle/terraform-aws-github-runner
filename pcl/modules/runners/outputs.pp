output "launchTemplate" {
  value = runnerResource
}
output "roleRunner" {
  value = runnerResource2
}
output "lambdaScaleUp" {
  value = scaleUp
}
output "lambdaScaleUpLogGroup" {
  value = scaleUpResource
}
output "roleScaleUp" {
  value = scaleUpResource3
}
output "lambdaScaleDown" {
  value = scaleDown
}
output "lambdaScaleDownLogGroup" {
  value = scaleDownResource
}
output "roleScaleDown" {
  value = scaleDownResource5
}
output "lambdaPool" {
  value = notImplemented("try(module.pool[0].lambda,null)")
}
output "lambdaPoolLogGroup" {
  value = notImplemented("try(module.pool[0].lambda_log_group,null)")
}
output "rolePool" {
  value = notImplemented("try(module.pool[0].role_pool,null)")
}
output "runnersLogGroups" {
  value = notImplemented("try(aws_cloudwatch_log_group.gh_runners,[])")
}
output "logfilesOutput" {
  value = logfiles
}
