import { app, input } from "@azure/functions";

app.http('status', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: (request, context) => {

        return {
            jsonBody: process.env,
        };
    },
});