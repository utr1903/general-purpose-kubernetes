#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --destroy)
      flagDestroy="true"
      shift
      ;;
    --dry-run)
      flagDryRun="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set parameters
owner="utr1903"

terraformProject="nr1general"
terraformVersion="001"

aksProject="nr1playground"
aksLocation="westeurope"
aksInstance="001"
aksVersion="1.27.1"

### Set variables
terraformResourceGroupName="rg${owner}${terraformProject}${terraformVersion}"
terraformStorageAccountName="st${owner}${terraformProject}${terraformVersion}"
terraformBlobContainerName="${terraformProject}tfstates"

aksResourceGroupName="rg${owner}${aksProject}${aksInstance}"
aksResourceName="aks${owner}${aksProject}${aksInstance}"
aksNodepoolResourceGroupName="rgaks${owner}${aksProject}${aksInstance}"

# Create backend config
azureAccount=$(az account show)
tenantId=$(echo $azureAccount | jq .tenantId)
subscriptionId=$(echo $azureAccount | jq .id)

echo -e 'tenant_id='"${tenantId}"'
subscription_id='"${subscriptionId}"'
resource_group_name=''"'${terraformResourceGroupName}'"''
storage_account_name=''"'${terraformStorageAccountName}'"''
container_name=''"'${terraformBlobContainerName}'"''
key=''"'${aksResourceName}.tfstate'"''' \
> ../terraform/backend.config

if [[ $flagDestroy != "true" ]]; then

  # Initialise Terraform
  terraform -chdir=../terraform init \
    --backend-config="./backend.config"

  # Plan Terraform
  terraform -chdir=../terraform plan \
    -var aks_resource_group_name=$aksResourceGroupName \
    -var aks_resource_name=$aksResourceName \
    -var aks_nodepool_resource_name=$aksNodepoolResourceGroupName \
    -var aks_version=$aksVersion \
    -var location=$aksLocation \
    -out "./tfplan"

    if [[ $flagDryRun != "true" ]]; then
    
      # Apply Terraform
      terraform -chdir=../terraform apply tfplan

      # Get AKS credentials
      az aks get-credentials \
        --resource-group $aksResourceGroupName \
        --name $aksResourceName \
        --overwrite-existing
    fi
else

  # Destroy resources
  terraform -chdir=../terraform destroy \
    -var aks_resource_group_name=$aksResourceGroupName \
    -var aks_resource_name=$aksResourceName \
    -var aks_nodepool_resource_name=$aksNodepoolResourceGroupName \
    -var aks_version=$aksVersion \
    -var location=$location
fi
