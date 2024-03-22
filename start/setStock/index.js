const updateData = require('./update');

module.exports = async function (context, myTimer) {
    
    const timeStamp = new Date().toISOString();
    
    const output = await updateData(); // Replace this with your function

    if(myTimer.isPastDue)
    {
        context.log('JavaScript is running late!');
    }

    context.log('JavaScript timer trigger function ran!', timeStamp);
    output.partitionKey = "/symbol";

console.log(`new stock: ${JSON.stringify(output)}`);

    context.bindings.outputDocument = output;
};