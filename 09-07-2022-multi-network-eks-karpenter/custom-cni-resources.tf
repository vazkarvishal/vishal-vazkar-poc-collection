resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "100.64.0.0/16"
}

resource "aws_subnet" "in_secondary_cidr_a" {
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "100.64.0.0/21"
  tags = {
    "Name" = "secondary-${local.cluster_name}-1"
  }
}

resource "aws_subnet" "in_secondary_cidr_b" {
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "100.64.8.0/21"
  tags = {
    "Name" = "secondary-${local.cluster_name}-2"
  }
}

resource "aws_subnet" "in_secondary_cidr_c" {
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary_cidr.vpc_id
  cidr_block = "100.64.16.0/21"
  tags = {
    "Name" = "secondary-${local.cluster_name}-3"
  }
}
