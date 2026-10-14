variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}
variable "env" {
  type        = string
  description = "vpn name"
}
variable "az_count" {
  type        = number
  description = "Number of Availability Zones"
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3"
  }
}
variable "single_nat_gateway" {
  type        = bool
  description = "true = one shared NAT (cheap, dev). false = one NAT per AZ (resilient, prod)"
  default     = true
}