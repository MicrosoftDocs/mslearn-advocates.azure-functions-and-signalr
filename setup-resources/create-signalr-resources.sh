# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
# To run: sign in to Azure CLI with `az login`
set -e

NODE_ENV_FILE="./.env"

SUBSCRIPTION_NAME="Concierge Subscription"

az account set --subscription "$SUBSCRIPTION_NAME"
echo "User default subscription set to $SUBSCRIPTION_NAME"

RESOURCE_GROUP_NAME=$(az group list --query '[0].name' -o tsv)
echo "Using resource group $RESOURCE_GROUP_NAME"

SIGNALR_SERVICE_NAME="msl-sigr-signalr$(openssl rand -hex 5)"

echo "Subscription Name: $SUBSCRIPTION_NAME"
echo "Resource Group Name: $RESOURCE_GROUP_NAME"
echo "SignalR Service Name: $SIGNALR_SERVICE_NAME"

echo "Creating SignalR Account"
az signalr create \
    --name $SIGNALR_SERVICE_NAME \
    --resource-group $RESOURCE_GROUP_NAME \
    --sku Free_DS2 \
    --unit-count 1

echo "Configure SignalR for serverless mode"
az resource update \
  --resource-type Microsoft.SignalRService/SignalR \
  --name $SIGNALR_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --set properties.features[flag=ServiceMode].value=Serverless

  echo "Get SignalR connection string"

  SIGNALR_CONNECTION_STRING=$(az signalr key list \
  --name $(az signalr list \
    --resource-group $RESOURCE_GROUP_NAME \
    --query [0].name -o tsv) \
  --resource-group $RESOURCE_GROUP_NAME \
  --query primaryConnectionString -o tsv)

# Add the SignalR connection string to the .env file
echo -e "\nSIGNALR_CONNECTION_STRING=$SIGNALR_CONNECTION_STRING" >> $NODE_ENV_FILE

printf "\n\nReplace <SIGNALR_CONNECTION_STRING> with:\n$SIGNALR_CONNECTION_STRING"

