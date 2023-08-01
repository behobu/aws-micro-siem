resource "aws_sns_topic" "root_console_logins" {
    name = "root-console-logins"
}

data "aws_iam_policy_document" "root_console_logins_policy" {
    statement {
        effect  = "Allow"
        actions = ["SNS:Publish"]
        principals {
            type = "Service"
            identifiers = ["events.amazonaws.com"]
        }
        resources = [aws_sns_topic.root_console_logins.arn]
    }
}

resource "aws_sns_topic_policy" "root_console_logins_policy_attachment" {
    arn    = aws_sns_topic.root_console_logins.arn
    policy = data.aws_iam_policy_document.root_console_logins_policy.json
}