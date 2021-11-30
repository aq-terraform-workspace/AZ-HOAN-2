
# ============================ #
# This script will create a storage account for terraform backend
# Set ARM_ACCESS_KEY env to storage account access key
# ============================ #
#!/bin/bash

export RESOURCE_GROUP_NAME=tfstate
export STORAGE_ACCOUNT_NAME=tfstate4445
export CONTAINER_NAME=tfstate

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location southeastasia

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Get storage account key
# ACCOUNT_KEY=$(az storage account keys list --resource-group tfstate --account-name tfstate4445 --query [0].value -o tsv)
export ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query [0].value -o tsv)

# Create blob container
# az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"

export ARM_ACCESS_KEY=$ACCOUNT_KEY
# export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name tfstateVault --query value -o tsv)

# References:
# https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage