import client from './db.js';
import {promises as fs} from 'fs';


const databaseDefinition = { id: "stocksdb" };
const collectionDefinition = { id: "stocks", 
partitionKey: {
  paths: ["/symbol"]
} };

const setupAndSeedDatabase = async ()  => {

  const data = await fs.readFile('data.json', 'utf8');
  const items = JSON.parse(data);

  const { database: db } = await client.databases.createIfNotExists(databaseDefinition);
  console.log('Database created.');

  const { container } = await db.containers.createIfNotExists(collectionDefinition);
  console.log('Collection created.');

  for await (const item of items) {
    await container.items.create(item);
    console.log(`Seed data added. Symbol ${item.symbol}`);
  }
};

setupAndSeedDatabase().catch(err => {
  console.error('Error setting up database:', err);
});
