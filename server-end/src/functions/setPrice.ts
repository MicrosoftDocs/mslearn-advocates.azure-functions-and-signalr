import { app, InvocationContext, Timer, output } from "@azure/functions";
import { updateData } from "../update";

const cosmosOutput = output.cosmosDB({
    databaseName: 'stocksdb',
    containerName: 'stocks',
    connection: 'COSMOSDB_CONNECTION_STRING',
    partitionKey: 'symbol'
});

export async function setPrice(myTimer: Timer, context: InvocationContext): Promise<void> {

    const newStock = await updateData();

    context.log(`Set Price ${newStock.symbol} ${newStock.price}`);
    context.extraOutputs.set(cosmosOutput, newStock);
}

app.timer('setPrice', {
    schedule: '0 * * * * *',
    extraOutputs: [cosmosOutput],
    handler: setPrice
});