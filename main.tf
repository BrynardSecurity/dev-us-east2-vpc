terraform {
  backend "remote" {
    organization = "BrynardSecurity"

    workspaces {
      name = "dev-us-east-2"
    }
  }
}

variable "vpc_name" {
  description = "Name of the VPC to deploy in the AWS account."
}
variable "aws_region" {
  description = "Region in which to deploy the VPC."
}
variable "aws_account" {
  description = "The AWS Account ID."
}
variable "aws_account_alias" {
  description = "AWS Account alias."
}
variable "customer_gateway_ip" {
  description = "IP address of the customer gateway."
}
variable "device_name" {
  description = "Customer gateway device name."
}
variable "environment" {
  description = "Deployment environment. Possible values: Prod, Staging, Test, Dev."
}
variable "cidr" {
  description = "CIDR range for VPC deployment. Possible values: 10.0.0.0/16, 20.10.0.0/16"
}
variable "build_branch" {}
variable "build_repo" {}

provider "aws" {
  region = "us-east-2"
}

locals {
  name         = var.vpc_name
  build_date   = formatdate("YYYY-MM-DD", timestamp())
  build_branch = var.build_branch
  region       = var.aws_region
  tags = {
    "Account ID"    = var.aws_account
    "Account Alias" = var.aws_account_alias
    Environment     = var.environment
    Name            = var.vpc_name
    "Build Branch"  = var.build_branch
    "Build Repo"    = var.build_repo
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = "${local.name}-${local.build_date}"
  cidr = var.cidr

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  public_subnets  = ["20.10.11.0/24", "20.10.12.0/24", "20.10.13.0/24"]

  manage_default_route_table = true
  default_route_table_tags   = { DefaultRouteTable = true }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway = true
  single_nat_gateway = true

  customer_gateways = {
    IP1 = {
      bgp_asn     = 65112
      ip_address  = var.customer_gateway_ip
      device_name = var.device_name
    }
  }
  enable_vpn_gateway = true

  enable_dhcp_options = false

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  enable_flow_log = false
}

module "vpc_endpoints_nocreate" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  create = false
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
  tags = "${local.tags}"
}