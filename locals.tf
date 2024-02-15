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

  flattened_notebook_paths = flatten([
    for i, notebook_paths in data.databricks_notebook_paths.existing_notebook_paths : [
      for notebook_path in notebook_paths.notebook_path_list : {
        path        = notebook_path.path
        language    = notebook_path.language
        directories = replace(dirname(notebook_path.path), "\\", "/")
      }
    ]
  ])

  unique_directory_paths = distinct([
    for path in local.flattened_notebook_paths : path.directories
  ])
}