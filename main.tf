# Databricks Cluster/Clusters that will be created in new region

resource "databricks_cluster" "new_cluster" {
  count                        = length(local.cluster_ids_list)
  cluster_name                 = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].cluster_name, null)
  spark_version                = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].spark_version, null)
  node_type_id                 = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].node_type_id, null)
  runtime_engine               = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].runtime_engine, null)
  instance_pool_id             = can(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].node_type_id) ? null : try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].instance_pool_id, null)
  policy_id                    = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].policy_id, null)
  autotermination_minutes      = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].autotermination_minutes, null)
  enable_elastic_disk          = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].enable_elastic_disk, null)
  enable_local_disk_encryption = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].enable_local_disk_encryption, null)
  data_security_mode           = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].data_security_mode, null)
  single_user_name             = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].single_user_name, null)
  idempotency_token            = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].idempotency_token, null)
  ssh_public_keys              = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].ssh_public_keys, null)
  spark_env_vars               = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].spark_env_vars, null)
  spark_conf                   = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].spark_conf, null)
  custom_tags                  = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[count.index].custom_tags, null)

  autoscale {
    min_workers = try(lookup(var.databricks_cluster_autoscale, "min_workers", null), null)
    max_workers = try(lookup(var.databricks_cluster_autoscale, "max_workers", null), null)
  }
}

# Databricks jobs to be replicated to the new region

resource "databricks_job" "new_jobs" {
  count = length(data.databricks_jobs.existing_jobs.ids)
  name  = data.databricks_job.existing_job[count.index].name

  dynamic "job_cluster" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].job_cluster, [])
    content {
      job_cluster_key = lookup(job_cluster.value, "job_cluster_key", null)

      dynamic "new_cluster" {
        for_each = lookup(job_cluster.value, "new_cluster", [])
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
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].task, [])

    content {
      task_key = lookup(task.value, "task_key", null)

      dynamic "pipeline_task" {
        for_each = lookup(task.value, "pipeline_task" ,null)

        content {
          pipeline_id = lookup(pipeline_task.value, "pipeline_id", null)
        }
      }
    }
  }
}

