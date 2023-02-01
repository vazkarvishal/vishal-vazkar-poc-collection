locals {
  test = toset(var.ipam_operating_regions)
}

output "example" {
  value = local.test
}
resource "aws_iam_service_linked_role" "ipam" {
  aws_service_name = "ipam.amazonaws.com"
  description      = "Service Linked Role for AWS VPC IP Address Manager"
}

resource "aws_vpc_ipam" "tutorial" {
  description = "my-ipam"
  dynamic "operating_regions" {
    for_each = local.test
    content {
      region_name = operating_regions.value
    }
  }
  depends_on = [
    aws_iam_service_linked_role.ipam
  ]
}

resource "aws_vpc_ipam_pool" "top_level" {
  description    = "top-level-pool"
  address_family = "ipv4"
  ipam_scope_id  = aws_vpc_ipam.tutorial.private_default_scope_id
}

# provision CIDR to the top-level pool
resource "aws_vpc_ipam_pool_cidr" "top_level" {
  ipam_pool_id = aws_vpc_ipam_pool.top_level.id
  cidr         = var.top_level_pool_cidr # "10.0.0.0/8" if following the tutorial
}

resource "aws_vpc_ipam_pool" "regional" {
  for_each            = local.test
  description         = "${each.key}-pool"
  address_family      = "ipv4"
  ipam_scope_id       = aws_vpc_ipam.tutorial.private_default_scope_id
  locale              = each.key
  source_ipam_pool_id = aws_vpc_ipam_pool.top_level.id
}

resource "aws_vpc_ipam_pool_cidr" "regional" {
  for_each     = { for index, region in tolist(local.test) : region => index }
  ipam_pool_id = aws_vpc_ipam_pool.regional[each.key].id
  cidr         = cidrsubnet(var.top_level_pool_cidr, 8, each.value)
}


# resource "aws_vpc" "tutorial" {
#   ipv4_ipam_pool_id   = aws_vpc_ipam_pool.regional["eu-west-1"].id
#   ipv4_netmask_length = 24
#   depends_on = [
#     aws_vpc_ipam_pool_cidr.regional
#   ]
# }

