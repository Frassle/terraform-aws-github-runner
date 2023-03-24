config "githubApp" "object({id=string, key_base64=string, webhook_secret=string})" {
  description = "GitHub app parameters, see your github app. Ensure the key is the base64-encoded `.pem` file (the output of `base64 app.private-key.pem`, not the content of `private-key.pem`)."
}
config "environment" "string" {
  description = "A name that identifies the environment, used as prefix and for tagging."
}
config "pathPrefix" "string" {
  description = "The path prefix used for naming resources"
}
config "kmsKeyArn" "string" {
  description = "Optional CMK Key ARN to be used for Parameter Store."
}
config "tags" "map(string)" {
  default     = {}
  description = "Map of tags that will be added to created resources. By default resources will be tagged with name and environment."
}
