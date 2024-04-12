import { promises as fs } from 'fs';
import * as path from 'path';

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

export const updateData = async ()  => {

  const pathToData = path.join(__dirname, './data.json');
  const data = await fs.readFile(pathToData, 'utf8');
  const items = JSON.parse(data);

  const existingStock = items[Math.floor(Math.random() * items.length)];

  const updates = getStockChangeValues(existingStock);
  const updatedStock = { ...existingStock, ...updates };

  console.log(`updatedStock: ${JSON.stringify(updatedStock)}`);

  return updatedStock;

};