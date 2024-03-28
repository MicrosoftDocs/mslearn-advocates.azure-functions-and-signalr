import './style.css';

function getApiUrl() {

    const backend = process.env.BACKEND_URL;
    
    const url = (backend) ? `${backend}` : ``;
    console.log('API URL:', url);
    return url;
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

                const response = await fetch(`${getApiUrl()}/api/getStocks`);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                console.log('Stocks fetched from ', getApiUrl());
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
                            .withUrl(`${getApiUrl()}/api`)
                            .configureLogging(signalR.LogLevel.Information)
                            .build();

    connection.onclose(()  => {
        console.log('SignalR connection disconnected');
        setTimeout(() => connect(), 2000);
    });

    connection.on('updated', updatedStock => {
        console.log('Stock updated:', updatedStock);
        const index = app.stocks.findIndex(s => s.id === updatedStock.id);
        app.stocks.splice(index, 1, updatedStock);
    });

    connection.start().then(() => {
        console.log("SignalR connection established");
    });
};

connect();