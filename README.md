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

* Start: uses polling every minute
* End: uses database change notifications and SignalR

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
    
    name: Build and deploy Node.js project to Azure Function App - signalr-3
    
    on:
      push:
        branches:
          - main
      workflow_dispatch:
    
    env:
      PACKAGE_PATH: 'server-end' # set this to the path to your web app project, defaults to the repository root
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
              zip -r ../release.zip .
              popd
            
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
              client-id: ${{ secrets.AZUREAPPSERVICE_CLIENTID_7953CE71DA404164BBBC35F07ECDD4FD }}
              tenant-id: ${{ secrets.AZUREAPPSERVICE_TENANTID_853880B11FFD4142A37B35F0DBD5C55D }}
              subscription-id: ${{ secrets.AZUREAPPSERVICE_SUBSCRIPTIONID_3B05BF95EF5440AF941C3AECF9FF10CD }}
    
          - name: 'Run Azure Functions Action'
            uses: Azure/functions-action@v1
            id: fa
            with:
              app-name: 'signalr-3'
              slot-name: 'Production'
              package: ${{ env.AZURE_FUNCTIONAPP_PACKAGE_PATH }}
   ```
   


1. Deploy the frontend to Azure Static Web Apps in Standard plan type (not free) in order to use [bring your own backend](https://learn.microsoft.com/azure/static-web-apps/functions-bring-your-own) (byob).

    Workflow file should include this section:

    ```yaml
    name: Azure Static Web Apps CI/CD
    
    on:
      push:
        branches:
          - main
      pull_request:
        types: [opened, synchronize, reopened, closed]
        branches:
          - main
    
    jobs:
      build_and_deploy_job:
        if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
        runs-on: ubuntu-latest
        name: Build and Deploy Job
        steps:
          - uses: actions/checkout@v3
            with:
              submodules: true
              lfs: false
          - name: Build And Deploy
            id: builddeploy
            uses: Azure/static-web-apps-deploy@v1
            with:
              azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_LIVELY_BUSH_0E5550C0F }}
              repo_token: ${{ secrets.GITHUB_TOKEN }} # Used for Github integrations (i.e. PR comments)
              action: "upload"
              ###### Repository/Build Configurations - These values can be configured to match your app requirements. ######
              # For more information regarding Static Web App workflow configurations, please visit: https://aka.ms/swaworkflowconfig
              app_location: "/client-end" # App source code path
              api_location: "" # Api source code path - optional
              output_location: "dist" # Built app content directory - optional
              ###### End of Repository/Build Configurations ######
    
      close_pull_request_job:
        if: github.event_name == 'pull_request' && github.event.action == 'closed'
        runs-on: ubuntu-latest
        name: Close Pull Request Job
        steps:
          - name: Close Pull Request
            id: closepullrequest
            uses: Azure/static-web-apps-deploy@v1
            with:
              azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN_LIVELY_BUSH_0E5550C0F }}
              action: "close"
    ```

    BYOB doesn't rely on the `api_locaton` property to find the APIs. Once linked, you can access the Functions App `api` endpoints through the api path from your static web app. This means the client doesn't have to know the backend URL because it uses its own URL for that purpose. 

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
