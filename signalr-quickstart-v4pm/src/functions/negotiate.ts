import { app, InvocationContext, input } from "@azure/functions";

const inputSignalR = input.generic({
    type: 'signalRConnectionInfo',
    name: 'connectionInfo',
    hubName: 'qsV4pm',
    connectionStringSetting: 'SIGNALR_CONNECTION_STRING',
});

app.post('negotiate', {
    authLevel: 'anonymous',
    handler: (request, context) => {
        return { body: JSON.stringify(context.extraInputs.get(inputSignalR)) }
    },
    route: 'negotiate',
    extraInputs: [inputSignalR],
});