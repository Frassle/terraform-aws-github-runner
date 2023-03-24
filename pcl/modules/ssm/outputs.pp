output "parameters" {
  value = {
    github_app_id = {
      name = githubAppId.name
      arn  = githubAppId.arn
    }
    github_app_key_base64 = {
      name = githubAppKeyBase64.name
      arn  = githubAppKeyBase64.arn
    }
    github_app_webhook_secret = {
      name = githubAppWebhookSecret.name
      arn  = githubAppWebhookSecret.arn
    }
  }
}
