terraform {
  backend "s3" {
    bucket = "<DEPLOYMENT_BUCKET>"
    key = "terraform/artifact/terraform.tfstate"
    profile = "AWS_PROFILE"
    encrypt = true
    region = "AWS_REGION"
  }
}