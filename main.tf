# Databricks Cluster/Clusters that will be created in new region

resource "databricks_cluster" "new_cluster" {
  provider                     = databricks.dr_site
  count                        = length(var.existing_cluster_list)
  cluster_name                 = data.databricks_cluster.existing_cluster[count.index].cluster_info[0].cluster_name
  spark_version                = data.databricks_cluster.existing_cluster[count.index].cluster_info[0].spark_version
  node_type_id                 = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].node_type_id, null)
  runtime_engine               = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].runtime_engine, null)
  instance_pool_id             = can(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].node_type_id) ? null : try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].instance_pool_id, null)
  apply_policy_default_values  = true
  autotermination_minutes      = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].autotermination_minutes, null)
  enable_elastic_disk          = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].enable_elastic_disk, null)
  enable_local_disk_encryption = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].enable_local_disk_encryption, null)
  data_security_mode           = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].data_security_mode, null)
  single_user_name             = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].single_user_name, null)
  idempotency_token            = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].idempotency_token, null)
  ssh_public_keys              = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].ssh_public_keys, null)
  spark_env_vars               = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].spark_env_vars, null)
  spark_conf                   = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].spark_conf, null)
  custom_tags                  = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].custom_tags, null)

  autoscale {
    min_workers = try(lookup(var.databricks_cluster_autoscale, "min_workers", null), null)
    max_workers = try(lookup(var.databricks_cluster_autoscale, "max_workers", null), null)
  }
}

