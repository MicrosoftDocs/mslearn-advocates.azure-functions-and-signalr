
const fs = require('fs');

const DB_NAME = "stocksdb";
const COLLECTION_NAME = "stocks";

const MIN = 100;
const MAX = 999;

const getPriceChange = () => {
  const change = MIN + (Math.random() * (MAX - MIN));
  const value = Math.round(change);
  return parseFloat((value / 100).toFixed(2));
}

const getStockChangeValues = (existingStock) => {

  console.log(`existingStock: ${JSON.stringify(existingStock.symbol)}`);

  const isChangePositive = !(existingStock.changeDirection === '+');
  const change = Number(getPriceChange());
  let price = isChangePositive ? Number(existingStock.price) + change : Number(existingStock.price) - change;
  price = parseFloat(price.toFixed(2));

  return {
    price,
    change,
    changeDirection: isChangePositive ? '+' : '-'
  };
};

const updateData = async ()  => {

  const data = fs.readFileSync('../setup/data.json', 'utf8');
  const items = JSON.parse(data);

  // get random item from items
  const existingStock = items[Math.floor(Math.random() * items.length)];

  const updates = getStockChangeValues(existingStock);
  const updatedStock = { ...existingStock, ...updates };

  return updatedStock;

};

module.exports = updateData;

