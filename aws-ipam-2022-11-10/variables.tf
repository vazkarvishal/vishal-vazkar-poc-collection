variable "ipam_operating_regions" {
  type        = list(string)
  description = "Additional AWS VPC IPAM operating regions. You can only create VPCs from a pool whose locale matches this variable. Duplicate values will be removed."
  default     = ["eu-west-1", "eu-west-2", "eu-west-3", "eu-north-1", "eu-central-1"]
}

variable "top_level_pool_cidr" {
  type        = string
  description = "The top level IPAM pool CIDR. Currently only supports a single CIDR."
  default     = "10.0.0.0/8"
}
