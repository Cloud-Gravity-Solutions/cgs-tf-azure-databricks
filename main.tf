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
  count             = length(data.databricks_jobs.existing_jobs.ids)
  name              = data.databricks_job.existing_job[count.index].name
  control_run_state = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].control_run_state, null)
  timeout_seconds   = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].timeout_seconds, null)

  dynamic "parameter" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].parameter, [])

    content {
      name    = lookup(parameter.value, "name", null)
      default = lookup(parameter.value, "name", null)
    }
  }

  dynamic "notification_settings" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].notification_settings, [])

    content {
      no_alert_for_skipped_runs  = lookup(notification_settings.value, "no_alert_for_skipped_runs", null)
      no_alert_for_canceled_runs = lookup(notification_settings.value, "no_alert_for_canceled_runs", null)
    }

  }
  dynamic "job_cluster" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].job_cluster, [])
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
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[count.index].settings[count.index].task, [])

    content {
      task_key                  = lookup(task.value, "task_key", null)
      run_if                    = lookup(task.value, "run_if", null)
      retry_on_timeout          = lookup(task.value, "retry_on_timeout", null)
      max_retries               = lookup(task.value, "max_retries", null)
      min_retry_interval_millis = lookup(task.value, "min_retry_interval_millis", null)
      timeout_seconds           = lookup(task.value, "timeout_seconds", null)

      dynamic "email_notifications" {
        for_each = lookup(task.value, "email_notifications", null)

        content {
          on_start                               = lookup(email_notifications.value, "on_start", null)
          on_success                             = lookup(email_notifications.value, "on_success", null)
          on_failure                             = lookup(email_notifications.value, "on_failure", null)
          on_duration_warning_threshold_exceeded = lookup(email_notifications.value, "on_duration_warning_threshold_exceeded", null)
        }
      }

      dynamic "pipeline_task" {
        for_each = lookup(task.value, "pipeline_task", null)

        content {
          pipeline_id = lookup(pipeline_task.value, "pipeline_id", null)
        }
      }

      dynamic "spark_jar_task" {
        for_each = lookup(task.value, "spark_jar_task", null)

        content {
          parameters      = lookup(spark_jar_task.value, "parameters", null)
          main_class_name = lookup(spark_jar_task.value, "main_class_name", null)
        }
      }
      dynamic "condition_task" {
        for_each = lookup(task.value, "condition_task", null)

        content {
          left  = lookup(condition_task.value, "left", null)
          right = lookup(condition_task.value, "right", null)
          op    = lookup(condition_task.value, "op", null)
        }
      }
      dynamic "spark_submit_task" {
        for_each = lookup(task.value, "spark_submit_task", null)

        content {
          parameters = lookup(spark_submit_task.value, "parameters", null)
        }
      }
      dynamic "spark_python_task" {
        for_each = lookup(task.value, "spark_python_task", null)

        content {
          python_file = lookup(spark_python_task.value, "python_file", null)
          source      = lookup(spark_python_task.value, "source", null)
          parameters  = lookup(spark_python_task.value, "parameters", null)
        }
      }
      dynamic "notebook_task" {
        for_each = lookup(task.value, "notebook_task", null)

        content {
          notebook_path   = lookup(notebook_task.value, "notebook_path", null)
          source          = lookup(notebook_task.value, "source", null)
          base_parameters = lookup(notebook_task.value, "base_parameters", null)
        }
      }

      dynamic "python_wheel_task" {
        for_each = lookup(task.value, "python_wheel_task", null)

        content {
          entry_point      = lookup(python_wheel_task.value, "entry_point", null)
          package_name     = lookup(python_wheel_task.value, "package_name", null)
          parameters       = lookup(python_wheel_task.value, "parameters", null)
          named_parameters = lookup(python_wheel_task.value, "named_parameters", null)
        }
      }

      dynamic "dbt_task" {
        for_each = lookup(task.value, "dbt_task", null)

        content {
          commands           = lookup(dbt_task.value, "commands", null)
          project_directory  = lookup(dbt_task.value, "project_directory", null)
          profiles_directory = lookup(dbt_task.value, "profiles_directory", null)
          catalog            = lookup(dbt_task.value, "catalog", null)
          schema             = lookup(dbt_task.value, "schema", null)
          warehouse_id       = lookup(dbt_task.value, "warehouse_id", null)
        }
      }
      dynamic "run_job_task" {
        for_each = lookup(task.value, "run_job_task", null)

        content {
          job_id         = lookup(run_job_task.value, "job_id", null)
          job_parameters = lookup(run_job_task.value, "job_parameters", null)
        }
      }

      dynamic "sql_task" {
        for_each = lookup(task.value, "sql_task", null)

        content {
          warehouse_id = lookup(sql_task.value, "warehouse_id", null)
          parameters   = lookup(sql_task.value, "parameters", null)

          dynamic "query" {
            for_each = lookup(sql_task.value, "query", null)
            content {
              query_id = lookup(query.value, "query_id", null)
            }
          }
          dynamic "dashboard" {
            for_each = lookup(sql_task.value, "dashboard", null)

            content {
              dashboard_id        = lookup(dashboard.value, "dashboard_id", null)
              custom_subject      = lookup(dashboard.value, "custom_subject", null)
              pause_subscriptions = lookup(dashboard.value, "pause_subscriptions", null)

              dynamic "subscriptions" {
                for_each = lookup(dashboard.value, "subscriptions", null)

                content {
                  user_name      = lookup(subscriptions.value, "user_name", null)
                  destination_id = lookup(subscriptions.value, "destination_id", null)
                }
              }
            }
          }
          dynamic "alert" {
            for_each = lookup(sql_task.value, "alert", null)

            content {
              alert_id            = lookup(alert.value, "alert_id", null)
              pause_subscriptions = lookup(alert.value, "pause_subscriptions", null)

              dynamic "subscriptions" {
                for_each = lookup(alert.value, "subscriptions", null)

                content {
                  user_name      = lookup(subscriptions.value, "user_name", null)
                  destination_id = lookup(subscriptions.value, "destination_id", null)
                }
              }
            }
          }
          dynamic "file" {
            for_each = lookup(sql_task.value, "file", null)

            content {
              path = lookup(file.value, "path", null)
            }
          }
        }
      }
    }
  }
}

