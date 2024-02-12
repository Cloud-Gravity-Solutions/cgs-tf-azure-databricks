terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.36.2"
    }
  }
}

provider "databricks" {
  # Configuration options
}