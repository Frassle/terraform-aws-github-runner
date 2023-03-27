config "config" "object({ami_id_ssm_parameter_name=string, ami_id_ssm_parameter_read_policy_arn=string, ami_kms_key_arn=string, ghes=object({ssl_verify=string, url=string}), github_app_parameters=object({id=map(string), key_base64=map(string)}), instance_allocation_strategy=string, instance_max_spot_price=string, instance_target_capacity_type=string, instance_types=list(string), kms_key_arn=string, lambda=object({architecture=string, log_level=string, logging_kms_key_id=string, logging_retention_in_days=number, reserved_concurrent_executions=number, runtime=string, s3_bucket=string, s3_key=string, s3_object_version=string, security_group_ids=list(string), subnet_ids=list(string), timeout=number, zip=string}), pool=list(object({schedule_expression=string, size=number})), prefix=string, role_path=string, role_permissions_boundary=string, runner=object({boot_time_in_minutes=number, disable_runner_autoupdate=bool, ephemeral=bool, extra_labels=string, group_name=string, launch_template=object({name=string}), name_prefix=string, pool_owner=string, role=object({arn=string})}), ssm_token_path=string, subnet_ids=list(string), tags=map(string)})" {
}
config "awsPartition" "string" {
  default     = "aws"
  description = "(optional) partition for the arn if not 'aws'"
}