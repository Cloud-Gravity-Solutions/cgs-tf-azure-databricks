locals {
  existing_databricks_service = "test-marko"

  cluster_ids_list = tolist(data.databricks_clusters.all.ids)

  naming_convetions = {
    westeurope  = "westeu"
    northeurope = "northeu"

    vnet = {
      westeurope  = "cwe"
      northeurope = "cne"
    }
  }
}