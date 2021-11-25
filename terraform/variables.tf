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
}
variable "cidr" {
  description = "CIDR range for VPC deployment. Possible values: 10.0.0.0/16, 20.10.0.0/16"
}
variable "build_branch" {}
variable "build_repo" {}