
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});


/*** Twilio ***/
// Require and initialize the Twilio module with your credentials

var ACCOUNT_SID = "AC86b279230f26f7ca6293af12e5713e9d";
var AUTH_TOKEN = "17d74223b2e0e2dff89e7b35b52eb9ac";

var client = require('twilio')(ACCOUNT_SID, AUTH_TOKEN);

Parse.Cloud.define("sendSms", function(request, response) {
  response.success("Bonjour")

  // Send an SMS message
  client.sendSms({
      to:'+2153506681', 
      from: '+14506667788', 
      body: 'Bonjour!'
    }, function(err, responseData) { 
      if (err) {
        console.log(err);
      } else { 
        console.log(responseData.from); 
        console.log(responseData.body);
      }
    }
  );
});
