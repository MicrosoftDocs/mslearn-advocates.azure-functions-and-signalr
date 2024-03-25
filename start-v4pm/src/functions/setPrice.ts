import { app, InvocationContext, Timer, output } from "@azure/functions";
import { updateData } from "../update";

const cosmosOutput = output.cosmosDB({
    databaseName: 'stocksdb',
    containerName: 'stocks',
    connection: 'COSMOSDB_CONNECTION_STRING',
    partitionKey: '/symbol',
    createIfNotExists: false

});

export async function setPrice(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('Timer function processed request.');
    context.log('Timer function processed request.');

    const newStock = await updateData();
    console.log(`timer ${newStock.symbol}: ${newStock.price}`);

}

app.timer('setPrice', {
    schedule: '0 * * * * *',
    extraOutputs: [cosmosOutput],
    handler: setPrice
});