resource "databricks_job" "new_jobs" {
  provider          = databricks.dr_site
  count             = length(data.databricks_jobs.existing_jobs.ids)
  name              = data.databricks_job.existing_job[count.index].name
  control_run_state = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].control_run_state, null)
  timeout_seconds   = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].timeout_seconds, 15)
  tags              = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].tags, {})

  dynamic "new_cluster" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].new_cluster, [])
    content {
      instance_pool_id = lookup(new_cluster.value, "instance_pool_id", null)
      node_type_id     = lookup(new_cluster.value, "node_type_id", "Standard_DS3_v2")
      spark_version    = lookup(new_cluster.value, "spark_version", null)
      spark_env_vars   = lookup(new_cluster.value, "spark_env_vars", null)
      spark_conf       = lookup(new_cluster.value, "spark_conf", null)

      dynamic "autoscale" {
        for_each = lookup(new_cluster.value, "autoscale", [])
        content {
          min_workers = lookup(autoscale.value, "min_workers", 1)
          max_workers = lookup(autoscale.value, "max_workers", 8)
        }
      }
    }
  }

  dynamic "task" {

    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].task, [])

    content {
      task_key                  = lookup(task.value, "task_key", null)
      run_if                    = lookup(task.value, "run_if", null)
      retry_on_timeout          = lookup(task.value, "retry_on_timeout", null)
      max_retries               = lookup(task.value, "max_retries", null)
      min_retry_interval_millis = lookup(task.value, "min_retry_interval_millis", null)
      timeout_seconds           = lookup(task.value, "timeout_seconds", null)
      existing_cluster_id       = lookup(task.value, "existing_cluster_id", null)
      job_cluster_key           = lookup(task.value, "job_cluster_key", null)

      dynamic "new_cluster" {
        for_each = lookup(task.value, "new_cluster", [])
        content {
          instance_pool_id = lookup(new_cluster.value, "instance_pool_id", null)
          node_type_id     = lookup(new_cluster.value, "node_type_id", "Standard_DS3_v2")
          spark_version    = lookup(new_cluster.value, "spark_version", null)
          spark_env_vars   = lookup(new_cluster.value, "spark_env_vars", null)
          spark_conf       = lookup(new_cluster.value, "spark_conf", null)

          dynamic "autoscale" {
            for_each = lookup(new_cluster.value, "autoscale", [])
            content {
              min_workers = lookup(autoscale.value, "min_workers", 1)
              max_workers = lookup(autoscale.value, "max_workers", 8)
            }
          }
        }
      }

      dynamic "depends_on" {
        for_each = lookup(task.value, "depends_on", [])

        content {
          task_key = lookup(depends_on.value, "task_key", null)
          outcome  = lookup(depends_on.value, "outcome", null)
        }
      }

      dynamic "notification_settings" {
        for_each = lookup(task.value, "notification_settings", [])

        content {
          no_alert_for_canceled_runs = lookup(notification_settings.value, "no_alert_for_canceled_runs", null)
          no_alert_for_skipped_runs  = lookup(notification_settings.value, "no_alert_for_skipped_runs", null)
          alert_on_last_attempt      = lookup(notification_settings.value, "alert_on_last_attempt", null)
        }
      }

      dynamic "email_notifications" {
        for_each = lookup(task.value, "email_notifications", [])

        content {
          on_start                               = lookup(email_notifications.value, "on_start", null)
          on_success                             = lookup(email_notifications.value, "on_success", null)
          on_failure                             = lookup(email_notifications.value, "on_failure", null)
          on_duration_warning_threshold_exceeded = lookup(email_notifications.value, "on_duration_warning_threshold_exceeded", null)
        }
      }

      dynamic "pipeline_task" {
        for_each = lookup(task.value, "pipeline_task", [])

        content {
          pipeline_id = lookup(pipeline_task.value, "pipeline_id", null)
        }
      }

      dynamic "spark_jar_task" {
        for_each = lookup(task.value, "spark_jar_task", [])

        content {
          parameters      = lookup(spark_jar_task.value, "parameters", null)
          main_class_name = lookup(spark_jar_task.value, "main_class_name", null)
        }
      }
      dynamic "condition_task" {
        for_each = lookup(task.value, "condition_task", [])

        content {
          left  = lookup(condition_task.value, "left", null)
          right = lookup(condition_task.value, "right", null)
          op    = lookup(condition_task.value, "op", null)
        }
      }
      dynamic "spark_submit_task" {
        for_each = lookup(task.value, "spark_submit_task", [])

        content {
          parameters = lookup(spark_submit_task.value, "parameters", null)
        }
      }
      dynamic "spark_python_task" {
        for_each = lookup(task.value, "spark_python_task", [])

        content {
          python_file = lookup(spark_python_task.value, "python_file", null)
          source      = lookup(spark_python_task.value, "source", null)
          parameters  = lookup(spark_python_task.value, "parameters", null)
        }
      }
      dynamic "notebook_task" {
        for_each = lookup(task.value, "notebook_task", [])

        content {
          notebook_path   = lookup(notebook_task.value, "notebook_path", null)
          source          = lookup(notebook_task.value, "source", null)
          base_parameters = lookup(notebook_task.value, "base_parameters", null)
        }
      }

      dynamic "python_wheel_task" {
        for_each = lookup(task.value, "python_wheel_task", [])

        content {
          entry_point      = lookup(python_wheel_task.value, "entry_point", null)
          package_name     = lookup(python_wheel_task.value, "package_name", null)
          parameters       = lookup(python_wheel_task.value, "parameters", null)
          named_parameters = lookup(python_wheel_task.value, "named_parameters", null)
        }
      }

      dynamic "dbt_task" {
        for_each = lookup(task.value, "dbt_task", [])

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
        for_each = lookup(task.value, "run_job_task", [])

        content {
          job_id         = lookup(run_job_task.value, "job_id", null)
          job_parameters = lookup(run_job_task.value, "job_parameters", null)
        }
      }

      dynamic "sql_task" {
        for_each = lookup(task.value, "sql_task", [])

        content {
          warehouse_id = lookup(sql_task.value, "warehouse_id", null)
          parameters   = lookup(sql_task.value, "parameters", null)

          dynamic "query" {
            for_each = lookup(sql_task.value, "query", [])
            content {
              query_id = lookup(query.value, "query_id", null)
            }
          }
          dynamic "dashboard" {
            for_each = lookup(sql_task.value, "dashboard", [])

            content {
              dashboard_id        = lookup(dashboard.value, "dashboard_id", null)
              custom_subject      = lookup(dashboard.value, "custom_subject", null)
              pause_subscriptions = lookup(dashboard.value, "pause_subscriptions", null)

              dynamic "subscriptions" {
                for_each = lookup(dashboard.value, "subscriptions", [])

                content {
                  user_name      = lookup(subscriptions.value, "user_name", null)
                  destination_id = lookup(subscriptions.value, "destination_id", null)
                }
              }
            }
          }
          dynamic "alert" {
            for_each = lookup(sql_task.value, "alert", [])

            content {
              alert_id            = lookup(alert.value, "alert_id", null)
              pause_subscriptions = lookup(alert.value, "pause_subscriptions", null)

              dynamic "subscriptions" {
                for_each = lookup(alert.value, "subscriptions", [])

                content {
                  user_name      = lookup(subscriptions.value, "user_name", null)
                  destination_id = lookup(subscriptions.value, "destination_id", null)
                }
              }
            }
          }
          dynamic "file" {
            for_each = lookup(sql_task.value, "file", [])

            content {
              path = lookup(file.value, "path", null)
            }
          }
        }
      }
    }
  }

  dynamic "schedule" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].schedule, [])

    content {
      quartz_cron_expression = lookup(schedule.value, "quartz_cron_expression", null)
      timezone_id            = lookup(schedule.value, "timezone_id", null)
      pause_status           = lookup(schedule.value, "pause_status", null)
    }
  }

  dynamic "queue" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].queue, [])

    content {
      enabled = lookup(queue.value, "enabled", null)
    }
  }

  dynamic "trigger" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].trigger, [])

    content {
      pause_status = lookup(trigger.value, "pause_status", null)

      dynamic "file_arrival" {

        for_each = lookup(trigger.value, "file_arrival", [])

        content {
          url                               = lookup(file_arrival.value, "url", null)
          min_time_between_triggers_seconds = lookup(file_arrival.value, "min_time_between_triggers_seconds", null)
          wait_after_last_change_seconds    = lookup(file_arrival.value, "wait_after_last_change_seconds", null)
        }
      }
    }
  }


  dynamic "git_source" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].git_source, [])

    content {
      url      = lookup(git_source.value, "url", null)
      provider = lookup(git_source.value, "provider", null)
      branch   = lookup(git_source.value, "branch", null)
      tag      = lookup(git_source.value, "tag", null)
      commit   = lookup(git_source.value, "commit", null)
    }
  }


  dynamic "parameter" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].parameter, [])

    content {
      name    = lookup(parameter.value, "name", null)
      default = lookup(parameter.value, "name", null)
    }
  }

  dynamic "notification_settings" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].notification_settings, [])

    content {
      no_alert_for_skipped_runs  = lookup(notification_settings.value, "no_alert_for_skipped_runs", null)
      no_alert_for_canceled_runs = lookup(notification_settings.value, "no_alert_for_canceled_runs", null)
    }

  }
  dynamic "job_cluster" {
    for_each = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].job_cluster, [])
    content {
      job_cluster_key = lookup(job_cluster.value, "job_cluster_key", null)

      dynamic "new_cluster" {
        for_each = lookup(job_cluster.value, "new_cluster", [])
        content {
          instance_pool_id = lookup(new_cluster.value, "instance_pool_id", null)
          node_type_id     = lookup(new_cluster.value, "node_type_id", "Standard_DS3_v2")
          spark_version    = lookup(new_cluster.value, "spark_version", null)
          spark_env_vars   = lookup(new_cluster.value, "spark_env_vars", null)
          spark_conf       = lookup(new_cluster.value, "spark_conf", null)

          dynamic "autoscale" {
            for_each = lookup(new_cluster.value, "autoscale", [])
            content {
              min_workers = lookup(autoscale.value, "min_workers", 1)
              max_workers = lookup(autoscale.value, "max_workers", 8)
            }
          }
        }
      }
    }
  }
}

