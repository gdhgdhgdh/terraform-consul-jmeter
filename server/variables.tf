variable "aws_region" {
    description = "The AWS region to create resources in."
    default = "us-west-1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_keypair"    {}
variable "control_cidr"   {}

variable "aws_amis" {
    default = {
        eu-west-1      = "ami-6e7bd919"
        us-east-1      = "ami-b66ed3de"
        us-west-1      = "ami-4b6f650e"
        ap-southeast-1 = "ami-ac5c7afe"
    }
}

variable "instance_count" {
    default = {
        eu-west-1      = "2"
        us-east-1      = "2"
        us-west-1      = "2"
        ap-southeast-1 = "2"
    }
}
