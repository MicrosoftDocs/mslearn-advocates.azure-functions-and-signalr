import { app, InvocationContext, HttpRequest, HttpResponseInit } from "@azure/functions";
import { readFile } from 'fs/promises';

export async function httpTrigger1(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);
    const content = await readFile('content/index.html', 'utf8');

    return {
        status: 200,
        headers: {
            'Content-Type': 'text/html'
        },
        body: content,
    };
};

app.http('index', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: httpTrigger1
});