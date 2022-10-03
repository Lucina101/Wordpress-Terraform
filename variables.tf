variable "region" {}
variable "ami" {}
variable "availability_zone" {}
variable "bucket_name" {}

variable "database_name" {}
variable "database_user" {}
variable "database_pass" {}

variable "admin_user" {}
variable "admin_pass" {}

variable "vpc_cidr" {
  type        = string
  default     = "172.16.0.0/16"
  description = "vpc subnet"
}

variable "first_public_subnet" {
  type        = string
  default     = "172.16.1.0/24"
}

variable "second_private_subnet" {
  type = string
  default = "172.16.2.0/24"
}

variable "third_private_subnet" {
  type = string
  default = "172.16.3.0/24"
}

variable "fourth_public_subnet" {
  type = string
  default = "172.16.4.0/24"
}

