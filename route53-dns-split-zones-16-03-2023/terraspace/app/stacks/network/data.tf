data "aws_route53_zone" "public" {
  name         = "cloud.example.com"
  private_zone = false
}

data "aws_iam_policy_document" "default_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}
