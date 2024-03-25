const cosmos = require('@azure/cosmos');
const CosmosClient = cosmos.CosmosClient;
const fs = require('fs');

const settings = JSON.parse(fs.readFileSync('local.settings.json', 'utf8'));

let endpoint = '';
let client = null;

const masterKey = settings.Values.AzureCosmosDBMasterKey;
const matches = settings.Values.AzureCosmosDBConnectionString.match(/(https.*?);/);

if(matches && matches.length > 1) {
    endpoint = matches[1];
    client = new CosmosClient({ endpoint, auth: { masterKey } });
} else {
    console.log('Cannot locate Cosmos DB endpoint from connection string.');
}

module.exports = client;