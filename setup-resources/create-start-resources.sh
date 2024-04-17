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

NODE_ENV_FILE=".env"

#SUBSCRIPTION_NAME=""
#az account set --subscription "$SUBSCRIPTION_NAME"
echo "User default subscription set to $SUBSCRIPTION_NAME"

export STORAGE_ACCOUNT_NAME=signalr$(openssl rand -hex 5)
export COMSOSDB_NAME=signalr-cosmos-$(openssl rand -hex 5)
export LOCATION=eastus

# Create resource group and set it to variable
# Continue if resource group already exists

export RESOURCE_GROUP_NAME="stock-prototype"
az group create \
  --subscription $SUBSCRIPTION_NAME \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION
echo "Using resource group $RESOURCE_GROUP_NAME"


echo "Subscription Name: $SUBSCRIPTION_NAME"
echo "Resource Group Name: $RESOURCE_GROUP_NAME"
echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
echo "CosmosDB Name: $COMSOSDB_NAME"

echo "Creating Storage Account"

az storage account create \
  --subscription $SUBSCRIPTION_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $STORAGE_ACCOUNT_NAME \
  --kind StorageV2 \
  --sku Standard_LRS

echo "Creating CosmosDB Account"

az cosmosdb create  \
  --subscription $SUBSCRIPTION_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $COMSOSDB_NAME 

echo "Get storage connection string"

export STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
--name $(az storage account list \
  --subscription $SUBSCRIPTION_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query [0].name -o tsv) \
--subscription $SUBSCRIPTION_NAME \
--resource-group $RESOURCE_GROUP_NAME \
--query "connectionString" -o tsv)

echo "Get account name" 

export COSMOSDB_ACCOUNT_NAME=$(az cosmosdb list \
    --subscription $SUBSCRIPTION_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --query [0].name -o tsv)

echo "Get CosmosDB connection string"

export COSMOSDB_CONNECTION_STRING=$(az cosmosdb keys list --type connection-strings \
  --subscription $SUBSCRIPTION_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --name $COSMOSDB_ACCOUNT_NAME \
  --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING"

# create a .env file with the connection strings and keys
cat >> $NODE_ENV_FILE <<EOF2
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
COSMOSDB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING
EOF2