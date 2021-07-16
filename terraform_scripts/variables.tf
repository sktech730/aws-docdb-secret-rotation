variable "vpc_id" {
  type    = string
  default = "<VPC_ID>"
}

variable "secret_rotation_frequency" {
  type    = number
  default = 30
}

variable "docdb_password" {
  type    = string
  default = "set_your_initial_password"
}

variable "docdb_user" {
  type = string
  default = "<ROOT_USER>"
}

variable "private-subnet-1"{
  type = string
  default = "<SUBNET_ID>"
}

variable "private-subnet-2"{
  type = string
  default = "<SUBNET_ID>"
}

variable "user_region" {
  type        = string
  description = "AWS region to use for all resources"
  default     = "us-east-1"
}