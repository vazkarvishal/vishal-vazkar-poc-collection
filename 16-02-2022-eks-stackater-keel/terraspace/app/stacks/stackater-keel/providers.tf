locals {
  # Use the cluster certificate unless a ca file is passed in, if so use that
  # this allows kubectl commands to be run from CPP laptops which perform SSL inspection and use a 
  # custom certificate
  ca_certificate = base64decode(var.cluster_certificate_authority_data)
}

provider "kubectl" {
  apply_retry_count      = 5
  host                   = var.cluster_endpoint
  cluster_ca_certificate = local.ca_certificate
  load_config_file       = false

  exec {
    # api_version = "client.authentication.k8s.io/v1beta1" //TODO fix this
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = local.ca_certificate
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
