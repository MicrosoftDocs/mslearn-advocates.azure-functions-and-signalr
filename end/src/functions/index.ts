import { app, InvocationContext, HttpRequest, HttpResponseInit } from "@azure/functions";
import { readFile } from 'fs/promises';

export async function httpTrigger1(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    const content = await readFile('public/index.html', 'utf8');

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