import './style.css';

function getApiUrl() {

    const backend = process.env.BACKEND_URL;
    
    const url = (backend) ? `${backend}` : ``;

    console.log('Backend URL: ', url);
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
                
                const url = `${getApiUrl()}/api/getStocks`;
                console.log('Fetching stocks from ', url);

                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                app.stocks = await response.json();
            } catch (ex) {
                console.log('Caught Error fetching stocks: ', ex);
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