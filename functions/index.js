const {onRequest} = require("firebase-functions/v2/https");

exports.testFunction = onRequest((request, response) => {
  response.send("BloodConnect Functions is working!");
});

