const client = require('./db.js');
const fs = require('fs');

const DB_NAME = "stocksdb";
const COLLECTION_NAME = "stocks";

const MIN = 100;
const MAX = 999;

const init = async () => {

  const database = client.database(DB_NAME);
  const container = database.container(COLLECTION_NAME);

  return { database, container };
}

const getPriceChange = () => {
  const change = MIN + (Math.random() * (MAX - MIN));
  const value = Math.round(change);
  return parseFloat((value / 100).toFixed(2));
}

const getStockChangeValues = (existingStock) => {

  console.log(`existingStock: ${JSON.stringify(existingStock)}`);

  const isChangePositive = !(existingStock.changeDirection === '+');
  const change = getPriceChange();
  let price = isChangePositive ? existingStock.price + change : existingStock.price - change;
  price = parseFloat(price.toFixed(2));

  return {
    price,
    change,
    changeDirection: isChangePositive ? '+' : '-'
  };
};

const updateData = async ()  => {

  const data = fs.readFileSync('data.json', 'utf8');
  const items = JSON.parse(data);

  const { container } = await init();

  const doc = await container.item(items[0].id, items[0].symbol);
  const docRead = await doc.read();
  const existingStock = docRead.resource;  

  const updates = getStockChangeValues(existingStock);
  const updatedStock = { ...existingStock, ...updates };

  await doc.replace(updatedStock);

};

updateData().catch(err => {
  console.error(err);
});
