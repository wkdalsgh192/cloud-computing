resource "aws_cloudwatch_log_group" "ec2" {
  name              = "${var.environment}/ec2"
  retention_in_days = 30
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}