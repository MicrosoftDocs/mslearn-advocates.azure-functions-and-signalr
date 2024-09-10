import { app, input } from '@azure/functions';

const inputSignalR = input.generic({
    type: 'signalRConnectionInfo',
    name: 'connectionInfo',
    hubName: 'default',
    connectionStringSetting: 'Endpoint=https://msl-sigr-signalr7bce9a1bc0.service.signalr.net;AccessKey=ENc6GLaw7qWuRyEbaoB2BELvdHze1uBbJAN5MJfduYs=;Version=1.0;%',
});

app.http('open-signalr-connection', {
    authLevel: 'anonymous',
    handler: (request, context) => {
        return { body: JSON.stringify(context.extraInputs.get(inputSignalR)) }
    },
    route: 'negotiate',
    extraInputs: [inputSignalR]
});