locals {

  cluster_ids_list = tolist(data.databricks_clusters.all.ids)

  dbfs_file_path = "dbfs:/FileStore/jars"


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

  flattened_library_paths = flatten([
    for library_path in data.databricks_dbfs_file_paths.existing_dbfs_file_paths.path_list : {
      path      = library_path.path
      file_size = library_path.file_size
    }
  ])

  unique_directory_paths = distinct([
    for path in local.flattened_notebook_paths : path.directories
  ])

  cluster_library_combinations = flatten([
    for cluster_id in databricks_cluster.new_cluster[*].id : [
      for library_path in local.flattened_library_paths : {
        cluster_id   = cluster_id
        library_path = join("", ["dbfs:", library_path.path])
      }
    ]
  ])
}