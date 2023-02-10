output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS Cluster Certificate Authority Data"
  value       = module.eks.cluster_certificate_authority_data
}

output "oidc_provider_arn" {
  description = "EKS Cluster oidc_provider_arn"
  value       = module.eks.oidc_provider_arn
}

output "managed_node_group_role_arn" {
  description = "EKS Cluster Managed Node Group Role ARN"
  value       = module.eks.eks_managed_node_groups["initial"].iam_role_arn
}
