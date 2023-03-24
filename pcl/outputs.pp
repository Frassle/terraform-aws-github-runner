output "runnersOutput" {
  value = {
    launch_template_name    = runners.launchTemplate.name
    launch_template_id      = runners.launchTemplate.id
    launch_template_version = runners.launchTemplate.latestVersion
    launch_template_ami_id  = runners.launchTemplate.imageId
    lambda_up               = runners.lambdaScaleUp
    lambda_up_log_group     = runners.lambdaScaleUpLogGroup
    lambda_down             = runners.lambdaScaleDown
    lambda_down_log_group   = runners.lambdaScaleDownLogGroup
    lambda_pool             = runners.lambdaPool
    lambda_pool_log_group   = runners.lambdaPoolLogGroup
    role_runner             = runners.roleRunner
    role_scale_up           = runners.roleScaleUp
    role_scale_down         = runners.roleScaleDown
    role_pool               = runners.rolePool
    runners_log_groups      = runners.runnersLogGroups
    labels = invoke("std:index:sort", {
      input = invoke("std:index:split", {
        separator = ","
        text      = runnerLabels
      }).result
    }).result
    logfiles = runners.logfiles
  }
}
output "binariesSyncer" {
  value = enableRunnerBinariesSyncer ? {
    lambda           = runnerBinaries[0].lambda
    lambda_log_group = runnerBinaries[0].lambdaLogGroup
    lambda_role      = runnerBinaries[0].lambdaRole
    location         = "s3://${runnerBinaries[0].bucket.id}/module.runner_binaries[0].bucket.key"
    bucket           = runnerBinaries[0].bucket
  } : null
}
output "webhookOutput" {
  value = {
    gateway          = webhook.gateway
    lambda           = webhook.lambda
    lambda_log_group = webhook.lambdaLogGroup
    lambda_role      = webhook.role
    endpoint         = "${webhook.gateway.apiEndpoint}/${webhook.endpointRelativePath}"
  }
}
output "ssmParameters" {
  value = ssm.parameters
}
output "queues" {
  value = {
    build_queue_arn            = queuedBuilds.arn
    build_queue_dlq_arn        = redriveBuildQueue.enabled ? queuedBuildsDlq[0].arn : null
    webhook_workflow_job_queue = notImplemented("try(aws_sqs_queue.webhook_events_workflow_job_queue[0],null)") != null ? webhookEventsWorkflowJobQueue[0].arn : ""
  }
}
