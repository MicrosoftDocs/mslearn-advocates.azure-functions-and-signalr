# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr

az account set --subscription "Concierge Subscription"
RESOURCE_GROUP_NAME=$(az group list --query '[0].name' -o tsv)

export STORAGE_ACCOUNT_NAME=mslsigrstorage$(openssl rand -hex 5)
export COMSOSDB_NAME=mslsigr-cosmos-$(openssl rand -hex 5)

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

COSMOSDB_CONNECTION_STRING=$(az cosmosdb list --type connection-strings  \
  --name $COSMOSDB_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --query "connectionStrings[?description=='Primary SQL Connection String'].connectionString" -o tsv)

echo "Get CosmosDB master key"

COSMOSDB_MASTER_KEY=$(az cosmosdb list --type keys \
--name $COSMOSDB_ACCOUNT_NAME \
--resource-group $RESOURCE_GROUP_NAME \
--query primaryMasterKey -o tsv)

printf "\n\nReplace <STORAGE_CONNECTION_STRING> with:\n$STORAGE_CONNECTION_STRING\n\nReplace <COSMOSDB_CONNECTION_STRING> with:\n$COSMOSDB_CONNECTION_STRING\n\nReplace <COSMOSDB_MASTER_KEY> with:\n$COSMOSDB_MASTER_KEY\n\n"