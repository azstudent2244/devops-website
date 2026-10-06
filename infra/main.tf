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

resource "azurerm_resource_group" "site1" {
  name     = "rg-devops-site1"                                  
  location = "westeurope"                                      
}

resource "azurerm_resource_group" "site" {
  name     = "rg-devops-site"                                  
  location = "westeurope"                                      
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