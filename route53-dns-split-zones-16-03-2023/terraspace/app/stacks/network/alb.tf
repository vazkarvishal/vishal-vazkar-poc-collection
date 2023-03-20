
## ALB for VPC 1 
resource "aws_security_group" "alb_sg" {
  name        = local.cluster_name
  description = local.cluster_name
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
    Name        = local.cluster_name
  }
}

resource "aws_lb" "test" {
  name               = local.cluster_name
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.private_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = local.cluster_name
  }
}

resource "aws_lb_listener" "front_end_http" {
  load_balancer_arn = aws_lb.test.arn
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

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "alb.cloud.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.test.dns_name
    zone_id                = aws_lb.test.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "front_end_https" {
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.example.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Test WORKS!!"
      status_code  = "200"
    }
  }
}


resource "aws_lb" "nlb-public-facing" {
  name               = "test-dns-public-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_route53_record" "public_dns_record" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "alb.cloud.example.com"
  type    = "A"

  alias {
    name                   = aws_lb.nlb-public-facing.dns_name
    zone_id                = aws_lb.nlb-public-facing.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_target_group" "nlb-public-facing" {
  name        = "test-dns-public-nlb"
  target_type = "alb"
  port        = 443
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 2
    path                = "/"
    port                = 443
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200-399"
    protocol            = "HTTPS"
  }
}


resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = aws_lb_target_group.nlb-public-facing.arn
  # attach the ALB to this target group
  target_id = aws_lb.test.arn
  #  If the target type is alb, the targeted Application Load Balancer must have at least one listener whose port matches the target group port.
  port = 443
  depends_on = [
    aws_lb_listener.front_end_https
  ]
}

resource "aws_lb_listener" "nlb-public-facing" {
  load_balancer_arn = aws_lb.nlb-public-facing.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-public-facing.arn
  }
}
