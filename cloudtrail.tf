resource "aws_cloudtrail" "cloudtrail" {
  name                          = "demo-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.demo_cloudtrail_bucket.bucket
  kms_key_id                    = aws_kms_key.demo_cloudtrail_bucket_key.arn
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = [
      "kms.amazonaws.com",
      "rdsdata.amazonaws.com"
    ]
  }
}