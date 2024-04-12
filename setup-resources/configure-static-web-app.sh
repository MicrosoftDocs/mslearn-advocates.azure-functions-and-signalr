#!/bin/bash

# Get the default subscription
SUBSCRIPTION_NAME=$(az account show --query 'name' -o tsv)
echo "Using default subscription: $SUBSCRIPTION_NAME"

# Set the resource group name
RESOURCE_GROUP_NAME="stock-prototype"

# Get the first Cosmos DB account in the resource group
echo "Getting the first Cosmos DB account in the resource group..."
cosmosDbAccount=$(az cosmosdb list --resource-group $resourceGroup --query '[0].name' -o tsv)
echo "Cosmos DB Account: $cosmosDbAccount"

# Get the connection string for the Cosmos DB account
echo "Getting the connection string for the Cosmos DB account..."
cosmosDbConnectionString=$(az cosmosdb keys list --name $cosmosDbAccount --resource-group $resourceGroup --type connection-strings --query 'connectionStrings[0].connectionString' -o tsv)
echo "Cosmos DB Connection String: $cosmosDbConnectionString"

# Get the first SignalR service in the resource group
echo "Getting the first SignalR service in the resource group..."
signalrName=$(az signalr list --resource-group $resourceGroup --query '[0].name' -o tsv)
echo "SignalR Service Name: $signalrName"

# Get the connection string for the SignalR service
echo "Getting the connection string for the SignalR service..."
signalrConnectionString=$(az signalr key list --name $signalrName --resource-group $resourceGroup --query 'primaryConnectionString' -o tsv)
echo "SignalR Connection String: $signalrConnectionString"

# Get the first Static Web App in the resource group
echo "Getting the first Static Web App in the resource group..."
staticWebAppName=$(az staticwebapp list --resource-group $resourceGroup --query '[0].name' -o tsv)
echo "Static Web App Name: $staticWebAppName"

# Add the environment variable to the Static Web App
echo "Adding the environment variables to the Static Web App..."
az staticwebapp appsettings set --name $staticWebAppName --resource-group $resourceGroup --setting-names SIGNALR_CONNECTION_STRING=$signalrConnectionString COSMOSDB_CONNECTION_STRING=$cosmosDbConnectionString
echo "Set environment variables."