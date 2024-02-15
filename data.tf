terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Data for databricks current user

data "databricks_current_user" "current_user" {}

# Data for Azure Databricks Clusters if it exists

data "databricks_clusters" "all" {}

data "databricks_cluster" "existing_cluster" {
  count      = length(local.cluster_ids_list)
  cluster_id = local.cluster_ids_list[count.index]
}

# Data to retirieve all databricks jobs from existing Databricks

data "databricks_jobs" "existing_jobs" {}

data "databricks_job" "existing_job" {
  count  = length(keys(data.databricks_jobs.existing_jobs.ids))
  job_id = values(data.databricks_jobs.existing_jobs.ids)[count.index]
}

# Data for Databricks Workspace 

data "azurerm_databricks_workspace" "existing_databricks_service" {
  name                = local.existing_databricks_service
  resource_group_name = var.existing_resource_group_name
}

# # Data for Databricks Cluster policy

# data "databricks_cluster_policy" "existing_cluster_policies" {
#   count    = length(local.cluster_ids_list)
#   name     = data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].policy_id
# }

# Data for Instance pools

data "databricks_instance_pool" "existing_pools" {
  count = length(var.existing_instance_pools)
  name  = var.existing_instance_pools[count.index]
}

# Data for existing notebook paths

data "databricks_notebook_paths" "existing_notebook_paths" {
  count     = length(var.existing_databricks_notebooks)
  path      = join("/", ["", var.existing_databricks_notebooks[count.index]])
  recursive = true
}

# Data for existing sql warehouses

data "databricks_sql_warehouses" "all" {
  depends_on = [data.azurerm_databricks_workspace.existing_databricks_service]
}
data "databricks_sql_warehouse" "sqlw" {
  count = length(tolist(data.databricks_sql_warehouses.all.ids))
  id    = tolist(data.databricks_sql_warehouses.all.ids)[count.index]
}

# Data for listing existing libraries stored in file system

data "databricks_dbfs_file_paths" "existing_dbfs_file_paths" {
  path      = local.dbfs_file_path
  recursive = true
}

data "databricks_dbfs_file" "existing_dbfs_files" {
  count           = length(local.flattened_library_paths)
  path            = local.flattened_library_paths[count.index].path
  limit_file_size = false
}