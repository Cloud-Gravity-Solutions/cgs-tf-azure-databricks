# Data for Azure Databricks Clusters if it exists

data "databricks_clusters" "all" {
}

data "databricks_cluster" "all" {
  count      = length(data.databricks_clusters.all.ids)
  cluster_id = data.databricks_clusters.all[count.index].ids
}

# Data for Databricks Workspace 

