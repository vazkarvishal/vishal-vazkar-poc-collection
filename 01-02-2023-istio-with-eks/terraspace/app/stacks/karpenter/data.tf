data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
