locals {
  # Naming
  naming_prefix = "${var.environment}-${var.application}"

  # Tags applied to all resources via provider default_tags
  tags_common = merge(var.tags, {
    Environment = var.environment
    Application = var.application
    ManagedBy   = "terraform"
    Team        = "platform"
  })

  # Network — compute subnet CIDRs from the VPC CIDR
  network_azs = ["${var.region}a", "${var.region}b", "${var.region}c"]

  network_public_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 0),
    cidrsubnet(var.vpc_cidr, 4, 1),
    cidrsubnet(var.vpc_cidr, 4, 2),
  ]

  network_private_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 4),
    cidrsubnet(var.vpc_cidr, 4, 5),
    cidrsubnet(var.vpc_cidr, 4, 6),
  ]

  network_database_subnets = [
    cidrsubnet(var.vpc_cidr, 4, 8),
    cidrsubnet(var.vpc_cidr, 4, 9),
    cidrsubnet(var.vpc_cidr, 4, 10),
  ]
}
