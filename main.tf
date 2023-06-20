#-------------------------------
# Local Declarations
#-------------------------------
locals {
  resource_group_name      = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  resource_group_id      = element(coalescelist(data.azurerm_resource_group.rgrp.*.id, azurerm_resource_group.rg.*.id, [""]), 0)
  location                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}
#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
    count = var.create_resource_group == false ? 1 : 0
    name = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.resource_group_name) 
  }
  )
}


#---------------------------------------------------------
# SQLMI Creation
#----------------------------------------------------------

resource "azurerm_network_security_group" "sql_nsg" {
  name                = "${var.environment}-${var.solution}-sqlmi-nsg-${var.location_short_ae}-1"
  location            = local.location
  resource_group_name = local.resource_group_name
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.solution}-sqlmi-nsg-${var.location_short_ae}-1"
    }
  )
}

# resource "azurerm_network_security_rule" "allow_management_inbound" {
#   name                        = "allow_management_inbound"
#   priority                    = 106
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_ranges     = ["9000", "9003", "1438", "1440", "1452"]
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

# resource "azurerm_network_security_rule" "allow_misubnet_inbound" {
#   name                        = "allow_misubnet_inbound"
#   priority                    = 200
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "10.0.0.0/24"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

# resource "azurerm_network_security_rule" "allow_health_probe_inbound" {
#   name                        = "allow_health_probe_inbound"
#   priority                    = 300
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "AzureLoadBalancer"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

resource "azurerm_network_security_rule" "allow_tds_inbound" {
  name                        = "allow_tds_inbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1433"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.sql_nsg.name
}

# resource "azurerm_network_security_rule" "deny_all_inbound" {
#   name                        = "deny_all_inbound"
#   priority                    = 4096
#   direction                   = "Inbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

# resource "azurerm_network_security_rule" "allow_management_outbound" {
#   name                        = "allow_management_outbound"
#   priority                    = 102
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_ranges     = ["80", "443", "12000"]
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

# resource "azurerm_network_security_rule" "allow_misubnet_outbound" {
#   name                        = "allow_misubnet_outbound"
#   priority                    = 200
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "10.0.0.0/24"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

# resource "azurerm_network_security_rule" "deny_all_outbound" {
#   name                        = "deny_all_outbound"
#   priority                    = 4096
#   direction                   = "Outbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = local.resource_group_name
#   network_security_group_name = azurerm_network_security_group.sql_nsg.name
# }

resource "azurerm_subnet_network_security_group_association" "sqlmi_association" {
  subnet_id                 = var.sqlmi_subnet_id
  network_security_group_id = azurerm_network_security_group.sql_nsg.id
}


resource "azurerm_mssql_managed_instance" "this_sqlmi" {
  name                = "${var.environment}-${var.solution}-sqlmi-${var.location_short_ae}-1"
  location                      = local.location
  resource_group_name           = local.resource_group_name

  license_type       = "BasePrice"
  sku_name           = "GP_Gen5"
  storage_size_in_gb = 32
  subnet_id          = var.sqlmi_subnet_id
  vcores             = 4

  administrator_login          = "sqladministrator"
  administrator_login_password = var.sql_admin_password
  timezone_id                  = "New Zealand Standard Time"

  identity {
    type = "SystemAssigned"
  }

  timeouts {
    create = "300m"
    update = "90m"
    read   = "5m"
    delete = "300m"
  }
  depends_on = [
    azurerm_subnet_network_security_group_association.sqlmi_association
  ]
  tags = merge(
    var.common_tags,
    {
      Name        = "${var.environment}-${var.solution}-sqlmi-${var.location_short_ae}-1"
    }
  )
}

#---------------------------------------------------------
# Enable TDE encryption
#----------------------------------------------------------
resource "azurerm_mssql_managed_instance_transparent_data_encryption" "sqlmi_transparent_data_encryption" {
  managed_instance_id            = azurerm_mssql_managed_instance.this_sqlmi.id
  key_vault_key_id      = var.keyvault_key_id
}

#---------------------------------------------------------
# Send SQLMI vulnerability assessment results to a conatiner
#----------------------------------------------------------

resource "azurerm_mssql_managed_instance_security_alert_policy" "alert_policy" {
  resource_group_name        = local.resource_group_name
  managed_instance_name      = azurerm_mssql_managed_instance.this_sqlmi.name
  enabled                    = true
  storage_endpoint           = var.storage_endpoint
  storage_account_access_key = var.sa_access_key 
  retention_days             = 90
}

resource "azurerm_mssql_managed_instance_vulnerability_assessment" "security_assessment" {
  managed_instance_id        = azurerm_mssql_managed_instance.this_sqlmi.id
  storage_container_path     = var.sa_conatiner_path 
  storage_account_access_key = var.sa_access_key 

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      "hATSHOCloudSupport@healthalliance.co.nz",
      "hatsisvulnerability@healthalliance.co.nz"
    ]
  }
  depends_on = [azurerm_mssql_managed_instance_security_alert_policy.alert_policy]
}

#---------------------------------------------------------
# SET AAD admin
#----------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azuread_directory_role" "reader" {
  display_name = "Directory Readers"
}

# Role assignment below requires the ADO service connection to be manually 
# temporarily granted the Privileged Role Administrator role in PIM beforehand
resource "azuread_directory_role_assignment" "sql_managed_instance" {
  role_id             = azuread_directory_role.reader.object_id
  principal_object_id = azurerm_mssql_managed_instance.this_sqlmi.identity.0.principal_id
}

resource "azurerm_mssql_managed_instance_active_directory_administrator" "sql_managed_instance" {
  managed_instance_id = azurerm_mssql_managed_instance.this_sqlmi.id
  login_username      = var.ad_admin_group
  object_id           = var.ad_admin_group_object_id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  
  depends_on = [azuread_directory_role_assignment.sql_managed_instance]
}