const fetchConfig = async () => {

    const result = await fetch('/config.json');

    if(result.ok) {
    const json = await response.json();
        // Use the data
        backendUrl = config.BASE_SERVERLESS_URL;
        console.log(`backendUrl:${backendUrl}`);

        return backendUrl;
    } else {
        console.error('Failed to fetch config.json');
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
                const backendUrl = await fetchConfig();
                const apiUrl = `${backendUrl}/api/getStocks`;
                console.log(`apiUrl:${apiUrl}`);
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