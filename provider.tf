provider "databricks" {
  alias = "primary_site"
  host  = data.azurerm_databricks_workspace.primary_db.workspace_url
}

provider "databricks" {
  alias = "dr_site"
  host  = data.azurerm_databricks_workspace.secondary_db.workspace_url
}