1. 2nd Project Cloud Gravity Solutions

# Terraform Module: Resource Replication

This Terraform module provisions the same existing databricks workspace in a new resource group in another location, to be used for DR strategy along with Azure Devops. 

## Authors
- [Marko Skendo](https://github.com/ingmarko)
- [Ditmir Spahiu](https://github.com/DitmirSpahiu)

## List of Replicated Resources

1- Azure Databricks Clusters


2- Azure Databricks Notebooks


3- Azure Databricks Folders


4- Azure Databricks Libraries


5- Azure Databricks DBFS Files


6- Azure Databricks Instance Pools


7- Azure Databricks Jobs & Tasks


8- Azure Databricks SQL Warehouses


## How to Use

### Variables

| Name                           | Description                                         | Type         | Default | Required |
|--------------------------------|-----------------------------------------------------|:------------:|:-------:|:--------:|
| `existing_resource_group_name` | Name of the existing resource group.                | `string`     | n/a     | yes      |
| `new_db_resource_group_name`   | Name of the new resource group for the database.    | `string`     | n/a     | yes      |
| `primary_db`                   | Name of the primary databricks workspace.          | `string`     | n/a     | yes      |
| `secondary_db`                 | Name of the secondary databricks workspace.        | `string`     | n/a     | yes      |
| `existing_instance_pools`      | List of existing instance pools to replicate.      | `list(string)` | n/a   | yes      |
| `existing_databricks_notebooks`| List of existing databricks notebooks to replicate.| `list(string)` | n/a   | yes      |
| `region_name`                  | Region where the resources will be replicated.     | `string`     | n/a     | yes      |

### Example with ALL Variables:

```hcl
module "databricks-rep" {
  source                        = "path/to/module/files"
  new_db_resource_group_name    = "test"
  primary_db                    = "test"
  secondary_db                  = "test"  
  existing_resource_group_name  = "test"
  existing_instance_pools       =["test-cgs-instance-pool""test-cgs-instance-pool-2"]
  existing_databricks_notebooks = ["test-folder", "test-folder-2", "test-cgs"]
  region_name                   = "westeurope"
}