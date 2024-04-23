# To use the Microsoft Learn Sandbox in the training module
# https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr
# To run: sign in to Azure CLI with `az login`
set -e


# Check if user is logged into Azure CLI
if ! az account show &> /dev/null
then
  prinft "You are not logged into Azure CLI. Please log in with 'az login' and try again.\n"
  exit 1
fi
printf "User logged in\n"

NODE_ENV_FILE="./.env"

# Get the default subscription
SUBSCRIPTION_NAME=$(az account show --query 'name' -o tsv)


# Set the SignalR service name
SIGNALR_SERVICE_NAME="msl-sigr-signalr$(openssl rand -hex 5)"

printf "Subscription Name: ""$SUBSCRIPTION_NAME"" \n"
printf "SignalR Service Name: $SIGNALR_SERVICE_NAME\n"

printf "Creating SignalR Account\n"
az signalr create \
    --name "$SIGNALR_SERVICE_NAME" \
    --sku Free_DS2

printf "Configure SignalR for serverless mode\n"

az resource update \
  --resource-type Microsoft.SignalRService/SignalR \
  --name "$SIGNALR_SERVICE_NAME" \
  --set properties.features[flag=ServiceMode].value=Serverless

printf "Get SignalR connection string\n"

SIGNALR_CONNECTION_STRING=$(az signalr key list \
  --name $(az signalr list \
    --query [0].name -o tsv) \
  --query primaryConnectionString -o tsv)

# Add the SignalR connection string to the .env file
echo -e "\nSIGNALR_CONNECTION_STRING=$SIGNALR_CONNECTION_STRING" >> $NODE_ENV_FILE

printf "\n\nReplace <SIGNALR_CONNECTION_STRING> with:\n$SIGNALR_CONNECTION_STRING"

