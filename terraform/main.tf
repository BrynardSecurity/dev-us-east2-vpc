terraform {
  backend "remote" {
    organization = "BrynardSecurity"

    workspaces {
      name = "dev-us-east-2"
    }
  }
}

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
  private_subnets = ["10.9.1.0/24", "10.9.2.0/24", "10.9.3.0/24"]
  public_subnets  = ["10.9.11.0/24", "10.9.12.0/24", "10.9.13.0/24"]

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

module "dev-us-east-2-tgw" {
  source          = "terraform-aws-modules/transit-gateway/aws"
  version         = "~> 2.0"
  name            = "dev-us-east-2-tgw-${local.build_date}"
  description     = "Hashicorp Vault HVN TGW"

  enable_auto_accept_shared_attachments = true

  vpc_attachments = {
    vpc = {
      vpc_id        = module.vpc.vpc_id
      subnet_ids    = module.vpc.private_subnets
      dns_support   = true
      ipv6_support  = false

      tgw_routes = [
        {
          destination_cidr_block = "10.9.0.0/16"
        }
      ]
    }
  }

  tags = {
    Purpose = "hvn-tgw-dev-us-east-2"
  }
}


data "aws_security_group" "default" {
  name   = "${var.vpc_name}-${local.build_date}"
  vpc_id = module.vpc.vpc_id
}