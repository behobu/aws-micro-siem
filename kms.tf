resource "aws_kms_key" "demo_cloudtrail_bucket_key" {
  description = "Used to encrypt CloudTrail logs"
  deletion_window_in_days = 1
  enable_key_rotation = true

  policy = data.aws_iam_policy_document.demo_cloudtrail_bucket_key_policy.json
}

resource "aws_kms_alias" "demo_cloudtrail_bucket_key_alias" {
  name = "alias/demo_cloudtrail_bucket_key_alias"
  target_key_id = aws_kms_key.demo_cloudtrail_bucket_key.key_id
}

data "aws_iam_policy_document" "demo_cloudtrail_bucket_key_policy" {
  policy_id = "Key policy created for CloudTrail log encryption"

  statement {
    sid = "Allow CloudTrail to describe key"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid = "Allow S3 to encrypt messages for publishing to SNS topic"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }

  statement {
    sid = "KMS access from source account"

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.demo_account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.demo_account_id}:trail/*"]
    }
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.demo_account_id}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.demo_account_id}:trail/*"]
    }
  }
}