# Databricks Cluster/Clusters that will be created in new region

resource "databricks_cluster" "new_cluster" {
  count                        = length(local.cluster_ids_list)
  cluster_name                 = join("", [count.index, data.databricks_cluster.existing_cluster[count.index].cluster_info[0].cluster_name])
  spark_version                = data.databricks_cluster.existing_cluster[count.index].cluster_info[0].spark_version
  node_type_id                 = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].node_type_id, null)
  runtime_engine               = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].runtime_engine, null)
  instance_pool_id             = can(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].node_type_id) ? null : try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].instance_pool_id, null)
  policy_id                    = try(data.databricks_cluster.existing_cluster[count.index].cluster_info[0].policy_id, null)
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

# Databricks jobs to be replicated to the new region

resource "databricks_job" "new_jobs" {
  count             = length(data.databricks_jobs.existing_jobs.ids)
  name              = join("-", [count.index, "job"])
  control_run_state = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].control_run_state, null)
  timeout_seconds   = try(data.databricks_job.existing_job[count.index].job_settings[0].settings[0].timeout_seconds, 15)

  dynamic "task" {
    for_each = data.databricks_job.existing_job[count.index].job_settings[0].settings[0].task
    content {
      task_key                  = lookup(task.value, "task_key", null)
      run_if                    = lookup(task.value, "run_if", null)
      retry_on_timeout          = lookup(task.value, "retry_on_timeout", null)
      max_retries               = lookup(task.value, "max_retries", null)
      min_retry_interval_millis = lookup(task.value, "min_retry_interval_millis", null)
      timeout_seconds           = lookup(task.value, "timeout_seconds", null)
      existing_cluster_id       = lookup(task.value, "existing_cluster_id", null)

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
          num_workers    = lookup(new_cluster.value, "num_workers", null)
          spark_version  = lookup(new_cluster.value, "spark_version", null)
          spark_env_vars = lookup(new_cluster.value, "spark_env_vars", null)
          spark_conf     = lookup(new_cluster.value, "spark_conf", null)
        }
      }
    }
  }
}

# Azure Databricks Instance Pools that will be replicated

resource "databricks_instance_pool" "new_instance_pools" {
  count                                 = length(var.existing_instance_pools)
  instance_pool_name                    = join("-", [count.index, "ip"])
  idle_instance_autotermination_minutes = data.databricks_instance_pool.existing_pools[count.index].pool_info[0].idle_instance_autotermination_minutes
  node_type_id                          = data.databricks_instance_pool.existing_pools[count.index].pool_info[0].node_type_id
  min_idle_instances                    = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].min_idle_instances)
  max_capacity                          = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].max_capacity)
  enable_elastic_disk                   = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].enable_elastic_disk)
  preloaded_spark_versions              = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].preloaded_spark_versions)

  dynamic "gcp_attributes" {
    for_each = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].gcp_attributes, [])

    content {
      gcp_availability = lookup(gcp_attributes.value, "gcp_availability", null)
      local_ssd_count  = lookup(gcp_attributes.value, "local_ssd_count", null)
    }
  }

  dynamic "azure_attributes" {
    for_each = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].azure_attributes, [])

    content {
      availability       = lookup(azure_attributes.value, "availability", null)
      spot_bid_max_price = lookup(azure_attributes.value, "spot_bid_max_price", null)
    }
  }

  dynamic "aws_attributes" {
    for_each = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].aws_attributes, [])

    content {
      zone_id                = lookup(aws_attributes.value, "zone_id", null)
      spot_bid_price_percent = lookup(aws_attributes.value, "spot_bid_price_percent", null)
      availability           = lookup(aws_attributes.value, "availability", null)
    }

  }
  dynamic "disk_spec" {
    for_each = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].disk_spec, [])

    content {
      disk_count = lookup(disk_spec.value, "disk_count", null)
      disk_size  = lookup(disk_spec.value, "disk_size", null)

      dynamic "disk_type" {
        for_each = lookup(disk_spec.value, "disk_type", [])

        content {
          ebs_volume_type        = lookup(disk_type.value, "ebs_volume_type", null)
          azure_disk_volume_type = lookup(disk_type.value, "azure_disk_volume_type", null)
        }
      }
    }
  }

  dynamic "preloaded_docker_image" {
    for_each = try(data.databricks_instance_pool.existing_pools[count.index].pool_info[0].preloaded_docker_image, [])

    content {
      url = lookup(preloaded_docker_image.value, "url", null)
      dynamic "basic_auth" {
        for_each = lookup(preloaded_docker_image.value, "basic_auth", [])

        content {
          username = lookup(basic_auth.value, "username", null)
          password = lookup(basic_auth.value, "password", null)
        }
      }
    }
  }
}

# Directories that will be replicated

resource "databricks_directory" "new_directories" {
  # count = length(local.flattened_notebook_paths)
  path  = data.databricks_directory.prod.path
}

# Databricks Notebooks that will be replicated

resource "databricks_notebook" "new_notebooks" {
  count    = length(local.flattened_notebook_paths)
  path     = local.flattened_notebook_paths[count.index].path
  language = local.flattened_notebook_paths[count.index].language
}

# Databricks SQL Warehouse that will be replicated

resource "databricks_sql_endpoint" "sql_warehouse" {
  count                     = length(tolist(data.databricks_sql_warehouses.all.ids))
  name                      = "${data.databricks_sql_warehouse.sqlw[count.index].name}-replica"
  cluster_size              = data.databricks_sql_warehouse.sqlw[count.index].cluster_size
  min_num_clusters          = data.databricks_sql_warehouse.sqlw[count.index].min_num_clusters
  max_num_clusters          = data.databricks_sql_warehouse.sqlw[count.index].max_num_clusters
  auto_stop_mins            = data.databricks_sql_warehouse.sqlw[count.index].auto_stop_mins
  spot_instance_policy      = data.databricks_sql_warehouse.sqlw[count.index].spot_instance_policy
  enable_photon             = data.databricks_sql_warehouse.sqlw[count.index].enable_photon
  warehouse_type            = data.databricks_sql_warehouse.sqlw[count.index].warehouse_type
  enable_serverless_compute = data.databricks_sql_warehouse.sqlw[count.index].enable_serverless_compute
  channel {
    name = length(data.databricks_sql_warehouse.sqlw[count.index].channel) > 0 ? data.databricks_sql_warehouse.sqlw[count.index].channel[0].name : "CHANNEL_NAME_CURRENT"
  }
}


