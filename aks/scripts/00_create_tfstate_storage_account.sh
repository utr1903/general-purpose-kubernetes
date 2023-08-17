#!/bin/bash

### Set parameters
owner="utr1903"
project="nr1general"
location="westeurope"
instance="001"

### Set variables
resourceGroupName="rg${owner}${project}${instance}"
storageAccountName="st${owner}${project}${instance}"
blobContainerName="${project}tfstates"

# Resource group
echo "Checking shared resource group [${resourceGroupName}]..."
resourceGroup=$(az group show \
  --name $resourceGroupName \
  2> /dev/null)

if [[ $resourceGroup == "" ]]; then
  echo " -> Shared resource group does not exist. Creating..."

  resourceGroup=$(az group create \
    --name $resourceGroupName \
    --location $location)

  echo -e " -> Shared resource group is created successfully.\n"
else
  echo -e " -> Shared resource group already exists.\n"
fi

# Storage account
echo "Checking shared storage account [${storageAccountName}]..."
storageAccount=$(az storage account show \
    --resource-group $resourceGroupName \
    --name $storageAccountName \
  2> /dev/null)

if [[ $storageAccount == "" ]]; then
  echo " -> Shared storage account does not exist. Creating..."

  storageAccount=$(az storage account create \
    --resource-group $resourceGroupName \
    --name $storageAccountName \
    --sku "Standard_LRS" \
    --allow-blob-public-access true \
    --encryption-services "blob")

  echo -e " -> Shared storage account is created successfully.\n"
else
  echo -e " -> Shared storage account already exists.\n"
fi

# Terraform blob container
echo "Checking Terraform blob container [${blobContainerName}]..."
terraformBlobContainer=$(az storage container show \
  --account-name $storageAccountName \
  --name $blobContainerName \
  2> /dev/null)

if [[ $terraformBlobContainer == "" ]]; then
  echo " -> Terraform blob container does not exist. Creating..."

  terraformBlobContainer=$(az storage container create \
    --account-name $storageAccountName \
    --name $blobContainerName \
    2> /dev/null)

  echo -e " -> Terraform blob container is created successfully.\n"
else
  echo -e " -> Terraform blob container already exists.\n"
fi
