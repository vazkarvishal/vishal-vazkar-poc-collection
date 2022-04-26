module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "<18"

  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  # Only need one node to get Karpenter up and running
  worker_groups = [
    {
      instance_type = "t3a.medium"
      asg_max_size  = 1
    }
  ]

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}
