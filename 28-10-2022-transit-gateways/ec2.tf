resource "aws_iam_role" "example" {
  name               = "tgw-demo-vpc-3"
  assume_role_policy = data.aws_iam_policy_document.default_assume.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_iam_instance_profile" "example" {
  name = "tgw-demo-vpc-1"
  role = aws_iam_role.example.name
}

data "aws_iam_policy_document" "default_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc_3.vpc_id
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc_3.vpc_cidr_block]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "allow_tls"
  }
}

module "ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = "tgw-demo-vpc-3"
  iam_instance_profile   = aws_iam_instance_profile.example.name
  ami                    = "ami-0ee415e1b8b71305f"
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id              = module.vpc_3.private_subnets[0]
  user_data              = file("cloud-init.yaml")
  tags = {
    Terraform = "true"
  }
}
