terraform {                                                 
  required_providers {
    azurerm = {                                               
      source  = "hashicorp/azurerm"                            
      version = "~> 4.0"                                      
    }
  }

   backend "azurerm" {                                       
    resource_group_name  = "rg-tfstate"                      
    storage_account_name = "sttfstateak301"                    
    container_name        = "tfstate"                           
    key                   = "devops-session2.tfstate"          
  }
}
provider "azurerm" {
  features {}                                                  
  use_cli = true                                              
}

variable "name_suffix" {
  type = string
  description = "Short unique suffix"
}

resource "azurerm_resource_group" "site" {
  name     = "rg-devops-site"                                  
  location = "westeurope"                                      
}

resource "azurerm_service_plan" "site" {
  name = "asp-devops-site"
  resource_group_name = azurerm_resource_group.site.name
  location = azurerm_resource_group.site.location
  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "site" {
  for_each = toset(["dev", "test", "prod"])
  name = "app-devops-${each.key}-${var.name_suffix}"
  resource_group_name = azurerm_resource_group.site.name
  location = azurerm_service_plan.site.location
  service_plan_id = azurerm_service_plan.site.id
  https_only = true

  site_config {
    application_stack {
      php_version = "8.3"
    }
  }
  app_settings = {
    ENVIRONMENT_NAME = each.key 
  }

  tags = {
    environment = each.key
  }


}











resource "azurerm_storage_account" "site" {
  name                     = "st1devops2sitejsm01"                
  resource_group_name      = azurerm_resource_group.site.name    
  location                 = azurerm_resource_group.site.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.site.id
  index_document     = "index.html"
}

output "website_endpoint" {
  value = azurerm_storage_account.site.primary_web_endpoint      
}

output "storage_account_name" {
  value = azurerm_storage_account.site.name                     
}