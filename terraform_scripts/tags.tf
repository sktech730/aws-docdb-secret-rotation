locals {
  # Common tags to be assigned to all resources
  common_tags = {
    "Category" = "artifact"
    "purpose" = "docdb-secret-rotation"
  }
}