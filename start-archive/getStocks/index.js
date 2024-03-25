module.exports = async function (context, req, stocks) {
    context.res.body = stocks;
};