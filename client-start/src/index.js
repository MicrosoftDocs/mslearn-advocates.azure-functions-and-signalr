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
    interval: null,
    data() { 
        return {
            stocks: []
        }
    },
    methods: {
        async update() {
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
        },
        startPoll() {
            this.interval = setInterval(this.update, 5000);
        }
    },
    created() {
        this.update();
        this.startPoll();
    }
});