'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

exports.dialogflowFirebaseFulfillment = functions.https.onRequest((request, response) => {
    console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
    console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

    const db = admin.database();
    const action = request.body.queryResult.action;
    if (action === 'product_description') {
        const product = request.body.queryResult.parameters.Products.trim();
        const ref = db.ref(`products/${product.toLowerCase()}/description`);
        ref.once('value').then((snapshot) => {
            const result = snapshot.val();
            if (result === null) {
                response.json({
                    fulfillmentText: `Product does not exists in inventory`
                });
                return;
            }
            response.json({
                fulfillmentText: `Here is the description of ${product}: ${result}`,
                source: action
            });

        }).catch((err) => {
            response.json({
                fulfillmentText: `I don't know what is it`
            });

        })
    } else if (action === 'product_quantity') {
        const product = request.body.queryResult.parameters.Products.trim();
        const ref = db.ref(`products/${product.toLowerCase()}`);
        ref.once('value').then((snapshot) => {
            const result = snapshot.val();
            if (result === null) {
                response.json({
                    fulfillmentText: `Product does not exists in inventory`
                });
                return;
            }
            if (!result.stock) {
                response.json({
                    fulfillmentText: `Currently ${product} is out of stock`,
                    source: action
                });
            } else {
                response.json({
                    fulfillmentText: `We have ${result.stock} ${product} in stock`,
                    source: action
                });
            }
        }).catch((err) => {
            response.json({
                fulfillmentText: `I don't know what is it`
            });
        })
    } else {
        response.json({
            fulfillmentText: `I don't know what is it`
        });
    }

});