# VPC endpoints for STS
resource "aws_security_group" "vpc_1_aws_interface_endpoints_sg" {
  description = "security group for vpc endpoint"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description = "https ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

resource "aws_vpc_endpoint" "vpc_1_interface_endpoint_ssm" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_1_aws_interface_endpoints_sg.id]
  private_dns_enabled = false
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "vpc_1_interface_endpoint_ssm_messages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_1_aws_interface_endpoints_sg.id]
  private_dns_enabled = false
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "vpc_1_interface_endpoint_ec2_messages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_1_aws_interface_endpoints_sg.id]
  private_dns_enabled = false
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "vpc_1_interface_endpoint_logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.eu-west-1.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_1_aws_interface_endpoints_sg.id]
  private_dns_enabled = false
  subnet_ids          = module.vpc.private_subnets
}

resource "aws_vpc_endpoint" "vpc_1_s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.eu-west-1.s3"
}

resource "aws_vpc_endpoint_route_table_association" "vpc_1_s3_gateway" {
  count           = length(module.vpc.private_route_table_ids)
  route_table_id  = module.vpc.private_route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.vpc_1_s3.id
}
