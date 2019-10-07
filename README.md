---
page_type: sample
description: "The archetypal model of web service stacks, has many different uses from managing friends lists to storing in-game chat conversations to enabling multiplayer matchmaking and more!"
languages:
  - powershell
  - bash
  - batch
  - json
  - php
  - azurecli
products:
  - azure
  - azure-virtual-machines
  - azure-mysql-database
  - azure-storage
  - azure-redis-cache
---

# LAMP for Gaming - Reference Architecture

The archetypal model of web service stacks, has many different uses from managing friends lists to storing in-game chat conversations to enabling multiplayer matchmaking and more!

## Deploy

To deploy the reference architecture to your own account, use the following deployment links below, or alternative use any of the command line scripts in either bash, PowerShell or Windows batch.

| Action | Azure CLI | Azure PowerShell | ARM Template |
|--------|--------|--------|--------|
| **Deploy a Virtual Machine on a Managed Disk** | [1-create-vm.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/1-create-vm.sh)<br>[1-create-vm.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/1-create-vm.bat) | [1-create-vm.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/1-create-vm.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-vm" target="_blank">Deploy</a> |
| **Install Apache, PHP and other stuff you consider** | [2-install-apache-and-php.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/scripts/2-install-apache-and-php.sh) | N/A | <a href="https://aka.ms/arm-gaming-lamp-install-apache-and-php" target="_blank">Deploy</a> | N/A
| **Deallocate and generalize the Virtual Machine** | [3-prepare-vm.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/3-prepare-vm.sh)<br>[3-prepare-vm.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/3-prepare-vm.bat) | [3-prepare-vm.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/3-prepare-vm.ps1) | N/A |
| **Generate the custom golden image** | [4-create-golden-image.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/4-create-golden-image.sh)<br>[4-create-golden-image.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/4-create-golden-image.bat) | [4-create-golden-image.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/4-create-golden-image.ps1) | TODO |
| **Deploy the networking resources** | [5-create-networking.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/5-create-networking.sh)<br>[5-create-networking.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/5-create-networking.bat) | [5-create-networking.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/5-create-networking.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-networking" target="_blank">Deploy Basic LB</a><br><a href="https://aka.ms/arm-gaming-lamp-create-networking-standard" target="_blank">Deploy Standard LB</a> |
| **Deploy the Azure Cache for Redis** | [6-create-redis.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/6-create-redis.sh)<br>[6-create-redis.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/6-create-redis.bat) | [6-create-redis.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/6-create-redis.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-redis" target="_blank">Deploy</a> |
| **Deploy the Azure Database for MySQL** | [7-create-mysql.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/7-create-mysql.sh)<br>[7-create-mysql.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/7-create-mysql.bat) | [7-create-mysql.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/7-create-mysql.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-mysql" target="_blank">Deploy</a> |
| **Create the Azure Storage account and container** | [8-create-storage.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/8-create-storage.sh)<br>[8-create-storage.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/8-create-storage.bat) | [8-create-storage.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/8-create-storage.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-storage" target="_blank">Deploy</a> |
| **Create the Virtual Machine Scale Set** | [9-create-vmss.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/9-create-vmss.sh)<br>[9-create-vmss.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/9-create-vmss.bat) | [9-create-vmss.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/9-create-vmss.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-vmss" target="_blank">Deploy</a> |
| **Setup the autoscale settings** | [10-create-autoscaler.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/10-create-autoscaler.sh)<br>[10-create-autoscaler.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/10-create-autoscaler.bat) | [10-create-autoscaler.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/10-create-autoscaler.ps1) | <a href="https://aka.ms/arm-gaming-lamp-create-autoscaler" target="_blank">Deploy</a> |
| **Enable protection against DDoS attacks** | [11-enable-ddos-protection.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/11-enable-ddos-protection.sh)<br>[11-enable-ddos-protection.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/11-enable-ddos-protection.bat) | [11-enable-ddos-protection.ps1](https://github.com/Azure-Samples/gaming-lamp/blob/master/powershell/11-enable-ddos-protection.ps1) | <a href="https://aka.ms/arm-gaming-lamp-enable-ddos-protection" target="_blank">Deploy</a> |
| **Update the Virtual Machine instances** | [12-update-app.sh](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/bash/12-update-app.sh)<br>[12-update-app.bat](https://github.com/Azure-Samples/gaming-lamp/blob/master/azurecli/windowsbatch/12-update-app.bat) | TODO | <a href="https://aka.ms/arm-gaming-lamp-update-app" target="_blank">Deploy</a> |

Then, please see the full documentation on the [LAMP gaming reference architecture](https://docs.microsoft.com/gaming/azure/reference-architectures/general-purpose-lamp) to learn how it all works.