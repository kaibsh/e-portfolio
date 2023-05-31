terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.58.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg-eportfolio" {
  name     = "RG-EPortfolio" 
  location = "westeurope"
}

resource "azurerm_virtual_network" "vn-eportfolio" {
  name                = "VN-EPortfolio"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-eportfolio.location
  resource_group_name = azurerm_resource_group.rg-eportfolio.name
}

resource "azurerm_subnet" "sn-eportfolio" {
  name                 = "SN-EPortfolio"
  resource_group_name  = azurerm_resource_group.rg-eportfolio.name
  virtual_network_name = azurerm_virtual_network.vn-eportfolio.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "ni-eportfolio" {
  name                = "NI-EPortfolio"
  location            = azurerm_resource_group.rg-eportfolio.location
  resource_group_name = azurerm_resource_group.rg-eportfolio.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sn-eportfolio.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "vm-eportfolio" {
  name                = "VM-EPortfolio"
  resource_group_name = azurerm_resource_group.rg-eportfolio.name
  location            = azurerm_resource_group.rg-eportfolio.location
  size                = "Standard_D2s_v4"
  admin_username      = "E-Portfolio-Admin"
  admin_password      = "password123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ni-eportfolio.id,
  ]

  os_disk {
    name                 = "OS-EPortfolio"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-backports-gen2"
    version   = "latest"
  }
}