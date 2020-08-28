variable "aws_region" {
	default = "ap-southeast-2"
}

variable "vpc_cidr" {
	default = "10.20.0.0/16"
}

variable "subnets_cidr" {
	type = list
	default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "subnets_cidr_private" {
	type = list
	default = ["10.20.3.0/24", "10.20.4.0/24", "10.20.5.0/24", "10.20.6.0/24"]
}

variable "azs" {
	type = list
	default = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "webservers_ami" {
  default = "ami-0ded330691a314693"
}

variable "instance_type" {
  default = "t2.nano"
}
