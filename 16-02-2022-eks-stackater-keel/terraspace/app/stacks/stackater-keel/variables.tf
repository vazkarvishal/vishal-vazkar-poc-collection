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
variable "cluster_oidc_issuer_url" {
  description = "The EKS Cluster cluster_oidc_issuer_url"
  type        = string
}

variable "stackater_namespace" {
  description = "The Kubernetes Namespace in which the app will be deployed"
  type        = string
  default     = "stackater"
}
variable "keel_namespace" {
  description = "The Kubernetes Namespace in which the app will be deployed"
  type        = string
  default     = "keel"
}
