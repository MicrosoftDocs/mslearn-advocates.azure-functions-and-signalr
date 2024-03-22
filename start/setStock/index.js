const updateData = require('./update');

module.exports = async function (context, myTimer) {
    
    const timeStamp = new Date().toISOString();
    
    const newStock = await updateData(); // Replace this with your function
    console.log(`new stock: ${JSON.stringify(newStock)}`);

    if(myTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }

    context.log('JavaScript timer trigger function ran!', timeStamp);
    output.partitionKey = "/symbol";

    return newStock;
};