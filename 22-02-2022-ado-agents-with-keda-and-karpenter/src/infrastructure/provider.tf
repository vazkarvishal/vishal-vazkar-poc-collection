provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Environment     = var.environment
      ManagedBy       = var.managed_by
      SecurityZone    = var.security_zone
      Confidentiality = var.confidentiality
      TaggingVersion  = var.tagging_version
      Project         = var.project
      TaggedBy        = var.tagged_by
    }
  }
}
