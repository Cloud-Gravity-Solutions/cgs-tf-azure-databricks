# Data for Azure Databricks Clusters if it exists

data "databricks_clusters" "all" {
}

data "databricks_cluster" "existing_cluster" {
  count      = length(data.databricks_clusters.all.ids)
  cluster_id = data.databricks_clusters.all[count.index].id
}

# Data to retirieve all databricks jobs from existing Databricks

data "databricks_jobs" "existing_jobs" {}

data "databricks_job" "existing_job" {
  count  = length(data.databricks_jobs.existing_jobs.ids)
  job_id = data.databricks_jobs.existing_jobs[count.index].id
}


# Data for Databricks Workspace 

data "azurerm_databricks_workspace" "existing_databricks_service" {
  name                = local.existing_databricks_service
  resource_group_name = var.existing_resource_group_name
}

# Data for Databricks Cluster policy

data "databricks_cluster_policy" "existing_cluster_policies" {
  count = length(data.databricks_clusters.all.ids)
  name  = data.databricks_cluster.existing_cluster[count.index].policy_id
}

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
  path  = var.existing_databricks_folders[count.index]
}