---
page_type: sample
languages:
- javascript
- typescript
- nodejs
products:
- azure
- azure-cosmos-db
- azure-functions
- azure-signalr
- azure-storage
- vs-code
urlFragment: azure-functions-and-signalr-javascript
name: "Enable real-time updates in a web application using Azure Functions and SignalR Service"
description: Change a JavaScript web app update mechanism from polling to real-time push-based architecture with SignalR Service, Azure Cosmos DB and Azure Functions. Use Vue.js and JavaScript to use SignalR using Visual Studio Code.
---

# SignalR with Azure Functions triggers and bindings

This repository is the companion to the following training module:

* [Enable automatic updates in a web application using Azure Functions and SignalR Service](https://learn.microsoft.com/training/modules/automatic-update-of-a-webapp-using-azure-functions-and-signalr/)

This solution displays fake stock prices as they update: 

* [Start](./start): uses polling every minute
* [Solution](./solution): uses database change notifications and SignalR

## Set up resources

The Azure resources are created from bash scripts in the `setup-resources` folder. This includes creating:

* Azure Cosmos DB
* Azure SignalR
* Azure Storage (for Azure Function triggers)

## Ports

* Client: 3000: built with webpack
* Server: 7071: build with Azure Functions core tools

## Starting project without SignalR

The starting project updates stock prices in a Cosmos DB database every minute with an Azure Function app and a timer trigger. The client polls for all the stock prices. 

## Ending project

The starting project updates stock prices in a Cosmos DB database every minute with an Azure Function app and a timer trigger. The client uses SignalR to recieve on the Cosmos DB items with change notifications through an Azure Functions app. 

## Deploy to Azure Static Web Apps and Azure Functions App

1. Deploy the backend to Azure Functions App.

    GitHub Action workflow file should look like:

   ```yaml
    # Docs for the Azure Web Apps Deploy action: https://github.com/azure/functions-action
    # More GitHub Actions for Azure: https://github.com/Azure/actions
    
    name: Server - Build and deploy Node.js project to Azure Function App
    
    on:
      push:
        branches:
          - main
      workflow_dispatch:
    
    env:
      # solution/server is the finished path
      # start/server is the original path you work on
      PACKAGE_PATH: 'solution/server' # set this to the path to your web app project, defaults to the repository root
      AZURE_FUNCTIONAPP_PACKAGE_PATH: '.'
      NODE_VERSION: '20.x' # set this to the node version to use (supports 8.x, 10.x, 12.x)
    
    jobs:
      build:
        runs-on: ubuntu-latest
        steps:
          - name: 'Checkout GitHub Action'
            uses: actions/checkout@v4
    
          - name: Setup Node ${{ env.NODE_VERSION }} Environment
            uses: actions/setup-node@v3
            with:
              node-version: ${{ env.NODE_VERSION }}
    
          - name: 'Resolve Project Dependencies Using Npm'
            shell: bash
            run: |
              pushd './${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}/${{ env.PACKAGE_PATH}}'
              npm install
              npm run build --if-present
              npm run test --if-present
              popd
    
          - name: Zip artifact for deployment
            run: |
              pushd './${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}/${{ env.PACKAGE_PATH}}'
              zip -r release.zip .
              popd
              cp ./${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}/${{ env.PACKAGE_PATH }}/release.zip ./release.zip
            
          - name: Upload artifact for deployment job
            uses: actions/upload-artifact@v3
            with:
              name: node-app
              path: release.zip
    
      deploy:
        runs-on: ubuntu-latest
        needs: build
        environment:
          name: 'Production'
          url: ${{ steps.deploy-to-webapp.outputs.webapp-url }}
        permissions:
          id-token: write #This is required for requesting the JWT
    
        steps:
          - name: Download artifact from build job
            uses: actions/download-artifact@v3
            with:
              name: node-app
    
          - name: Unzip artifact for deployment
            run: unzip release.zip
          
          - name: Login to Azure
            uses: azure/login@v1
            with:
              client-id: ${{ secrets.AZUREAPPSERVICE_CLIENTID_123 }}
              tenant-id: ${{ secrets.AZUREAPPSERVICE_TENANTID_123 }}
              subscription-id: ${{ secrets.AZUREAPPSERVICE_SUBSCRIPTIONID_123 }}
    
          - name: 'Run Azure Functions Action'
            uses: Azure/functions-action@v1
            id: fa
            with:
              app-name: 'signalr-3'
              slot-name: 'Production'
              package: ${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}
   ```
   


1. Deploy the frontend to Azure Static Web Apps in Standard plan type (not free) in order to use [bring your own backend](https://learn.microsoft.com/azure/static-web-apps/functions-bring-your-own) (byob).

   * Azure Cloud: Choose the Vue.js prebuild template then edit for this example, using the [example client workflow](example-client-workflow.yml). The build relies on the injection of the repo variable to find the BACKEND_URL value during SWA build and deploy. The webpack Dotenv param for `systemvars: true` brings in the value from the GitHub step to the webpack build.

   * Local: The client build on the local machine depends on a `.env` file at the root of the client application.

1. In Azure Functions, enable CORS for the client URL and check `Enable Access-Control-Allow-Credentials`.

## Resources

* [Azure SignalR service documentation](https://learn.microsoft.com/azure/azure-signalr/)
* [Azure SignalR service samples](https://github.com/aspnet/AzureSignalR-samples)
* [Azure Functions triggers and bindings for SignalR](https://learn.microsoft.com/azure/azure-functions/functions-bindings-signalr-service)

## Trademark Notice

Trademarks This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow [Microsoft’s Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general). Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Legal Notices

Microsoft and any contributors grant you a license to the Microsoft documentation and other content
in this repository under the [Creative Commons Attribution 4.0 International Public License](https://creativecommons.org/licenses/by/4.0/legalcode),
see the [LICENSE](LICENSE) file, and grant you a license to any code in the repository under the [MIT License](https://opensource.org/licenses/MIT), see the
[LICENSE-CODE](LICENSE-CODE) file.

Microsoft, Windows, Microsoft Azure and/or other Microsoft products and services referenced in the documentation
may be either trademarks or registered trademarks of Microsoft in the United States and/or other countries.
The licenses for this project do not grant you rights to use any Microsoft names, logos, or trademarks.
Microsoft's general trademark guidelines can be found at http://go.microsoft.com/fwlink/?LinkID=254653.

Privacy information can be found at https://privacy.microsoft.com/en-us/

Microsoft and any contributors reserve all other rights, whether under their respective copyrights, patents,
or trademarks, whether by implication, estoppel or otherwise.
