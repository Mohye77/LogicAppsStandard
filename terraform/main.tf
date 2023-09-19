resource "azurerm_resource_group" "rg" {
  name     = "rg-cellenza-blog"
  location = "West Europe"
}

resource "azurerm_application_insights" "appinsight" {
  name                = "appi-cellenza-blog"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"
}

resource "azurerm_storage_account" "storage" {
  name                     = "sacellenzablog"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "plan-cellenza-blog"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "elastic"

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}

resource "azurerm_logic_app_standard" "logicapp" {
  name                       = "logic-cellenza-blog"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key
  version                    = "~4"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"              = "node"
    "WEBSITE_NODE_DEFAULT_VERSION"          = "~18",
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.appinsight.instrumentation_key,
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.appinsight.connection_string
  }

  identity {
    type = "SystemAssigned"
  }
}
