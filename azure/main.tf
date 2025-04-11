# main.tf
resource "azurerm_resource_group" "azure-test" {
  name     = "azure-test"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "azure-test-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.azure-test.location
  resource_group_name = azurerm_resource_group.azure-test.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.azure-test.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "azure-test-ip"
  location            = azurerm_resource_group.azure-test.location
  resource_group_name = azurerm_resource_group.azure-test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ssh-nsg"
  location            = azurerm_resource_group.azure-test.location
  resource_group_name = azurerm_resource_group.azure-test.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "azure-test-nic"
  location            = azurerm_resource_group.azure-test.location
  resource_group_name = azurerm_resource_group.azure-test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ubuntu-vm"
  resource_group_name = azurerm_resource_group.azure-test.name
  location            = azurerm_resource_group.azure-test.location
  size                = "Standard_F4ams_v6"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}

data "azurerm_public_ip" "vm_public_ip" {
  name                = azurerm_public_ip.public_ip.name
  resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
}
output "public_ip_address" {
  description = "The public IP address of the virtual machine"
  value       = data.azurerm_public_ip.vm_public_ip.ip_address
}
