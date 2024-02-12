# Databricks Cluster/Clusters that will be created in new region

resource "databricks_cluster" "new_cluster" {
  count                        = length(data.databricks_clusters.all.ids)
  cluster_name                 = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "cluster_name", null)
  spark_version                = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "spark_version", null)
  node_type_id                 = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "node_type_id", null)
  runtime_engine               = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "runtime_engine", null)
  driver_node_type_id          = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "driver_node_type_id", null)
  driver_instance_pool_id      = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "driver_instance_pool_id", null)
  instance_pool_id             = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "instance_pool_id", null)
  policy_id                    = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "policy_id", null)
  autotermination_minutes      = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "autotermination_minutes", null)
  enable_elastic_disk          = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "enable_elastic_disk", null)
  enable_local_disk_encryption = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "enable_local_disk_encryption", null)
  data_security_mode           = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "data_security_mode", null)
  single_user_name             = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "single_user_name", null)
  idempotency_token            = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "idempotency_token", null)
  ssh_public_keys              = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "ssh_public_keys", null)
  spark_env_vars               = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "spark_env_vars", null)
  spark_conf                   = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "spark_conf", null)
  custom_tags                  = lookup(data.databricks_cluster.existing_cluster[count.index].cluster_info, "custom_tags", null)

  autoscale {
    min_workers = lookup(var.databricks_cluster_autoscale, "min_workers", null)
    max_workers = lookup(var.databricks_cluster_autoscale, "max_workers", null)
  }
}

# Databricks jobs to be replicated to the new region

resource "databricks_job" "new_jobs" {
  count = length(data.databricks_jobs.existing_jobs.ids)
  name  = data.databricks_job.existing_job[count.index].id

  dynamic "job_cluster" {
    for_each = data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index]

    content {
      job_cluster_key = lookup(job_cluster.value, "job_cluster_key", null)

      dynamic "new_cluster" {
        for_each = lookup(job_cluster.value, "new_cluster", null)
        content {
          num_workers    = lookup(new_cluster.value, "num_workers", null)
          spark_version  = lookup(new_cluster.value, "spark_version", null)
          spark_env_vars = lookup(new_cluster.value, "spark_env_vars", null)
          spark_conf     = lookup(new_cluster.value, "spark_conf", null)
        }
      }
    }
  }

  dynamic "task" {
    for_each = data.databricks_job.existing_job[count.index].job_settings

    content {
      task_key = lookup(task.value, "task_key", null)
    }


  }
}