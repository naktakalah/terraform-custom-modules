locals {
  success_role_arn    = var.create_success_role ? aws_iam_role.success[0].arn : null
  failure_role_arn    = var.create_failure_role ? aws_iam_role.failure[0].arn : null
  success_sample_rate = var.create_success_role ? var.success_sample_rate : null
}

data "aws_iam_policy_document" "sns_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "delivery_logs" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "success" {
  count = var.create_success_role ? 1 : 0

  name               = "${local.naming_prefix}-sns-success"
  assume_role_policy = data.aws_iam_policy_document.sns_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "success" {
  count = var.create_success_role ? 1 : 0

  name   = "delivery-logs"
  role   = aws_iam_role.success[0].id
  policy = var.success_policy != null ? jsonencode(var.success_policy) : data.aws_iam_policy_document.delivery_logs.json
}

resource "aws_iam_role" "failure" {
  count = var.create_failure_role ? 1 : 0

  name               = "${local.naming_prefix}-sns-failure"
  assume_role_policy = data.aws_iam_policy_document.sns_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "failure" {
  count = var.create_failure_role ? 1 : 0

  name   = "delivery-logs"
  role   = aws_iam_role.failure[0].id
  policy = var.failure_policy != null ? jsonencode(var.failure_policy) : data.aws_iam_policy_document.delivery_logs.json
}

# without this the topic creation fails every now and then because SNS can't assume
# the role yet (IAM is eventually consistent)
resource "time_sleep" "wait_iam_propagation" {
  count = var.create_success_role || var.create_failure_role ? 1 : 0

  create_duration = "10s"

  depends_on = [
    aws_iam_role_policy.success,
    aws_iam_role_policy.failure,
  ]
}
