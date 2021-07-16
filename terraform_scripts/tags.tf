locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Category"= "artifact"
    "purpose" = "db_secret_rotaion"
  }
}