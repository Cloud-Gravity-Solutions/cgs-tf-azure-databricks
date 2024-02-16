terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Data to get existing databricks workspaces, primary and secondary

data "azurerm_databricks_workspace" "primary_db" {
  name                = var.primary_db
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_databricks_workspace" "secondary_db" {
  name                = var.secondary_db
  resource_group_name = var.new_db_resource_group_name
}
# Data for databricks current user

data "databricks_current_user" "current_user" {
  provider = databricks.primary_site
}

# Data for Azure Databricks Clusters if it exists

data "databricks_clusters" "all" {
  provider = databricks.primary_site
}

data "databricks_cluster" "existing_cluster" {
  provider   = databricks.primary_site
  count      = length(local.cluster_ids_list)
  cluster_id = local.cluster_ids_list[count.index]
}

# Data to retirieve all databricks jobs from existing Databricks

data "databricks_jobs" "existing_jobs" {
  provider = databricks.primary_site
}

data "databricks_job" "existing_job" {
  provider = databricks.primary_site
  count    = length(keys(data.databricks_jobs.existing_jobs.ids))
  job_id   = values(data.databricks_jobs.existing_jobs.ids)[count.index]
}

# Data for Instance pools

data "databricks_instance_pool" "existing_pools" {
  provider = databricks.primary_site
  count    = length(var.existing_instance_pools)
  name     = var.existing_instance_pools[count.index]
}

# Data for existing notebook paths

data "databricks_notebook_paths" "existing_notebook_paths" {
  provider  = databricks.primary_site
  count     = length(var.existing_databricks_notebooks)
  path      = join("/", ["", var.existing_databricks_notebooks[count.index]])
  recursive = true
}

# Data for existing sql warehouses

data "databricks_sql_warehouses" "all" {
  provider   = databricks.primary_site
  depends_on = [data.azurerm_databricks_workspace.primary_db]
}
data "databricks_sql_warehouse" "sqlw" {
  provider = databricks.primary_site
  count    = length(tolist(data.databricks_sql_warehouses.all.ids))
  id       = tolist(data.databricks_sql_warehouses.all.ids)[count.index]
}

# Data for listing existing libraries stored in file system

data "databricks_dbfs_file_paths" "existing_dbfs_file_paths" {
  provider  = databricks.primary_site
  path      = local.dbfs_file_path
  recursive = true
}

data "databricks_dbfs_file" "existing_dbfs_files" {
  provider        = databricks.primary_site
  count           = length(local.flattened_library_paths)
  path            = local.flattened_library_paths[count.index].path
  limit_file_size = false
}
