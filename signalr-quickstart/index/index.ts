import { AzureFunction, Context, HttpRequest } from "@azure/functions"
import { promises as fs } from 'fs';

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
    const path = context.executionContext.functionDirectory + '/../content/index.html'
    try {
        var data = await fs.readFile(path);
        context.res = {
            headers: {
                'Content-Type': 'text/html'
            },
            body: data
        }
       
    } catch (err) {
        context.log.error(err);
        context.done(err);
    }

};

export default httpTrigger;