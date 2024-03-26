import { app, InvocationContext, CosmosDBOutputOptions, Timer, output } from "@azure/functions";
import { updateData } from "../update";

const cosmosOutputConfig: CosmosDBOutputOptions = {
    databaseName: 'stocksdb',
    containerName: 'stocks',
    connection: 'COSMOSDB_CONNECTION_STRING',
    partitionKey: 'symbol'
};

const cosmosOutput = output.cosmosDB(cosmosOutputConfig);

export async function setPrice(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('Timer function processed request.');

    const newStock = await updateData();
    console.log(JSON.stringify(newStock));
    context.extraOutputs.set(cosmosOutput, newStock);
}

app.timer('setPrice', {
    schedule: '0 * * * * *',
    extraOutputs: [cosmosOutput],
    handler: setPrice
});