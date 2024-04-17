import { app, output, CosmosDBv4FunctionOptions, InvocationContext } from "@azure/functions";

let goingOutToSignalR;

const comingFromCosmosDB: CosmosDBv4FunctionOptions = {
    connection: 'COSMOSDB_CONNECTION_STRING',
    databaseName: 'stocksdb',
    containerName: 'stocks',
    createLeaseContainerIfNotExists: true,
    feedPollDelay: 500,
    handler: dataToMessage,
    extraOutputs: [goingOutToSignalR],
};
goingOutToSignalR = output.generic({
    type: 'signalR',
    name: 'signalR',
    hubName: 'default',
    connectionStringSetting: 'SIGNALR_CONNECTION_STRING',
});
export async function dataToMessage(documents: unknown[], context: InvocationContext): Promise<void> {

    try {

        context.log(`Documents: ${JSON.stringify(documents)}`);

        documents.map(stock => {
            // @ts-ignore
            context.log(`Get price ${stock.symbol} ${stock.price}`);
            context.extraOutputs.set(goingOutToSignalR,
                {
                    'target': 'updated',
                    'arguments': [stock]
                });
        });
    } catch (error) {
        context.log(`Error: ${error}`);
    }
}


app.cosmosDB('send-signalr-messages', comingFromCosmosDB);
