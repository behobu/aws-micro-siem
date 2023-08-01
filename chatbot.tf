data "aws_iam_policy_document" "chatbot_role_policy" {
  statement {
    sid    = "ChatbotReadOnlyPolicy"
    effect = "Deny"
    actions = [
      "iam:*",
      "s3:GetBucketPolicy",
      "ssm:*",
      "sts:*",
      "kms:*",
      "cognito-idp:GetSigningCertificate",
      "ec2:GetPasswordData",
      "ecr:GetAuthorizationToken",
      "gamelift:RequestUploadCredentials",
      "gamelift:GetInstanceAccess",
      "lightsail:DownloadDefaultKeyPair",
      "lightsail:GetInstanceAccessDetails",
      "lightsail:GetKeyPair",
      "lightsail:GetKeyPairs",
      "redshift:GetClusterCredentials",
      "storagegateway:DescribeChapCredentials"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "chatbot_policy" {
  name   = "ChatbotNotificationsPolicy"
  role   = aws_iam_role.chatbot_role.id
  policy = data.aws_iam_policy_document.chatbot_role_policy.json
}

resource "aws_iam_role" "chatbot_role" {
  name               = "ChatbotNotificationsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "ChatbotNotificationsAssumeRolePolicy"
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "chatbot_readonly_policy_attachment" {
  name       = "ChatbotReadOnlyPolicyAttachment"
  roles      = [aws_iam_role.chatbot_role.name]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "awscc_chatbot_slack_channel_configuration" "send_sns_to_slack" {
  configuration_name = "RootLoginAttemptNotifications"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  slack_channel_id   = "A0B1C2D3E4F"
  slack_workspace_id = "T0U1V2W3X4Y"
  sns_topic_arns     = [aws_sns_topic.root_console_logins.arn]
  guardrail_policies = ["arn:aws:iam::aws:policy/AWSDenyAll"]
}