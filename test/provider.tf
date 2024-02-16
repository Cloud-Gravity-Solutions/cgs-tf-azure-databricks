module "test-cgs" {
  source                        = "../"
  new_db_resource_group_name    = "test-rg-cgs"
  primary_db                    = "test-marko"
  secondary_db                  = "test-2-cgs"  
  existing_resource_group_name  = "marko"
  existing_instance_pools       = ["test-cgs-instance-pool", "test-cgs-instance-pool-2"]
  existing_databricks_notebooks = ["test-folder", "test-folder-2"]
  region_name                   = "westeurope"
}

terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}



