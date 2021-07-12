# Deploy to Azure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Feature for Azure provider (required)
provider "azurerm" {
  features {}
}

# Resource group for our infrastructure
resource "azurerm_resource_group" "mlops_demo_rg" {
  name     = "JoshPriceMLOpsDemo"
  location = "West Europe"
}

# Premium databricks workspace
resource "azurerm_databricks_workspace" "databricks_workspace_demo" {
  name                = "joshpricedatabricks-demo"
  resource_group_name = azurerm_resource_group.mlops_demo_rg.name
  location            = azurerm_resource_group.mlops_demo_rg.location
  sku                 = "premium"
}

# Public Storage account for storing things
resource "azurerm_storage_account" "storage_account_demo" {
  name                     = "joshpricemlopsstorage"
  resource_group_name      = azurerm_resource_group.mlops_demo_rg.name
  location                 = azurerm_resource_group.mlops_demo_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
}

# Public Storage container for storing things
resource "azurerm_storage_container" "storage_container_demo" {
  name                  = "joshpricemlopsstoragectr"
  storage_account_name  = azurerm_storage_account.storage_account_demo.name
  container_access_type = "blob"
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster_demo" {
  name                = "jpkubernetes-demo"
  resource_group_name = azurerm_resource_group.mlops_demo_rg.name
  location            = azurerm_resource_group.mlops_demo_rg.location
  dns_prefix          = "joshpricemlopsdemo"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}