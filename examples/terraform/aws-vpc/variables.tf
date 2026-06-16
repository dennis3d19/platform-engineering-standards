variable "environment" {
  type        = string
  description = "Deployment environment. Must be one of: tst, acc, prd."

  validation {
    condition     = contains(["tst", "acc", "prd"], var.environment)
    error_message = "environment must be one of: tst, acc, prd."
  }
}

variable "application" {
  type        = string
  description = "Application or team name. Used in resource naming and tags."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.application))
    error_message = "application must be lowercase alphanumeric with hyphens, starting with a letter."
  }
}

variable "region" {
  type        = string
  description = "AWS region where resources will be created."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC. Must be a valid IPv4 CIDR."
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Enable NAT Gateway for private subnets. Disable only in environments with no outbound internet requirement."
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT Gateway for all private subnets. Reduces cost for non-production environments at the expense of AZ resilience."
  default     = false
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VPC Flow Logs for network traffic auditing."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources."
  default     = {}
}
