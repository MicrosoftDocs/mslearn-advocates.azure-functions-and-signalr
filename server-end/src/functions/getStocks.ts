import { app, input } from "@azure/functions";

const cosmosInput = input.cosmosDB({
    databaseName: 'stocksdb',
    containerName: 'stocks',
    connection: 'AZURE_COSMOS_CONNECTION_STRING_KEY',
    sqlQuery: 'SELECT * from c',
});

app.http('getStocks', {
    methods: ['GET'],
    authLevel: 'anonymous',
    extraInputs: [cosmosInput],
    handler: (request, context) => {
        const stocks = context.extraInputs.get(cosmosInput);
        return {
            jsonBody: stocks,
        };
    },
});