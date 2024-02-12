terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

# Data for Azure Databricks Clusters if it exists

data "databricks_clusters" "all" {}

data "databricks_cluster" "existing_cluster" {
  count      = length(local.cluster_ids_list) 
  cluster_id = local.cluster_ids_list[count.index]
}

# Data to retirieve all databricks jobs from existing Databricks

data "databricks_jobs" "existing_jobs" {}

data "databricks_job" "existing_job" {
  count = length(keys(data.databricks_jobs.existing_jobs.ids))
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

# Data for Databricks Notebooks

data "databricks_notebook" "existing_notebooks" {
  count  = length(var.existing_databricks_notebooks)
  path   = var.existing_databricks_notebooks[count.index].path
  format = var.existing_databricks_notebooks[count.index].format
}

# Data for databricks Wrokspace Folder

data "databricks_directory" "existing_folders" {
  count = length(var.existing_databricks_folders)
  path  = join("/",["",var.existing_databricks_folders[count.index]])
}