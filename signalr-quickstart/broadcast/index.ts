import { AzureFunction, Context } from "@azure/functions"
var https = require('https');

var etag = '';
var star = 0;

const timerTrigger: AzureFunction = async function (context: Context, myTimer: any): Promise<void> {
    
    const randomNumber = Math.floor(Math.random() * 100);

            context.bindings.signalRMessages = [{
                "target": "newMessage",
                "arguments": [ `Current star count of https://github.com/Azure/azure-signalr is: ${randomNumber}` ]
            }]
};

export default timerTrigger;
