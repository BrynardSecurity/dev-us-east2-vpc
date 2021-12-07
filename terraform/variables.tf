variable "vpc_name" {
  description = "Name of the VPC to deploy in the AWS account."
  default     = "dev-us-east-2"
}
variable "aws_region" {
  description = "Region in which to deploy the VPC."
  default     = "us-east-2"
}
variable "aws_account" {
  description = "The AWS Account ID."
}
variable "aws_account_alias" {
  description = "AWS Account alias."
  default     = ""
}
variable "customer_gateway_ip" {
  description = "IP address of the customer gateway."
}
variable "device_name" {
  description = "Customer gateway device name."
}
variable "environment" {
  description = "Deployment environment. Possible values: Prod, Staging, Test, Dev."
  default     = "dev"
}
variable "cidr" {
  description = "CIDR range for VPC deployment. Possible values: 10.0.0.0/16, 20.10.0.0/16"
  default     = "10.9.0.0/16"
}
variable "build_branch" {
  default = "main"
}
variable "build_repo" {
  default = "https://github.com/BrynardSecurity/dev-us-east2-vpc"
}