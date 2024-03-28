import './style.css';

function getApiUrl() {

    const backend = process.env.BACKEND_URL;
    
    const url = (backend) ? `${backend}` : ``;
    console.log('API URL:', url);
    return url;
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
                
                const response = await fetch(`${getApiUrl()}/api/getStocks`);
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