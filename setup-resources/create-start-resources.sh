# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
# To run: sign in to Azure CLI with `az login`
#
# bash create-start-resources.sh "SUBSCRIPTION_NAME_OR_ID"
#


set -e

printf "Param 1: $1\n"

LOCATION="eastus2"
printf "Location: $LOCATION\n"

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
# Set default subscription
az configure --defaults subscription="$SUBSCRIPTION_NAME"
printf "Using subscription: ""$SUBSCRIPTION_NAME""\n"

# Set the resource group name if not provided as a parameter
RANDOM_STRING=$(openssl rand -hex 5)
#printf "Using random string: $RANDOM_STRING\n"
RESOURCE_GROUP_NAME="$USER_NAME-signalr-$RANDOM_STRING"

# Create a resource group
az group create \
  --subscription "$SUBSCRIPTION_NAME" \
  --name "$RESOURCE_GROUP_NAME" \
  --location $LOCATION

# Set default resource group
az configure --defaults group="$RESOURCE_GROUP_NAME"

printf "Using resource group $RESOURCE_GROUP_NAME\n"

export STORAGE_ACCOUNT_NAME=signalr$(openssl rand -hex 5)
export COMSOSDB_NAME=signalr-cosmos-$(openssl rand -hex 5)

printf "Subscription Name: ""$SUBSCRIPTION_NAME"" \n"
printf "Resource Group Name: $RESOURCE_GROUP_NAME\n"
printf "Storage Account Name: $STORAGE_ACCOUNT_NAME\n"
printf "CosmosDB Name: $COMSOSDB_NAME\n"

printf "Creating Storage Account\n"

az storage account create \
  --subscription "$SUBSCRIPTION_NAME" \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --kind StorageV2 \
  --sku Standard_LRS

printf "Creating CosmosDB Account\n"

az cosmosdb create  \
  --subscription "$SUBSCRIPTION_NAME" \
  --name $COMSOSDB_NAME \
  --resource-group $RESOURCE_GROUP_NAME

printf "Creating CosmosDB db\n"
# Create stocksdb database
az cosmosdb sql database create \
    --account-name $COMSOSDB_NAME \
    --name stocksdb

printf "Creating CosmosDB container\n"
# Create stocks container
az cosmosdb sql container create \
    --account-name $COMSOSDB_NAME \
    --database-name stocksdb \
    --name stocks \
    --partition-key-path /symbol

printf "Get storage connection string\n"

STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
--name $(az storage account list \
  --resource-group $RESOURCE_GROUP_NAME \
  --query [0].name -o tsv) \
--resource-group $RESOURCE_GROUP_NAME \
--query "connectionString" -o tsv)

printf "Get account name \n" 

COSMOSDB_ACCOUNT_NAME=$(az cosmosdb list \
    --subscription "$SUBSCRIPTION_NAME" \
    --resource-group $RESOURCE_GROUP_NAME \
    --query [0].name -o tsv)

printf "Get CosmosDB connection string \n"

COSMOSDB_CONNECTION_STRING=$(az cosmosdb keys list --type connection-strings \
  --name $COSMOSDB_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --subscription "$SUBSCRIPTION_NAME" \
  --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING"

# create a .env file with the connection strings and keys
cat >> $NODE_ENV_FILE <<EOF2
STORAGE_CONNECTION_STRING=$STORAGE_CONNECTION_STRING
COSMOSDB_CONNECTION_STRING=$COSMOSDB_CONNECTION_STRING
EOF2

# put resource group name in .env file
echo -e "RESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME" >> $NODE_ENV_FILE
printf "\n\nRESOURCE_GROUP_NAME=$RESOURCE_GROUP_NAME"


# Validate the .env file
if [ -f "$NODE_ENV_FILE" ]; then
  printf "\n\nThe .env file was created successfully."
else
  printf "\n\nThe .env file was not created."
fi