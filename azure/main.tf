# Create subnet
resource "azurerm_subnet" "hu19bcsachinsubnet" {
    name                 = "hu19-bcsachin-subnet"
    resource_group_name  = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    virtual_network_name = "hu19-tf-vnet"
    address_prefixes       = ["10.1.128.0/22"]
}

# Create public IPs
resource "azurerm_public_ip" "hu19hu19bcsachinsubnetip" {
    name                         = "hu19-hu19bcsachin-ip"
    location                     = "EAST US"
    resource_group_name          = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
    allocation_method            = "Dynamic"

    tags = {
        environment = "HU-19"
        "createdby" = "linker-bcsachin"
        "managedby" = "terraform"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "hu19bcsachinnsg" {
    name = "hu19bcsachinnsg"
    location                     = "EAST US"
    resource_group_name          = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
  
    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "HU-19"
        "createdby" = "linker-bcsachin"
        "managedby" = "terraform"
    }
}

# Create network interface
resource "azurerm_network_interface" "hu19bcsachinnic" {
    name                      = "hu19-bcsachin-nic"
   location                     = "EAST US"
    resource_group_name          = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
  
    ip_configuration {
        name                          = "hu19-bcsachin-nic-config"
        subnet_id                     = azurerm_subnet.hu19bcsachinsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.hu19bcsachinip.id
    }

    tags = {
        environment = "HU-19"
        "createdby" = "linker-bcsachin"
        "managedby" = "terraform"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "hu19bcsachinnsgassoc" {
    network_interface_id      = azurerm_network_interface.hu19bcsachinnic.id
    network_security_group_id = azurerm_network_security_group.hu19bcsachinnsg.id
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "hu19bcsachinstorageacc" {
    name                        = "hu19bcsachinstorage"
    location                     = "EAST US"
    resource_group_name          = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
   account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "HU-19"
        "createdby" = "linker-bcsachin"
        "managedby" = "terraform"
    }
}

# Create (and display) an SSH key
resource "tls_private_key" "bcsexample_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "azurerm_storage_container" "hu19bcsachinstoragecontainer" {
  name                  = "hu19-bcsachin-container"
  storage_account_name  = azurerm_storage_account.hu19bcsachinstorageacc.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "hu19bcsachinblob" {
  name                   = "hu19-bcsachin-blob"
  storage_account_name   = azurerm_storage_account.hu19bcsachinstorageacc.name
  storage_container_name = azurerm_storage_container.hu19bcsachinstoragecontainer.name
  type                   = "Block"
  source                 = "terraform.tfstate"
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "hu19bcsachinvm" {
    name                  = "hu19-bcsachin-vm"
    location                     = "EAST US"
    resource_group_name          = "AZRG_USE2_CON_NPDHASHEDINAZUREINTERNALPOC-NPD-002"
   network_interface_ids = [azurerm_network_interface.hu19bcsachinnic.id]
    size                  = "Standard_DS1_v2"
    custom_data = filebase64("cloud-init.sh")
    os_disk {
        name              = "bcsachin-Disk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "hu19-bcsachinv-vm"
    admin_username = "bcsachin"
    admin_password = "bcsachin@1234"
    disable_password_authentication = false



    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.hu19bcsachinstorageacc.primary_blob_endpoint
    }

    tags = {
        environment = "HU-19"
        "createdby" = "linker-bcsachin"
        "managedby" = "terraform"
    }
}