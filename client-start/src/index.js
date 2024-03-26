import './style.css';

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
                console.log(process.env.BACKEND_URL);
                const apiUrl = `${process.env.BACKEND_URL}/api/getStocks`;

                const response = await fetch(apiUrl);
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