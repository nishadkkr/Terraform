provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  env                = var.env
  az_count           = 2
  single_nat_gateway = true
}