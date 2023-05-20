data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}