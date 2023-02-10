variable "cluster_name" {
  description = "The EKS Cluster Name"
  type        = string
}
variable "cluster_endpoint" {
  description = "The EKS Cluster Endpoint"
  type        = string
}
variable "cluster_certificate_authority_data" {
  description = "The EKS Cluster cluster_certificate_authority_data"
  type        = string
}
variable "oidc_provider_arn" {
  description = "The EKS Cluster oidc_provider_arn"
  type        = string
}
variable "managed_node_group_role_arn" {
  description = "The EKS Cluster managed_node_group_role_arn"
  type        = string
}
