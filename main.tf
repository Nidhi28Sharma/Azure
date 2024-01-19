terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# provider "azurerm" {
#     # subscription_id = "7951adbe-b3bf-4ea1-9cd2-377f532cfe26"
#     # tenant_id = "5202406f-f701-4c8d-bf2c-cd63bca126b9"
#     # client_id = "d44810ad-d5ed-492a-917d-b6658252873a"
#     //client_secret = "4744bd50-fd26-4154-b471-62f71ab09094"
    
#     features {
      
#     }
# }

# Create a resource group
resource "azurerm_resource_group" "test_resource" {
  name     = "Nidhi_Test_Resource"
  location = "West Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "virtual_net" {
  name                = "nidhi-vnet"
  resource_group_name = azurerm_resource_group.test_resource.name  //resource type.  resource name. name
  location            = azurerm_resource_group.test_resource.location //resource type.  resource name. location
  address_space       = ["10.0.0.0/16"]
}

#create a subnet
resource "azurerm_subnet" "sub1" {
  name= "nidhi-subnet"
  resource_group_name = azurerm_resource_group.test_resource.name  //resource type.  resource name. name
  virtual_network_name = azurerm_virtual_network.virtual_net.name  
  address_prefixes     = ["10.0.2.0/24"]
}

#create network interface
resource "azurerm_network_interface" "nidhi_interface" {
  name= "nidhi-interface"
  resource_group_name = azurerm_resource_group.test_resource.name  //resource type.  resource name. name
  location            = azurerm_resource_group.test_resource.location //resource type.  resource name. location
  ip_configuration {
    name                          = "nidhi-ip"
    subnet_id                     = azurerm_subnet.sub1.id // resource type.resource name. id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [ azurerm_subnet.sub1 ]
}

# create a virtual machine
resource "azurerm_virtual_machine" "nidhi-vm" {
  name="nidhi-vm"
  resource_group_name = azurerm_resource_group.test_resource.name  //resource type.  resource name. name
  location            = azurerm_resource_group.test_resource.location //resource type.  resource name. location
  network_interface_ids = [azurerm_network_interface.nidhi_interface.id]
vm_size               = "Standard_DS1_v2"
storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal" //ubuntu
    sku       = "20_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
  depends_on = [ azurerm_network_interface.nidhi_interface, azurerm_resource_group.test_resource ]

}
