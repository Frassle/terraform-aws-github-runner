webhookEndpoint = "webhook"
myrolePath      = rolePath == null ? "/${prefix}/" : rolePath
mylambdaZip     = lambdaZip == null ? "${module}/lambdas/webhook/webhook.zip" : lambdaZip
resource "webhook" "aws:apigatewayv2/api:Api" {
  name         = "${prefix}-github-action-webhook"
  protocolType = "HTTP"
  tags         = tags
}
resource "webhookResource" "aws:apigatewayv2/route:Route" {
  apiId    = webhook.id
  routeKey = "POST /${webhookEndpoint}"
  target   = "integrations/${webhookResource3.id}"
}
resource "webhookResource2" "aws:apigatewayv2/stage:Stage" {
  apiId      = webhook.id
  name       = "$default"
  autoDeploy = true
  tags       = tags
}
resource "webhookResource3" "aws:apigatewayv2/integration:Integration" {
  apiId             = webhook.id
  integrationType   = "AWS_PROXY"
  connectionType    = "INTERNET"
  description       = "GitHub App webhook for receiving build events."
  integrationMethod = "POST"
  integrationUri    = webhookResource4.invokeArn
}
