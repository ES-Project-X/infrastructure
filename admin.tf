resource "aws_iam_user" "admin" {
  name = "admin"
  path = "/"
}

resource "aws_iam_group" "admin" {
  name = "admin_group"
  path = "/"
}

resource "aws_iam_user_group_membership" "admin" {
  user   = aws_iam_user.admin.name
  groups = [aws_iam_group.admin.name]
}

resource "aws_iam_group_policy_attachment" "CloudWatchLogsReadOnlyAccess" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "CloudWatchApplicationInsightsFullAccess" {
  group      = aws_iam_group.admin.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchApplicationInsightsFullAccess"
}

resource "aws_iam_group_policy" "admin_metrics" {
  name  = "admin"
  group = aws_iam_group.admin.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ],
        "Resource" : "*"
      }
    ]
  })
}
