variable "vpc_id" {
  type    = string
  default = "<VPC_ID>"
}

variable "secret_rotation_frequency" {
  type    = number
  default = 30 # set the rotation frequency in days
}

variable "master_docdb_password" {
  type    = string
  default = "<MASTER_USER_PASSWORD>"
}

variable "docdb_app_usr_password" {
  type = string
  default = "<APP_USER_PASSWORD>"
}

variable "master_docdb_user" {
  type = string
  default = "<MASTER_USER>"
}

variable "sample_app_user"{
  type = string
  default = "<APP_USER>"
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
  default     = "<REGION>"
}

