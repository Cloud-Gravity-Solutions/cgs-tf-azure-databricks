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

# Variable for existing region

variable "region_name" {
  type        = string
  description = "Name of region where resources will reside"

  validation {
    condition     = var.region_name != null
    error_message = "Please provide a value for the region_name"
  }
}


# Variables for existing workspaces

variable "primary_db" {
  type        = string
  description = "Name of primary databricks"

  validation {
    condition     = var.primary_db != null
    error_message = "Please provide a value for the primary_db"
  }
}

variable "secondary_db" {
  type        = string
  description = "Name of secondary databricks"

  validation {
    condition     = var.secondary_db != null
    error_message = "Please provide a value for the secondary_db"
  }
}


variable "databricks_cluster_autoscale" {
  type        = any
  description = "Configuration of databricks cluster autoscale"
  default     = null
}