# Directories that will be replicated

resource "databricks_directory" "new_directories" {
  provider         = databricks.dr_site
  count            = length(local.unique_directory_paths)
  path             = local.unique_directory_paths[count.index]
  delete_recursive = true
}

# Databricks Notebooks that will be replicated

resource "databricks_notebook" "new_notebooks" {
  provider       = databricks.dr_site
  count          = length(data.databricks_notebook.existing_notebooks)
  content_base64 = data.databricks_notebook.existing_notebooks[count.index].content
  path           = data.databricks_notebook.existing_notebooks[count.index].path
  language       = data.databricks_notebook.existing_notebooks[count.index].language
  format         = "SOURCE"

  depends_on = [databricks_directory.new_directories]
}

# Databricks SQL Warehouse that will be replicated

resource "databricks_sql_endpoint" "sql_warehouse" {
  provider                  = databricks.dr_site
  count                     = length(tolist(data.databricks_sql_warehouses.all.ids))
  name                      = data.databricks_sql_warehouse.sqlw[count.index].name
  cluster_size              = data.databricks_sql_warehouse.sqlw[count.index].cluster_size
  min_num_clusters          = data.databricks_sql_warehouse.sqlw[count.index].min_num_clusters
  max_num_clusters          = data.databricks_sql_warehouse.sqlw[count.index].max_num_clusters
  auto_stop_mins            = try(data.databricks_sql_warehouse.sqlw[count.index].auto_stop_mins, 0)
  spot_instance_policy      = data.databricks_sql_warehouse.sqlw[count.index].spot_instance_policy
  enable_photon             = data.databricks_sql_warehouse.sqlw[count.index].enable_photon
  warehouse_type            = data.databricks_sql_warehouse.sqlw[count.index].warehouse_type
  enable_serverless_compute = data.databricks_sql_warehouse.sqlw[count.index].enable_serverless_compute

  dynamic "channel" {
    for_each = try(to_list(data.databricks_sql_warehouse.sqlw[count.index].channel), [])

    content {
      name = lookup(channel.value, "name", "CHANNEL_NAME_CURRENT")
    }
  }
}

# Databricks files to be replicated

resource "databricks_dbfs_file" "new_dbfs_files" {
  provider       = databricks.dr_site
  count          = length(local.flattened_library_paths)
  content_base64 = data.databricks_dbfs_file.existing_dbfs_files[count.index].content
  path           = local.flattened_library_paths[count.index].path
}

# Databricks Libraries that will be installed in each cluster

resource "databricks_library" "new_libraries" {
  provider   = databricks.dr_site
  count      = length(local.cluster_library_combinations)
  cluster_id = local.cluster_library_combinations[count.index].cluster_id
  whl        = local.cluster_library_combinations[count.index].library_path

  depends_on = [databricks_dbfs_file.new_dbfs_files, databricks_cluster.new_cluster]
}


