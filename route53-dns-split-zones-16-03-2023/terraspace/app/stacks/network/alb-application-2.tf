
## ALB for VPC 1 
resource "aws_security_group" "external_alb_sg" {
  name        = "${local.cluster_name}-external-app"
  description = "${local.cluster_name}-external"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ##TODO:: To change to only allow VPC CIDR blocks
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ##TODO:: To change to only allow VPC CIDR blocks
  }

  ingress {
    description = "ICMP"
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] ##TODO:: To change to only allow VPC CIDR blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "${local.cluster_name}-external"
  }
}

resource "aws_lb" "external_test" {
  name               = "${local.cluster_name}-external"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "${local.cluster_name}-external"
  }
}

resource "aws_lb_listener" "external_front_end_http" {
  load_balancer_arn = aws_lb.external_test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_route53_record" "external_dns" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "external-alb.cloud.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.external_test.dns_name
    zone_id                = aws_lb.external_test.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "external_front_end_https" {
  load_balancer_arn = aws_lb.external_test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.example.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "EXTERNAL ALB FOR SPLIT ZONE TEST"
      status_code  = "200"
    }
  }
}
