import { app, output, CosmosDBv4FunctionOptions, InvocationContext } from "@azure/functions";

const goingOutToSignalR = output.generic({
    type: 'signalR',
    name: 'signalR',
    hubName: 'default',
    connectionStringSetting: 'SIGNALR_CONNECTION_STRING',
});

export async function dataToMessage(documents: unknown[], context: InvocationContext): Promise<void> {

    documents.map(stock => {
        // @ts-ignore
        context.log(`Get price ${stock.symbol} ${stock.price}`);
        context.extraOutputs.set(goingOutToSignalR,
            {
                'target': 'updated',
                'arguments': [stock]
            });
    });
}

const options: CosmosDBv4FunctionOptions = {
    connection: 'COSMOSDB_CONNECTION_STRING',
    databaseName: 'stocksdb',
    containerName: 'stocks',
    createLeaseContainerIfNotExists: true,
    feedPollDelay: 500,
    handler: dataToMessage,
    extraOutputs: [goingOutToSignalR],
};

app.cosmosDB('documents', options);

