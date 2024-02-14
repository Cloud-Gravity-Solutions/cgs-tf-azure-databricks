locals {
  existing_databricks_service = "test-marko"

  cluster_ids_list = tolist(data.databricks_clusters.all.ids)
  notebook_list    = tolist(data.databricks_notebook_paths.existing_notebook_paths[*].notebook_path_list[*].path)

  naming_convetions = {
    westeurope  = "westeu"
    northeurope = "northeu"

    vnet = {
      westeurope  = "cwe"
      northeurope = "cne"
    }
  }
}