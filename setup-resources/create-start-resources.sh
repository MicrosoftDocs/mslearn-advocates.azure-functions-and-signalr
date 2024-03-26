# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
# To run: sign in to Azure CLI with `az login`
set -e

# Check if user is logged into Azure CLI
if ! az account show &> /dev/null
then
  echo "You are not logged into Azure CLI. Please log in with 'az login' and try again."
  exit 1
fi
echo "User logged in"

NODE_ENV_FILE="./.env"

SUBSCRIPTION_NAME="Concierge Subscription"

az account set --subscription "$SUBSCRIPTION_NAME"
echo "User default subscription set to $SUBSCRIPTION_NAME"

RESOURCE_GROUP_NAME=$(az group list --query '[0].name' -o tsv)
echo "Using resource group $RESOURCE_GROUP_NAME"

export STORAGE_ACCOUNT_NAME=signalr$(openssl rand -hex 5)
export COMSOSDB_NAME=signalr-cosmos-$(openssl rand -hex 5)

echo "Subscription Name: $SUBSCRIPTION_NAME"
echo "Resource Group Name: $RESOURCE_GROUP_NAME"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "CosmosDB Name: $COMSOSDB_NAME"

echo "Creating Storage Account"

az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --kind StorageV2 \
  --sku Standard_LRS

echo "Creating CosmosDB Account"

  az cosmosdb create  \
  --name $COMSOSDB_NAME \
  --resource-group $RESOURCE_GROUP_NAME

echo "Get storage connection string"

STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
--name $(az storage account list \
  --resource-group $RESOURCE_GROUP_NAME \
  --query [0].name -o tsv) \
--resource-group $RESOURCE_GROUP_NAME \
--query "connectionString" -o tsv)

echo "Get account name" 

COSMOSDB_ACCOUNT_NAME=$(az cosmosdb list \
    --resource-group $RESOURCE_GROUP_NAME \
    --query [0].name -o tsv)

echo "Get CosmosDB connection string"

COSMOSDB_CONNECTION_STRING=$(az cosmosdb list-connection-strings \
  --name $COSMOSDB_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

echo "Get CosmosDB master key"

COSMOSDB_MASTER_KEY=$(az cosmosdb list-keys \
  --name $COSMOSDB_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query primaryMasterKey -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING"

# create a .env file with the connection strings and keys
cat >> $NODE_ENV_FILE <<EOF2
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
COSMOSDB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING
COSMOSDB_MASTER_KEY=$COSMOSDB_MASTER_KEY
EOF2