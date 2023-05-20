
# ## ALB for VPC 1 
# resource "aws_security_group" "alb_sg" {
#   name        = "alb_sg_vpc_3"
#   description = "alb_sg_vpc_3"
#   vpc_id      = module.vpc_3.vpc_id

#   ingress {
#     description = "HTTP from VPC"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] ##TODO:: To change to only allow VPC CIDR blocks
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Name        = "tgw-demo-vpc-1"
#   }
# }

# resource "aws_lb" "test" {
#   name               = "tgw-demo-vpc-3"
#   internal           = true
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb_sg.id]
#   subnets            = module.vpc_3.private_subnets

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#     Name        = "tgw-demo-vpc-3"
#   }
# }

# resource "aws_lb_listener" "test_listener" {
#   load_balancer_arn = aws_lb.test.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Transit Gateway Test WORKS!!"
#       status_code  = "200"
#     }
#   }
# }
