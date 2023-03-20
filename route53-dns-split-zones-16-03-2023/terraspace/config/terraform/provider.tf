# Docs: https://www.terraform.io/docs/providers/aws/index.html
#
# If AWS_PROFILE and AWS_REGION is set, then the provider is optional.  Here's an example anyway:
#
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.5"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

# Temporary workaround due to AWS Public ECR only supporting us-east-1
# https://github.com/aws/karpenter/issues/3015#issuecomment-1344646211
provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}
