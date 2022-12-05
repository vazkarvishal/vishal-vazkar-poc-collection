module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tgw-demo-vpc-1"
  cidr = "10.0.0.0/16"

  azs                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "vpc_2" {
  source = "terraform-aws-modules/vpc/aws"

  name = "tgw-demo-vpc-2"
  cidr = "10.1.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  # public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
  # single_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "vpc_3" {
  source = "terraform-aws-modules/vpc/aws"

  name                 = "tgw-demo-vpc-3"
  cidr                 = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  azs                  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets      = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  # public_subnets       = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]

  enable_nat_gateway = false
  # single_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


## Transit Gateway

resource "aws_ec2_transit_gateway" "example" {
  description                    = "tgw-demo"
  auto_accept_shared_attachments = "enable"
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "tgw-demo"
  }
}

# Transit Gateway Attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_1" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = module.vpc.vpc_id
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "tgw-demo-attachment-vpc-1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_2" {
  subnet_ids         = module.vpc_2.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = module.vpc_2.vpc_id
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "tgw-demo-attachment-vpc-2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_3" {
  subnet_ids         = module.vpc_3.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = module.vpc_3.vpc_id
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "tgw-demo-attachment-vpc-3"
  }
}

# Route table for VPC 1 and 3 attached to TGW
resource "aws_route" "vpc_1_to_tgw" {
  count = length(module.vpc.private_route_table_ids)
  # not using for each due to dependency loop and for each failing due to not knowing number of items before apply
  # for_each = {
  #   for route_table_id in module.vpc.private_route_table_ids : route_table_id => route_table_id
  # }
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.example.id
}

resource "aws_route" "vpc_3_to_tgw" {
  count = length(module.vpc_3.private_route_table_ids)
  # not using for each due to dependency loop and for each failing due to not knowing number of items before apply
  # for_each = {
  #   for route_table_id in module.vpc_3.private_route_table_ids : route_table_id => route_table_id
  # }
  route_table_id         = module.vpc_3.private_route_table_ids[count.index]
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.example.id
}


resource "aws_route" "vpc1_public_subnets_to_tgw" {
  count = length(module.vpc.public_route_table_ids)
  # not using for each due to dependency loop and for each failing due to not knowing number of items before apply
  # for_each = {
  #   for route_table_id in module.vpc_3.private_route_table_ids : route_table_id => route_table_id
  # }
  route_table_id         = module.vpc.default_route_table_id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.example.id
}

# Blackhole  for avoiding NAT bounce back traffic
# resource "aws_ec2_transit_gateway_route" "blackhole" {
#   destination_cidr_block         = "10.0.0.0/8"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway.example.association_default_route_table_id
#   blackhole                      = true
# }

# TGW to Attachment 1
resource "aws_ec2_transit_gateway_route" "tgw_internet_vpc_1" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.example.association_default_route_table_id
}


resource "aws_route" "vpc_3_to_tgw_for_igw" {
  count = length(module.vpc_3.private_route_table_ids)
  # not using for each due to dependency loop and for each failing due to not knowing number of items before apply
  # for_each = {
  #   for route_table_id in module.vpc_3.private_route_table_ids : route_table_id => route_table_id
  # }
  route_table_id         = module.vpc_3.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.example.id
}

