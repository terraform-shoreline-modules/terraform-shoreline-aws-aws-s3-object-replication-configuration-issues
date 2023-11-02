resource "shoreline_notebook" "issues_with_amazon_s3_object_replication_configuration" {
  name       = "issues_with_amazon_s3_object_replication_configuration"
  data       = file("${path.module}/data/issues_with_amazon_s3_object_replication_configuration.json")
  depends_on = [shoreline_action.invoke_set_bucket_replication]
}

resource "shoreline_file" "set_bucket_replication" {
  name             = "set_bucket_replication"
  input_file       = "${path.module}/data/set_bucket_replication.sh"
  md5              = filemd5("${path.module}/data/set_bucket_replication.sh")
  description      = "Update or Verify that the ARN of the destination bucket is correct in the replication configuration on the source bucket."
  destination_path = "/tmp/set_bucket_replication.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_set_bucket_replication" {
  name        = "invoke_set_bucket_replication"
  description = "Update or Verify that the ARN of the destination bucket is correct in the replication configuration on the source bucket."
  command     = "`chmod +x /tmp/set_bucket_replication.sh && /tmp/set_bucket_replication.sh`"
  params      = ["BUCKET_NAME","DESTINATION_BUCKET_ARN","REPLICATION_ROLE_ARN"]
  file_deps   = ["set_bucket_replication"]
  enabled     = true
  depends_on  = [shoreline_file.set_bucket_replication]
}

