import 'dotenv/config'

import {
    CosmosClient,
  } from "@azure/cosmos";

let endpoint = '';
let client = null;

const key = process.env.COSMOSDB_MASTER_KEY;
const matches = process.env.COSMOSDB_CONNECTION_STRING.match(/(https.*?);/);

console.log('Connection string: ' + process.env.COSMOSDB_CONNECTION_STRING);
console.log('Key: ' + key);

if(matches && matches.length > 1) {
    endpoint = matches[1];
    client = new CosmosClient({ endpoint, key });
} else {
    console.log('Cannot locate Cosmos DB endpoint from connection string.');
}

export default client;