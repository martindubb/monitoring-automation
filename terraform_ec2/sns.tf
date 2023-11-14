resource "aws_sns_topic" "prom_alerts" {
  name = "prometheus-alerts"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.prom_alerts.arn
  protocol  = "email"
  endpoint  = "martin@techstarter.de"
}