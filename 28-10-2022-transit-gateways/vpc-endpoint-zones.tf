# Zone
resource "aws_route53_zone" "private_ssm_messages" {
  name = "ssmmessages.eu-west-1.amazonaws.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone_association" "private_ssm_messages" {
  zone_id = aws_route53_zone.private_ssm_messages.zone_id
  vpc_id  = module.vpc_3.vpc_id
}

# output "test" {
#   value = aws_vpc_endpoint.vpc_1_interface_endpoint_ssm_messages.dns_entry[0]["dns_name"]
# }

#Record
resource "aws_route53_record" "private_ssm_messages" {
  zone_id = aws_route53_zone.private_ssm_messages.zone_id
  name    = "ssmmessages.eu-west-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.vpc_1_interface_endpoint_ssm_messages.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.vpc_1_interface_endpoint_ssm_messages.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "private_ssm" {
  name = "ssm.eu-west-1.amazonaws.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone_association" "private_ssm" {
  zone_id = aws_route53_zone.private_ssm.zone_id
  vpc_id  = module.vpc_3.vpc_id
}

resource "aws_route53_record" "private_ssm" {
  zone_id = aws_route53_zone.private_ssm.zone_id
  name    = "ssm.eu-west-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.vpc_1_interface_endpoint_ssm.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.vpc_1_interface_endpoint_ssm.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = false
  }
}

resource "aws_route53_zone" "private_ec2messages" {
  name = "ec2messages.eu-west-1.amazonaws.com"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_route53_zone_association" "private_ec2messages" {
  zone_id = aws_route53_zone.private_ec2messages.zone_id
  vpc_id  = module.vpc_3.vpc_id
}

resource "aws_route53_record" "private_ec2messages" {
  zone_id = aws_route53_zone.private_ec2messages.zone_id
  name    = "ec2messages.eu-west-1.amazonaws.com"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.vpc_1_interface_endpoint_ec2_messages.dns_entry[0]["dns_name"]
    zone_id                = aws_vpc_endpoint.vpc_1_interface_endpoint_ec2_messages.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health = false
  }
}
