variable "environment" {
  type = string
}

variable "managed_by" {
  type = string
}

variable "security_zone" {
  type = string
}

variable "confidentiality" {
  type = string
}

variable "tagging_version" {
  type = string
}

variable "project" {
  type = string
}

variable "tagged_by" {
  type = string
}

variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kms_key_id" {
  type    = string
  default = "undefined"
}

variable "ec2_spot_instance_role_arn" {
  type = string
}
