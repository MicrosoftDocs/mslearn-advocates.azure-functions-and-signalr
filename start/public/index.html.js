const LOCAL_BASE_URL = 'http://localhost:7071';

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
                const apiUrl = `${LOCAL_BASE_URL}/api/getStocks`;
                const response = await axios.get(apiUrl);
                console.log('Stocks fetched from ', apiUrl);
                app.stocks = response.data;
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