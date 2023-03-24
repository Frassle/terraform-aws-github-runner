output "bucket" {
  value = actionDist
}
output "runnerDistributionObjectKey" {
  value = actionRunnerDistributionObjectKey
}
output "lambda" {
  value = syncer
}
output "lambdaLogGroup" {
  value = syncerResource
}
output "lambdaRole" {
  value = syncerLambda
}
