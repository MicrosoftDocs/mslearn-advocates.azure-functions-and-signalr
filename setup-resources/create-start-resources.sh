# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
# To run: sign in to Azure CLI with `az login`
set -e

# Check if user is logged into Azure CLI
if ! az account show &> /dev/null
then
  printf "You are not logged into Azure CLI. Please log in with 'az login' and try again."
  exit 1
fi
printf "User logged in\n"

NODE_ENV_FILE="./.env"

# Get user name
USER_NAME=$(az account show --query 'user.name' -o tsv)
# Capture name before `@` in user.name
USER_NAME=${USER_NAME%%@*}
printf "User name: $USER_NAME\n"

# Get the default subscription if not provided as a parameter
SUBSCRIPTION_NAME=$1
printf "Using subscription: $SUBSCRIPTION_NAME\n"

# Set the resource group name if not provided as a parameter
RANDOM_STRING=$(openssl rand -hex 5)
printf "Using random string: $RANDOM_STRING\n"
RESOURCE_GROUP_NAME="$USER_NAME-signal-r-$RANDOM_STRING"

# Create a resource group
az group create \
  --subscription $SUBSCRIPTION_NAME \
  --name "$RESOURCE_GROUP_NAME" \
  --location eastus

printf "Using resource group $RESOURCE_GROUP_NAME"

exit 0

export STORAGE_ACCOUNT_NAME=signalr$(openssl rand -hex 5)
export COMSOSDB_NAME=signalr-cosmos-$(openssl rand -hex 5)

printf "Subscription Name: $SUBSCRIPTION_NAME"
printf "Resource Group Name: $RESOURCE_GROUP_NAME"
printf "Storage Account Name: $STORAGE_ACCOUNT_NAME"
printf "CosmosDB Name: $COMSOSDB_NAME"

printf "Creating Storage Account"

az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --kind StorageV2 \
  --sku Standard_LRS

printf "Creating CosmosDB Account"

  az cosmosdb create  \
  --name $COMSOSDB_NAME \
  --resource-group $RESOURCE_GROUP_NAME

printf "Get storage connection string"

STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
--name $(az storage account list \
  --resource-group $RESOURCE_GROUP_NAME \
  --query [0].name -o tsv) \
--resource-group $RESOURCE_GROUP_NAME \
--query "connectionString" -o tsv)

printf "Get account name" 

COSMOSDB_ACCOUNT_NAME=$(az cosmosdb list \
    --resource-group $RESOURCE_GROUP_NAME \
    --query [0].name -o tsv)

printf "Get CosmosDB connection string"

COSMOSDB_CONNECTION_STRING=$(az cosmosdb keys list --type connection-strings \
  --name $COSMOSDB_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING"

# create a .env file with the connection strings and keys
cat >> $NODE_ENV_FILE <<EOF2
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
COSMOSDB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING
EOF2

# put resource group name in .env file
printf -e "RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME" >> $NODE_ENV_FILE
printf "\n\nRESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME"


# Validate the .env file
if [ -f "$NODE_ENV_FILE" ]; then
  printf "\n\nThe .env file was created successfully."
else
  printf "\n\nThe .env file was not created."
fi