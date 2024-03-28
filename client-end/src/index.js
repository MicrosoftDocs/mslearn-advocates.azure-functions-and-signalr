import './style.css';

function getApiUrl() {
    if (process.env.BACKEND_URL) {
        // localhost or Codespaces
         return `${process.env.BACKEND_URL}/api/getStocks`;
    } else {
        // Production on SWA with managed backend
        return `/api/getStocks`;
    }
}


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

                const response = await fetch(getApiUrl());
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                console.log('Stocks fetched from ', apiUrl);
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
    const connection = new signalR.HubConnectionBuilder()
                            .withUrl(`${process.env.BACKEND_URL}/api`)
                            .configureLogging(signalR.LogLevel.Information)
                            .build();

    connection.onclose(()  => {
        console.log('SignalR connection disconnected');
        setTimeout(() => connect(), 2000);
    });

    connection.on('updated', updatedStock => {
        const index = app.stocks.findIndex(s => s.id === updatedStock.id);
        app.stocks.splice(index, 1, updatedStock);
    });

    connection.start().then(() => {
        console.log("SignalR connection established");
    });
};

connect();