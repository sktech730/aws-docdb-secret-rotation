variable "vpc_id" {
  type    = string
}

variable "secret_rotation_frequency" {
  type    = number
  default = 30 # set the rotation frequency in days
}

variable "master_docdb_user" {
  type = string
}

variable "master_docdb_password" {
  type    = string
}

variable "private_subnet_1"{
  type = string
}

variable "private_subnet_2"{
  type = string
}

variable "user_region" {
  type        = string
  description = "AWS region to use for all resources"
}

