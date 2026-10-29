resource "azurerm_container_registry" "acr" {

    name = "acrdevops${var.name_suffix}"
    resource_group_name = azurerm_resource_group.site.name
    location = azurerm_resource_group.site.location
    sku = "Basic"
    admin_enabled = true
}

resource "azurerm_log_analytics_workspace" "logs" {
  name = "log-devops-${var.name_suffix}"
  resource_group_name = azurerm_resource_group.site.name
  location = azurerm_resource_group.site.location
  sku = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_container_app_environment" "env" {
  name = "cae-devops-${var.name_suffix}"
  resource_group_name = azurerm_resource_group.site.name
  location = azurerm_resource_group.site.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id
}


resource "azurerm_container_app" "site" {
  for_each = toset (["dev", "test", "prod"])
  name = "ca-devops-${each.key}-${var.name_suffix}"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name = azurerm_resource_group.site.name
  revision_mode = "Single"

  registry {
    server = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name = "acr-password"
    value = azurerm_container_registry.acr.admin_password
  }

  ingress {
    external_enabled = true
    target_port = 80

    traffic_weight {
      percentage = 100
      latest_revision = true
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name = "site"
      image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu = 0.25
      memory = "0.5Gi"

      env {
        name = "ENVIRONMENT_NAME"
        value = each.key
      }
    }
  }

  tags = {
    environment = each.key
  }

  lifecycle {
    ignore_changes = [ template[0].container[0].image ]
  }
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "container_app_urls" {
  value = { for env, app in azurerm_container_app.site : env => "https://${app.ingress[0].fqdn}"}
}