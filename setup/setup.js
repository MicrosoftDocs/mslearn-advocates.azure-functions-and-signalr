const client = require('./db.js');
const fs = require('fs');


const databaseDefinition = { id: "stocksdb" };
const collectionDefinition = { id: "stocks", 
partitionKey: {
  paths: ["/symbol"]
} };

const setupAndSeedDatabase = async ()  => {

  const data = fs.readFileSync('data.json', 'utf8');
  const items = JSON.parse(data);

  const { database: db } = await client.databases.create(databaseDefinition);
  console.log('Database created.');

  const { container } = await db.containers.create(collectionDefinition);
  console.log('Collection created.');

  for await (const item of items) {
    await container.items.create(item);
    console.log(`Seed data added. Symbol ${item.symbol}`);
  }
};

setupAndSeedDatabase().catch(err => {
  console.error('Error setting up database:', err);
});
