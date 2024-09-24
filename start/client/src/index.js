import './style.css';
import { BACKEND_URL } from './env';

const app = new Vue({
    el: '#app',
    data() {
        return {
            stocks: []
        }
    },
    methods: {
        async getStocks() {
            try {

                const url = `${BACKEND_URL}/api/getStocks`;
                console.log('Fetching stocks from ', url);

                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
                }
                app.stocks = await response.json();
            } catch (ex) {
                console.error(ex);
            }
        }
    },
    created() {
        this.getStocks();
    }
});

const connect = () => {

    const signalR_URL = `${BACKEND_URL}/api`;
    console.log(`Connecting to SignalR...${signalR_URL}`)

    const connection = new signalR.HubConnectionBuilder()
                            .withUrl(signalR_URL)
                            .configureLogging(signalR.LogLevel.Information)
                            .build();

    connection.onclose(()  => {
        console.log('SignalR connection disconnected');
        setTimeout(() => connect(), 2000);
    });

    connection.on('updated', updatedStock => {
        console.log('Stock updated message received', updatedStock);
        const index = app.stocks.findIndex(s => s.id === updatedStock.id);
        console.log(`${updatedStock.symbol} Old price: ${app.stocks[index].price}, New price: ${updatedStock.price}`);
        app.stocks.splice(index, 1, updatedStock);
    });

    connection.start().then(() => {
        console.log("SignalR connection established");
    });
};

connect();