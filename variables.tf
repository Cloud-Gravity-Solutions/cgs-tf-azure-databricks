# Variable for existing resource group name

variable "existing_resource_group_name" {
  type        = string
  description = "Name of existing resource group"

  validation {
    condition     = var.existing_resource_group_name != null
    error_message = "Please provide a value for the existing_resource_group_name"
  }
}

# Variable for new resource group where new databricks exist

variable "new_db_resource_group_name" {
  type        = string
  description = "Name of existing resource group"

  validation {
    condition     = var.new_db_resource_group_name != null
    error_message = "Please provide a value for the new_db_resource_group_name"
  }
}

# Variable for new resource group where new databricks exist

variable "db_workspaces" {
  type        = list(string)
  description = "Name of existing databricks services"

  validation {
    condition     = var.db_workspaces != null
    error_message = "Please provide a value for the db_workspaces"
  }
}

# Variable to retrieve list of instance pools

variable "existing_instance_pools" {
  type        = list(string)
  description = "Name of existing instance pools"

  validation {
    condition     = var.existing_instance_pools != null
    error_message = "Please provide a value for the existing_instance_pools"
  }
}

# Variable to retrieve list of databricks notebooks

variable "existing_databricks_notebooks" {
  type        = list(string)
  description = "Name of existing databricks notebooks"

  validation {
    condition     = var.existing_databricks_notebooks != null
    error_message = "Please provide a value for the existing_databricks_notebooks"
  }
}

# Variable to get list of databricks folders

# variable "existing_databricks_folders" {
#   type        = list(string)
#   description = "Name of existing databricks folders"

#   validation {
#     condition     = var.existing_databricks_folders != null
#     error_message = "Please provide a value for the existing_databricks_folders"
#   }
# }

variable "databricks_cluster_autoscale" {
  type        = any
  description = "Configuration of databricks cluster autoscale"
  default     = null
}