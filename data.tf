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

data "databricks_cluster" "existing_cluster" {
  provider     = databricks.primary_site
  count        = length(var.existing_cluster_list)
  cluster_name = var.existing_cluster_list[count.index]
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

# Data for existing notebook paths and notebooks

data "databricks_notebook_paths" "existing_notebook_paths" {
  provider  = databricks.primary_site
  count     = length(var.existing_databricks_notebooks)
  path      = join("/", ["", var.existing_databricks_notebooks[count.index]])
  recursive = true
}

data "databricks_notebook" "existing_notebooks" {
  provider = databricks.primary_site
  count    = length(local.flattened_notebook_paths)
  path     = local.flattened_notebook_paths[count.index].path
  format   = "SOURCE"
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