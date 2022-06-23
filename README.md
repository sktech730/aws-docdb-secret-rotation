# aws-docdb-secret-rotation

This sample code sets up automated way of rotating amazon document DB password 
through amazon secret manager service

## Prerequisite
- AWS account
- A VPC with DnsHostname enabled
- 2 private subnets in different AZs
- Terraform installation
- AWS Profile
- S3 bucket for Terraform state file

## Usage
- Clone the repo
- Set following variables in main.tfvars file
    - vpc_id
    - private_subnet_1
    - private_subnet_2
    - master_docdb_user
    - master_docdb_password
    - user_region
- Set the following variables in backend.tf
    - DEPLOYMENT_BUCKET
    - AWS_PROFILE
    - AWS_REGION
- Set appropriate Tags in tags.tf
- Download the pem file from "https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem" and place it under src/docdb_rotate