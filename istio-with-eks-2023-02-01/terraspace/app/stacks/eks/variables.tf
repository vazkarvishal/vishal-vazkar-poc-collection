variable "vpc_id" {
  description = "VPC to launch instance in"
  type        = string
  default     = null
}
variable "private_subnets" {
  description = "Private Subnet IDs"
  type        = list(string)
}