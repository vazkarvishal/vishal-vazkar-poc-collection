module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "18.31.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.24"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # Required for Karpenter role below
  enable_irsa = true

  node_security_group_additional_rules = {
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Node group for Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_https_for_istio = {
      description = "Istio HTTPS"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      self        = true
    }
    ingress_icmp_for_istio = {
      description = "Istio ICMP"
      protocol    = "tcp"
      from_port   = 1024
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    ingress_icmp_for_istio_to_cluster = {
      description                   = "Istio ICMP"
      protocol                      = "tcp"
      from_port                     = 1024
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    eggress_http = {
      description = "HTTP Egress for apt-get"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  node_security_group_tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  }

  # Only need one node to get Karpenter up and running.
  # This ensures core services such as VPC CNI, CoreDNS, etc. are up and running
  # so that Karpenter can be deployed and start managing compute capacity as required
  eks_managed_node_groups = {
    initial = {
      instance_types = ["m5.large"]
      # Not required nor used - avoid tagging two security groups with same tag as well
      create_security_group = false

      # Ensure enough capacity to run 2 Karpenter pods
      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}
