import 'dotenv/config'

import {
    CosmosClient,
  } from "@azure/cosmos";

let client = null;

const connString = process.env.COSMOSDB_CONNECTION_STRING;

console.log('Connection string: ' + process.env.COSMOSDB_CONNECTION_STRING);

if(connString) {
    client = new CosmosClient(connString);
} else {
    console.log('Cannot locate Cosmos DB endpoint from connection string.');
}

export default client;