resource "aws_cloudwatch_event_rule" "root_console_login" {
    name        = "root-console-login"
    description = "Capture successful root user logins from the console"
    event_pattern = jsonencode({
        "source": ["aws.signin"],
        "detail": {
            "userIdentity": {
                "type": ["Root"]
            },
            "responseElements": {
                "ConsoleLogin": ["Success"]
            },
            "eventName": ["ConsoleLogin"],
            "eventSource": ["signin.amazonaws.com"]
        }
    })
}

resource "aws_cloudwatch_event_target" "successful_root_console_login_target" {
    rule      = aws_cloudwatch_event_rule.root_console_login.name
    target_id = "send_successful_root_login_attempt_to_SNS"
    arn       = aws_sns_topic.root_console_logins.arn
}