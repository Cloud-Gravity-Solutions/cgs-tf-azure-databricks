module "test-cgs" {
  source                       = "../"
  existing_resource_group_name = "marko"
  existing_instance_pools      = ["test-cgs-instance-pool", "test-cgs-instance-pool-2"]
  existing_databricks_notebooks = [
    {
      path   = "/Users/marko.skendo@raiffeisen.al/test-cgs-notebook"
      format = "SOURCE"
    },
    {
      path   = "/Users/marko.skendo@raiffeisen.al/test-cgs-notebook-2"
      format = "SOURCE"
    }
  ]
  existing_databricks_folders = ["test-folder", "test-folder-2"]
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

provider "databricks" {
  host = data.azurerm_databricks_workspace.existing_databricks_service.workspace_url
}

data "azurerm_databricks_workspace" "existing_databricks_service" {
  name                = "test-marko"
  resource_group_name = "marko"
}
