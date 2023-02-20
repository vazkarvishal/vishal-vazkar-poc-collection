locals {
  service_account = "keel-ecr-service-account"
}

resource "helm_release" "stackater_reloader" {
  namespace        = var.stackater_namespace
  create_namespace = true
  name             = "stackater-reloader"
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  version          = "v1.0.5"
  timeout          = 120
  cleanup_on_fail  = true
  wait             = true
  lint             = true
}

data "aws_iam_policy_document" "keel_ecr_policy_document" {
  statement {
    actions = [
      "ecr:*",
      "ec2:*",
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "keel_ecr_policy" {
  name        = local.service_account
  policy      = data.aws_iam_policy_document.keel_ecr_policy_document.json
  description = "Policy for keel to poll ECR"
}

module "iam_assumable_role" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.11.2"
  create_role      = true
  role_name        = "${local.service_account}-${var.cluster_name}"
  provider_url     = var.cluster_oidc_issuer_url
  role_policy_arns = [aws_iam_policy.keel_ecr_policy.arn]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${var.keel_namespace}:${local.service_account}",
    "system:serviceaccount:${var.keel_namespace}:default",
    "system:serviceaccount:${var.keel_namespace}:keel"
  ]
}

resource "kubernetes_service_account" "generated_sa" {
  metadata {
    name      = local.service_account
    namespace = var.keel_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role.iam_role_arn
    }
  }
  automount_service_account_token = true
}

resource "helm_release" "keel" {
  namespace        = var.keel_namespace
  create_namespace = true
  name             = "keel"
  repository       = "https://charts.keel.sh"
  chart            = "keel"
  version          = "0.9.11"
  timeout          = 120
  cleanup_on_fail  = true
  wait             = true
  lint             = true
  set {
    name  = "ecr.enabled"
    value = "true"
  }
  set {
    name  = "ecr.roleArn"
    value = module.iam_assumable_role.iam_role_arn
  }
  set {
    name  = "ecr.region"
    value = "ap-south-1"
  }
  set {
    name  = "image.tag"
    value = "latest"
  }
}

