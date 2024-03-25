# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
set -e

FUNCTIONS_ENV_FILE="./local.settings.json"
NODE_ENV_FILE="./.env"

#SUBSCRIPTION_NAME="Concierge Subscription"
SUBSCRIPTION_NAME="b57b253a-e19e-4a9c-a0c0-a5062910a749"

az account set --subscription $SUBSCRIPTION_NAME

#RESOURCE_GROUP_NAME=$(az group list --query '[0].name' -o tsv)
RESOURCE_GROUP_NAME="signalr"
SIGNALR_SERVICE_NAME="msl-sigr-signalr$(openssl rand -hex 5)"

echo "Subscription Name: $SUBSCRIPTION_NAME"
echo "Resource Group Name: $RESOURCE_GROUP_NAME"

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

echo "SignalR Connection String: $SIGNALR_CONNECTION_STRING"

# Update local.settings.json with the SignalR connection string
JSON="{\"SIGNALR_CONNECTION_STRING\": \"$SIGNALR_CONNECTION_STRING\"}"

# Use jq to update the local.settings.json file at the Values level with the JSON object
jq --argjson json "$JSON" '.Values += $json' $FUNCTIONS_ENV_FILE > temp.json && mv temp.json $FUNCTIONS_ENV_FILE

# Add the SignalR connection string to the .env file
echo -e "\nSIGNALR_CONNECTION_STRING=$SIGNALR_CONNECTION_STRING" >> $NODE_ENV_FILE
