resource "githubAppId" "aws:ssm/parameter:Parameter" {
  name  = "${pathPrefix}/github_app_id"
  type  = "SecureString"
  value = githubApp.id
  keyId = mykmsKeyArn
  tags  = tags
}
resource "githubAppKeyBase64" "aws:ssm/parameter:Parameter" {
  name  = "${pathPrefix}/github_app_key_base64"
  type  = "SecureString"
  value = githubApp.keyBase64
  keyId = mykmsKeyArn
  tags  = tags
}
resource "githubAppWebhookSecret" "aws:ssm/parameter:Parameter" {
  name  = "${pathPrefix}/github_app_webhook_secret"
  type  = "SecureString"
  value = githubApp.webhookSecret
  keyId = mykmsKeyArn
  tags  = tags
}
