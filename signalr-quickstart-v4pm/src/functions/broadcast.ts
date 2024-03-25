import { app, InvocationContext, Timer, output } from "@azure/functions";

const signalR = output.generic({
    type: 'signalR',
    name: 'signalR',
    hubName: 'qsV4pm',
    connectionStringSetting: 'SIGNALR_CONNECTION_STRING',
});

export async function timerTrigger1(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('Timer function processed request.');
    const randomNumber = Math.floor(Math.random() * 100);

    const message = `Current #: ${randomNumber}`;

    context.extraOutputs.set(signalR,
        {
            'target': 'newMessage',
            'arguments': [message]
        });

}

app.timer('timerTrigger1', {
    schedule: '0 * * * * *',
    handler: timerTrigger1,
    extraOutputs: [signalR],
});