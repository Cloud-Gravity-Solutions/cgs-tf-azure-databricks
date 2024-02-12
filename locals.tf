locals {
  existing_databricks_service = "dbw-dlh-prod-westeu-001"

  naming_convetions = {
    westeurope  = "westeu"
    northeurope = "northeu"

    vnet = {
      westeurope  = "cwe"
      northeurope = "cne"
    }
  }
}