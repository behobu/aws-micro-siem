resource "aws_s3_bucket" "demo_cloudtrail_bucket" {
  bucket = "bsides-lv2023-spcnkq-demo-cloudtrail-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "demo_cloudtrail_bucket_ownership" {
  bucket = aws_s3_bucket.demo_cloudtrail_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "demo_cloudtrail_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.demo_cloudtrail_bucket_ownership]
  bucket     = aws_s3_bucket.demo_cloudtrail_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "demo_cloudtrail_bucket_sse" {
  bucket = aws_s3_bucket.demo_cloudtrail_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "demo_cloudtrail_bucket_lifecycle" {
  bucket = aws_s3_bucket.demo_cloudtrail_bucket.id

  rule {
    id     = "AWSlogs"
    status = "Enabled"

    filter {
      prefix = "/AWSLogs"
    }
    expiration {
      days = 7
    }
    transition {
      days          = 1
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 3
      storage_class = "GLACIER"
    }
  }
}

data "aws_iam_policy_document" "demo_cloudtrail_bucket_policy_doc" {
  statement {
    sid           = "AWSCloudTrailAclCheck20150319"
    effect        = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions       = ["s3:GetBucketAcl"]
    resources     = ["${aws_s3_bucket.demo_cloudtrail_bucket.arn}"]
    
  }

  statement {
    sid           = "AWSCloudTrailWrite20150319"
    effect        = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions       = ["s3:PutObject"]
    resources     = ["${aws_s3_bucket.demo_cloudtrail_bucket.arn}/AWSLogs/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid           = "Replicate objects"
    effect        = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${var.demo_account_id}"]
    }
    actions       = [
      "s3:ReplicateObject",
      "s3:ObjectOwnerOverrideToBucketOwner"
    ]
    resources     = ["${aws_s3_bucket.demo_cloudtrail_bucket.arn}/*"]
  }

  statement {
    sid           = "Replicate bucket"
    effect        = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${var.demo_account_id}"]
    }
    actions       = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]
    resources     = ["${aws_s3_bucket.demo_cloudtrail_bucket.arn}"]
  }

  statement {
    sid           = "ReadOnly access for source account"
    effect        = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${var.demo_account_id}"]
    }
    actions       = [
      "s3:List*",
      "s3:Get*"
    ]
    resources     = [
      "${aws_s3_bucket.demo_cloudtrail_bucket.arn}",
      "${aws_s3_bucket.demo_cloudtrail_bucket.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "demo_cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.demo_cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.demo_cloudtrail_bucket_policy_doc.json
}

resource "aws_s3_bucket_public_access_block" "demo_cloudtrail_bucket_pab" {
  bucket   = aws_s3_bucket.demo_cloudtrail_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_versioning" "demo_cloudtrail_bucket_versioning" {
  bucket   = aws_s3_bucket.demo_cloudtrail_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}